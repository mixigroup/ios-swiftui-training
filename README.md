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
            repos = try decoder.decode([Repo].self, from: data)
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
- ずっとloadingのままであることがわかります
- これだとユーザーは何が起きたか理解できないので、エラーをユーザーに表示できるようにましょう
- まずはキャッチしたエラーをViewに反映させるために、`ReposStore`のインスタンスプロパティに`error`を設置しましょう

```swift
@Observable   
class ReposStore {
    private(set) var repos = [Repo]()
    private(set) var error: Error? = nil

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

- 次に、公開された`error`を`RepoListView`側で監視し、[Button](https://developer.apple.com/documentation/swiftui/button)を使ってリトライ可能なUIを表示します

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationStack {
            if store.error != nil {
                VStack {
                    Text("Failed to load repositories")
                    Button(
                        action: {
                            Task {
                                // リトライボタンをタップしたときに再度リクエストを投げる
                                await store.loadRepos()
                            }
                        },
                        label: {
                            Text("Retry")
                        }
                    )
                    .padding()
                }
            } else {
                if store.repos.isEmpty {
                    ...
```

- 次に、読み込み中をより正しく表現できるようにします
- 現状はreposが空の場合を読み込み中と判定してしまっているので、別途読み込み中を監視できるようにします

```swift
@Observable   
class ReposStore {
    private(set) var repos = [Repo]()
    private(set) var error: Error? = nil
    private(set) var isLoading: Bool = false

    func loadRepos() {
        isLoading = true
        ...
 
        do {
            ...
            repos = ...
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}            
```

- そしてこれも`RepoListView`側で監視します

```swift
struct RepoListView: View {
    ...
    var body: some View {
        NavigationStack {
            if store.error != nil {
                ...
            } else {
                if store.isLoading {
                    ProgressView("loading...")
                } else {
                    List(store.repos) {...}
                     　　　.navigationTitle("Repositories")
                    ...
                }
            }
        }
    }
```
- 一度Live Previewで表示確認してみましょう
<img src="https://user-images.githubusercontent.com/17004375/234403886-3bf65068-a03f-4c3c-a3a7-16e36ceaf904.png" width="300" />

- 現状だと、エラーや読み込みの画面でナビゲーションタイトルが表示されていません
- これを解消するためにはそれぞれの画面に対応するViewに対して `.navigationTitle("Repositories")` を呼び出してあげると良さそうですが、同じ記述を3箇所書くのはなかなか悪いコードのにおいがします
- このような場合は [Group](https://developer.apple.com/documentation/swiftui/group) を使って複数のViewを一つにまとめて一括でmodifierを付与してあげましょう

```swift
    var body: some View {
        NavigationStack {
            Group {
                if store.error != nil {
                    ...   
                } else {
                    if store.isLoading {
                        ...
                    } else {
                        if store.repos.isEmpty {
                            ...
                        } else {
                            List(store.repos) {...}
                        }
                    }
                }
            }
            .navigationTitle("Repositories")
            .navigationDestination(for: Repo.self) { repo in
                RepoDetailView(repo: repo)
            }
        }
```

- ナビゲーションタイトルが表示されるようになりました
<img src="https://user-images.githubusercontent.com/17004375/234403615-297b6a01-0b48-48bf-ab44-138dc6c999d2.png" width="300" />

### チャレンジ

- Repoの配列を読み込むという状態を表現するためだけに3つものpropertyが定義されてしまいました
- これでもでも問題なく動作していますが、コードが複雑になり可読性が下がっています
  - また、repoの取得が成功したにも関わらずerrorが非nilである状態や、読み込み中である状態を潜在的に抱えてしまっているという問題もあります
  - 現状、repoが空かどうか、errorがnilかどうか、読み込み中かどうか、の`2^3 = 8`通りの状態が存在します
- 表現したい状態は、読み込み中 or 読み込み失敗 or 読み込み完了 の3通りだけです
- 状態を必要十分に表現するため、1つのpropertyにまとめる方針でリファクタリングしてみましょう

#### ヒント

- [session-0](https://github.com/mixigroup/ios-swiftui-training/blob/session-0/README.md)では、状態を必要十分に表現するためにenumとassociated valuesを活用する例をご紹介しました
- 状態を表現できる型として `Stateful` という enum を定義し、これを使うようにしてみましょう

```swift
enum Stateful<Value> {
    /// 読み込み中
    case loading
    /// 読み込み失敗、遭遇したエラーを保持
    case failed(Error)
    /// 読み込み完了、読み込まれた値を保持
    case loaded(Value)
}
```

<details>
    <summary>解説</summary>

Statefulを駆使して3つあったインスタンスプロパティを1つにしていきます

```swift
@Observable
class ReposStore {
    private(set) var state: Stateful<[Repo]> = .loading

    func loadRepos() {
        state = .loading
        ...

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let repos = try decoder.decode([Repo].self, from: data)

            state = .loaded(repos)
        } catch {
            state = .failed(error)
        }
    }
}

struct RepoListView: View {
    ...
    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        ...
                    }
                case .failed:
                    ...
                }
            }
            .navigationTitle("Repositories")
            .navigationDestination(for: Repo.self) { repo in
                RepoDetailView(repo: repo)
            }
        }
        ...
    }
}
```
        
ネストが減り、より直感的に読みやすいコードになったと思います。
        
このように、型を工夫して必要なpropertyを最小限にすることで、コードの可読性および保守性を大幅に上げることができます。
最初から理想のコードを書くことは難しいので、一度動くコードを一通りかけたら見直して改善できる余地がないかを検討する癖をつけておきましょう。

</details>

### 前セッションとのDiff
[session-2.2..session-2.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-2.2..session-2.3)

## Next
[3.1. Single Source of Truth](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.1)
