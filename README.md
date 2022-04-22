## 2.3. エラーハンドリング
- 通信は必ず成功するものではありません、そして仮に失敗した場合にはしっかりエラーをハンドリングしてユーザーがそれを理解できるように示してあげる必要があります
- まずは `response.statusCode` が 200 以外の場合に `URLError(.badServerResponse)` をthrowするようにしましょう
- この時、`try!` となっている部分は `do {}` 内に含めつつ `try` に直してエラーをキャッチできるようにします

```swift
        ...
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)

            repos = value
        } catch {
            print("error: \(error)")
        }
```
- 次に、`response.statusCode` が 200 以外だった場合を再現するために、必ず `URLError(.badServerResponse)` がthrowされるように変更してみます
```swift
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
//            }
```
- この状態でLive Previewで確認してみてください
- ずっとloadingのままであることがわかります、これだとユーザーは何が起きたか理解できないどころか、エラーから復帰することもできません

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
@MainActor   
class ReposStore: ObservableObject {
    @Published private(set) var repos = [Repo]()
    @Published private(set) var error: Error? = nil

    func loadRepos() {
        ...
        do {
            ...
        } catch {
            self.error = error
        }
    }
}            
```

次に、この公開されたエラーをList側で監視します

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            if reposStore.error != nil {
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
                            Task {
                                await reposStore.loadRepos() // リトライボタンをタップしたときに再度リクエストを投げる
                            }
                        },
                        label: {
                            Text("Retry")
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.top, 8)
                }
            } else {
                if reposStore.repos.isEmpty {
                    ...
```

次に、読み込み中を表現できるようにします <br>
現状はreposが空の場合を読み込み中と判定してしまっているので、別途@Publishedで読み込み中を監視できるようにしてあげる必要があります

```swift
@MainActor   
class ReposStore: ObservableObject {
    @Published private(set) var repos = [Repo]()
    @Published private(set) var error: Error? = nil
    @Published private(set) var isLoading: Bool = false

    func loadRepos() {
        ...
        isLoading = true
            
        do {
            ...
            repos = value
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}            
```

あとはこれをList側で監視してあげます

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            if reposStore.error != nil {
                ...
            } else {
                if reposStore.isLoading {
                    ProgressView("loading...")
                } else {
                    if reposStore.repos.isEmpty {
                        Text("No repositories")
                            .fontWeight(.bold)
                    } else {
                        List(reposStore.repos) {...}
                        .navigationTitle("Repositories")
                    }
                }
            }
        }
    }
```

(reposに空配列(<code>[]</code>)を代入して一度Live Previewで表示確認してみましょう)

現状だと、エラー画面や空画面でナビゲーションが表示されていません <br>
これを解消するためにはそれぞれの画面に対応するViewに対して <code>.navigationTitle("Repositories")</code> を呼び出してあげると良さそうですが、同じ記述を3箇所書くのはなかなか悪いコードのにおいがします

そんな時は [Group](https://developer.apple.com/documentation/swiftui/group) を使って複数のViewを一つにまとめて一括でmodifierを付与してあげましょう

```swift
    var body: some View {
        NavigationView {
            Group {
                if reposStore.error != nil {
                    ...   
                } else {
                    if reposStore.isLoading {
                        ...
                    } else {
                        if reposStore.repos.isEmpty {
                            ...
                        } else {
                            List(reposStore.repos) {...}
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
@MainActor
class ReposStore: ObservableObject {
    @Published private(set) var state: Stateful<[Repo]> = .idle

    func loadRepos() {
        ...
        state = .loading

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)

            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}

struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            Group {
                switch reposStore.state {
                case .idle, .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    if repos.isEmpty {
                        Text("No repositories")
                        ...  
                    } else {
                        List(repos) { repo in
                            ...
                        }
                    }
                case .failed:
                    ...
                }
            }
            .navigationTitle("Repositories")
        }
        ...
    }
}
```
このままでも良さそうですが、さらに `repos` が空の場合と空でない場合を別の状態として扱うようにしてみます。以下のように switch の機能を活用します。
  
```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationView {
            Group {
                switch reposStore.state {
                case .idle, .loading:
                    ProgressView("loading...")
                case .loaded([]):
                    Text("No repositories")
                    ...  
                case let .loaded(repos):
                    List(repos) { repo in
                        ...
                    }
                case .failed:
                    ...
                }
            }
            .navigationTitle("Repositories")
        }
        ...
    }
}
```
        
ネストが減り、より直感的に読みやすいコードになったと思います。しかし、このままでは以下のようなエラーが出てしまいます。
        
> Operator function '~=' requires that 'Repo' conform to 'Equatable'
        
switch 内部で `repos: [Repo]` の等価性を比較するため、`Repo` を `Equatable` に準拠させる必要があります。
        
```swift      
struct Repo: Identifiable, Decodable, Equatable {        
...   
```
```swift
struct User: Decodable, Equatable {
...        
```
        

このように、型を工夫して必要なpropertyを最小限にすることができると、コードの可読性および保守性を大幅に上げることができます <br>
最初から一発で理想のコードを書くことは難しいので、一度動くコードを一通りかけたら見直して改善できる余地がないかを検討する癖をつけておきましょう

</details>

### 前セッションとのDiff
[session-2.2..session-2.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.2..session-2.3)

## Next
[3.1. MVVMアーキテクチャ](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.1)
