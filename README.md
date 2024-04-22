## 2.1. Swift Concurrencyによる非同期処理

- APIリクエストを送り、レスポンスを受け取ってその結果をViewに表示する際、その間Main Thread（UIを更新するスレッド）を止めてユーザーの自由を奪ってしまってはかなり体験の悪いアプリになってしまいます
- よってAPIリクエストは別スレッドで非同期に送り、結果が返ってきたらMain ThreadでUIを更新する、という実装をするのが良いとされています
- そこで、API通信周りの実装する前に、まずは非同期処理について学ぶ必要があります
- 今回は [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) という仕組みを用いて実装していきます
- Swift Concurrency とは非同期処理および並行処理のコードを簡潔かつ安全に記述できる機能です
- 例として「写真名の一覧をダウンロードした後、さらにその最初の写真をダウンロードしてユーザーに表示する処理」をクロージャとConcurrencyでそれぞれ実装したものです
   - 引用：https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/

```swift
// クロージャを使った実装
listPhotos(inGallery: "Summer Vacation") { photoNames in
    let sortedNames = photoNames.sorted()
    let name = sortedNames[0]
    downloadPhoto(named: name) { photo in
        show(photo)
    }
}
```

```swift
// Swift Concurrencyを使った実装
let photoNames = await listPhotos(inGallery: "Summer Vacation")
let sortedNames = photoNames.sorted()
let name = sortedNames[0]
let photo = await downloadPhoto(named: name)
show(photo)
```
- 同じ内容の処理でもSwift Concurrencyを使った実装ではネストがなくなり、直感的に理解しやすくなっていると思います
- 親子関係をもつ複数の非同期処理を構造的に扱うStructured Concurrencyという仕組みも存在しますが、本セッションでは詳しくは述べません
  - 詳しくは[Tasks and Task Groups](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency#Tasks-and-Task-Groups)というドキュメントをご覧ください
- Swift Concurrencyにおいて重要な3つのキーワードについて簡単に紹介します
- async/await
   - 関数に `async` キーワードを付けることで、その関数内が「非同期なコンテキスト」になる
   - 「非同期なコンテキスト」では、他の `async` な関数を呼び出すことができる
   - `async` な関数を呼び出す際は `await` キーワードをつけてその結果を待つ（サスペンションポイント）
- Task
   - `Task` とは非同期で実行できる処理の単位
   - 「非同期なコンテキスト」を提供し、Backgroud Threadで実行される
- actor
   - `actor` とは `struct` や `class` と並ぶ型の一種
   - マルチスレッドにおけるデータ競合を回避し、より安全な並行処理を実現するための型
   - 本セッションでは直接利用することがないので解説は省略します（気になる方は[ドキュメント](https://developer.apple.com/documentation/swift/actor)をご覧ください）
- では、Concurrencyを使った実装に置き換えてみましょう

```swift
struct RepoListView: View {
    ...
    
    var body: some View {
        ...
        .onAppear() {
            Task {
               await store.loadRepos()
            }
        }
    }
    
    private func loadRepos() async {        
        try! await Task.sleep(nanoseconds: 1_000_000_000)　// 1秒待つ

        mockRepos = [.mock1, .mock2, .mock3, .mock4, .mock5]
    }
}
```

- 以下の流れになります
    1. `await store.loadRepos()` で `loadRepos()` を開始しつつ、その結果を待つ状態に
    2. `loadRepos()` 内部では `Task.sleep(nanoseconds:)` を開始しつつ、その結果を待つ状態に
    3. 1秒後に `Task.sleep(nanoseconds:)` が完了し、`mockRepos` に mock の配列が代入され、`loadRepos()` 完了
    4. `await store.loadRepos()` に返ってきて、一連の処理が終わる

- `onAppear() { Task {...} }` は下記と同等なので置き換えます

```swift
        ...
        .task {
            await store.loadRepos()
        }
```

- 次に `loadRepos()` メソッドを別のクラスに切り出してみます
- `ReposStore` というクラスを作ってみてください (ファイルは `RepoListView` と同じで構いません)

```swift
class ReposStore {
    private(set) var repos = [Repo]()

    func loadRepos() async {
        try! await Task.sleep(nanoseconds: 1_000_000_000)

        repos = [.mock1, .mock2, .mock3, .mock4, .mock5]
    }
}
```

- `store` を `RepoListView` のpropertyとして初期化して、 `mockRepos` を参照していた箇所を置き換えていきます

```swift
struct RepoListView: View {
    @State private var store = ReposStore()

    var body: some View {
        NavigationView {
            if store.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(store.repos) { repo in
                    NavigationLink(value: repo) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
                .navigationDestination(for: Repo.self) { repo in
                    RepoDetailView(repo: repo)
                }
            }
        }
        .task {
            await store.loadRepos()
        }
    }
}
```
    
- この状態でLive Previewを試してみましょう
- loadingのまま何も中身が更新されないことがわかるはずです
- @Stateはそのproperty自身に変更が加えられた際にViewの再描画を促します、この場合 `ReposStore` の内部で状態が変わったとしてもクラスのインスタンスが作り変えられるわけでもないので更新は走りません
- 適切にViewが更新されるようにするために　`ReposStore`　インスタンス内部の変更を監視できるようにする必要があります
- そのためには　[Observation](https://developer.apple.com/documentation/observation)　フレームワークの　[@Observable](https://developer.apple.com/documentation/observation/observable()) を使用します
- Observableマクロは、対象の型に監視サポートを追加し、[Observableプロトコル](https://developer.apple.com/documentation/observation/observable)　に準拠させてこれを監視可能にします

```swift
@Observable
class ReposStore {
    private(set) var repos = [Repo]()
```
    
- Live Previewでリポジトリがリスト表示されることを確認しましょう

### チャレンジ
(本セクションではチャレンジはありません)

### 前セッションとのDiff
[session-1.5..session-2.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.5..session-2.1)

## Next
[2.2. URLSessionによる通信](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.2)
