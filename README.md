## 2.3. エラーハンドリング
- 通信は必ず成功するものではありません、そして仮に失敗した場合にはしっかりエラーをハンドリングしてユーザーがそれを理解できるように示してあげる必要があります
- 先のセッションで実装したURLSession周りの処理で必ずErrorをthrowするようにしてみましょう

```swift
            .tryMap() { element -> Data in
//                guard let httpResponse = element.response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
//                }
//                return element.data
            }
```
    
- この状態でLive Previewで確認してみてください
- ずっとloadingのままであることがわかります、これだとユーザーは何が起きたか理解できないどころか、エラーから復帰することもできません
- throwされたErrorをキャッチするにはSinkの `receiveCompletion` にて処理を記述します
- 以下のようにSwitch文で [Subscribers.Completion](https://developer.apple.com/documentation/combine/subscribers/completion) からエラーをハンドリングします

```swift
.sink(receiveCompletion: { completion in
    switch completion {
    case .failure(let error):
        print("Error: \(error)")
    case .finished: print("Finished")
    }
}
```

### チャレンジ
- エラーをキャッチした際には以下のようなエラー画面を表示しましょう
<img src="https://user-images.githubusercontent.com/8536870/115537014-5869e200-a2d5-11eb-976b-ca4612adfba7.png" width=50%>

- リトライボタンの表示には [Button](https://developer.apple.com/documentation/swiftui/button) を使用してください
- リトライボタンを押すと再びリポジトリ一覧を取得しつつ、その最中はloadingを表示させてください
- もし取得したリポジトリが空の場合には以下のように空であることを示してください

<img src="https://user-images.githubusercontent.com/8536870/115537090-6e77a280-a2d5-11eb-801a-03e8b99fc87d.png" width=50%>

<details>
    <summary>解説</summary>

まずはキャッチしたエラーをViewに反映させるために、@Publishedでエラーを監視できるようにしましょう

```swift
class ReposLoader: ObservableObject {
    @Published private(set) var repos = [Repo]()
    @Published private(set) var error: Error? = nil
    ...
    func call() {
        ...
        reposPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error
                case .finished:
                    ...
```

次に、この公開されたエラーをList側で監視します

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            if reposLoader.error != nil {
                VStack {
                    Group {
                        Image("GitHubMark")
                        Text("Failed to load repositories")
                            .padding(.top, 4)
                    }
                    .foregroundColor(.black)
                    .opacity(0.4)
                    Button(
                        action: {
                            reposLoader.call() // リトライボタンをタップしたときに再度リクエストを投げる
                        },
                        label: {
                            Text("Retry")
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.top, 8)
                }
            } else {
                if reposLoader.repos.isEmpty {
                    ...
```

次に、読み込み中を表現できるようにします <br>
現状はreposが空の場合を読み込み中と判定してしまっているので、別途@Publishedで読み込み中を監視できるようにしてあげる必要があります


```swift
class ReposLoader: ObservableObject {
    @Published private(set) var repos = [Repo]()
    @Published private(set) var error: Error? = nil
    @Published private(set) var isLoading: Bool = false
    ...
    func call() {
        ...
        reposPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.isLoading = true
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {...}
                self?.isLoading = false
            }, receiveValue: {...})
```

今回は [handleEvents(receiveSubscription:)](https://developer.apple.com/documentation/combine/fail/handleevents(receivesubscription:receiveoutput:receivecompletion:receivecancel:receiverequest:)) でPublisherがsubscribeされたタイミングを受け取ってisLoadingをtrueに、SinkのreceiveCompletionにてfalseに切り替えるように実装しています

あとはこれをList側で監視してあげます

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            if reposLoader.error != nil {
                ...
            } else {
                if reposLoader.isLoading {
                    ProgressView("loading...")
                } else {
                    if reposLoader.repos.isEmpty {
                        Text("No repositories")
                            .fontWeight(.bold)
                    } else {
                        List(reposLoader.repos) {...}
                        .navigationTitle("Repositories")
                    }
                }
            }
        }
    }
```

(sinkのreceiveValueにてreposに空配列(<code>[]</code>)を代入して一度Live Previewで表示確認してみましょう)

現状だと、エラー画面や空画面でナビゲーションが表示されていません <br>
これを解消するためにはそれぞれの画面に対応するViewに対して <code>.navigationTitle("Repositories")</code> を呼び出してあげると良さそうですが、同じ記述を3箇所書くのはなかなか悪いコードのにおいがします

そんな時は [Group](https://developer.apple.com/documentation/swiftui/group) を使って複数のViewを一つにまとめて一括でmodifierを付与してあげましょう

```swift
    var body: some View {
        NavigationView {
            Group {
                if reposLoader.error != nil {
                    ...   
                } else {
                    if reposLoader.isLoading {
                        ...
                    } else {
                        if reposLoader.repos.isEmpty {
                            ...
                        } else {
                            List(reposLoader.repos) {...}
                        }
                    }
                }
            }
            .navigationTitle("Repositories")
        }
```

さて、振り返ってみてみると、Repoの配列を読み込むという状態を表現するためだけに@Publishedなpropertyが3つも定義されてしまいました

これを1つのpropertyのみで表現できるように改善してみます

そのためには、読み込み中の状態を表現できる型として <code>Stateful</code> というものを定義します

```swift
enum Stateful<Value> {
    case idle // まだデータを取得しにいっていない
    case loading // 読み込み中
    case failed(Error) // 読み込み失敗、遭遇したエラーを保持
    case loaded(Value) // 読み込み完了、読み込まれたデータを保持
}
```

このStatefulを駆使して3つあった@Publishedを1つにしていきます

```swift
class ReposLoader: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle
    ...
    func call() {
        ...
        reposPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.repos = .failed(error)
                case .finished:
                    print("Finished: \(completion)")
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            }
            ).store(in: &cancellables)
    }
}

struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            Group {
                switch reposLoader.repos {
                case .idle, .loading:
                    ProgressView("loading...")
                case .failed:
                    ...
                case let .loaded(repos):
                    if repos.isEmpty {
                        ....
                    } else {
                        List(repos) {...}
                }
            }
            .navigationTitle("Repositories")
        }
        ...
    }
}
```

このように、型を工夫して必要なpropertyを最小限にすることができると、コードの可読性および保守性を大幅に上げることができます <br>
最初から一発で理想のコードを書くことは難しいので、一度動くコードを一通りかけたら見直して改善できる余地がないかを検討する癖をつけておきましょう

</details>

### 前セッションとのDiff
[session-2.2..session-2.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.2..session-2.3)

## Next
[3.1. MVVMアーキテクチャ](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.1)
