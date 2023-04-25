## 2.1. Swift Concurrencyによる非同期処理

- APIリクエストを送り、レスポンスを受け取ってその結果をViewに表示する際、その間Main Thread（UIを更新するスレッド）を止めてユーザーの自由を奪ってしまってはかなり体験の悪いアプリになってしまいます
- よってAPIリクエストは別スレッドで非同期に送り、結果が帰ってきたらMain ThreadでUIを更新する、という実装をするのが良いとされています
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
- 本セッションでポイントとなるSwift Concurrencyの3つの要素を簡単に紹介します
- async/await
   - 関数に `async` キーワードを付けることで、その関数内が「非同期なコンテキスト」になる
   - 「非同期なコンテキスト」では、他の `async` な関数を呼び出すことができる
   - `async` な関数を呼び出す際は `await` キーワードをつけてその結果を待つ（サスペンションポイント）
- Task
   - `Task` とは非同期で実行できる処理の単位
   - 「非同期なコンテキスト」を提供し、Backgroud Threadで実行される
- actor
   - `actor` とは `struct` や `class` と並ぶスレッドセーフなオブジェクト
   - 非同期処理であっても競合状態を回避しより安全な並行処理を実現できる
   - オブジェクトや関数に `@MainActor` を付与することで、その部分の処理が必ずメインスレッド（`MainActor` という特殊なactorのコンテキスト）で実行される
- では、Concurrencyを使った実装に置き換えてみましょう

```swift
struct RepoListView: View {
    ...
    
    var body: some View {
        ...
        .onAppear() {
            Task {
               await reposStore.loadRepos()
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
    1. `await reposStore.loadRepos()` で `loadRepos()` を開始しつつ、その結果を待つ状態に
    2. `loadRepos()` 内部では `Task.sleep(nanoseconds:)` を開始しつつ、その結果を待つ状態に
    3. 1秒後に `Task.sleep(nanoseconds:)` が完了し、`mockRepos` に mock の配列が代入され、`loadRepos()` 完了
    4. `await reposStore.loadRepos()` に返ってきて、一連の処理が終わる

- `onAppear() { Task {...} }` は下記と同等なので置き換えます

```swift
        ...
        .task {
            await reposStore.loadRepos()
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

- `ReposStore` を `RepoListView` のpropertyとして初期化して、 `mockRepos` を参照していた箇所を置き換えていきます

```swift
struct RepoListView: View {
    @State private var reposStore = ReposStore()

    var body: some View {
        NavigationView {
            if reposStore.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposStore.repos) { repo in
                    NavigationLink(
                        destination: RepoDetailView(repo: repo)) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
            }
        }
        .task {
            await reposStore.loadRepos()
        }
    }
}
```
    
- この状態でLive Previewを試してみましょう
- loadingのまま何も中身が更新されないことがわかるはずです
- @Stateはそのproperty自身に変更が加えられた際にViewの再描画を促します、この場合 `ReposStore` の内部で状態が変わったとしてもクラスのインスタンスが作り変えられるわけでもないので更新は走りません
- `ReposStore` の `repos` という特定のpropertyを監視する必要があります
- そのためには [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) を使用します
- `ReposStore` にObservableObjectを適用し、監視させたいpropertyである `repos` には [@Published](https://developer.apple.com/documentation/combine/published) をannotateします
    - @Publishedでannotateすると、そのpropertyの値の変更をView側から監視できるようになります

```swift
class ReposStore: ObservableObject {
    @Published private(set) var repos = [Repo]()
```
    
- そして最後に、 `RepoListView` のproperty `reposStore` には [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject) をannotateします

```swift
struct RepoListView: View {
    @StateObject private var reposStore = ReposStore()
```
    
- Live Previewでリポジトリがリスト表示されることを確認しましょう

### チャレンジ
- この状態でSimulatorを起動してみてください
- 紫色の警告が表示されるはずなので、なぜ警告が出たのかを理解しつつエラーメッセージの通りに修正してください

### ヒント
- エラーメッセージで提案される通りの修正方法ではありません

<details>
    <summary>解説</summary>

Simulatorで実行すると、以下のようなエラーが出るはずです

<img width="412" alt="スクリーンショット 2022-04-18 8 51 42" src="https://user-images.githubusercontent.com/17004375/163737497-4502dc70-449b-4cfa-852d-24a8d1894f33.png">

> Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.

iOSアプリでUIを更新する場合、必ずMain Threadから実行する必要があります
@PublishedはViewにbindされることを前提として作られているため、Backgroud Threadから値を更新しようとするとランタイムに上記のような紫色の警告が出て叱ってくれるというわけです

`Task` のクロージャ内はBackgroud Threadで実行さるので、 `repos` もBackgroud Threadで更新されていたんですね

以下のように `ReposStore` に `@MainActor` を指定してあげましょう

```swift
@MainActor
class ReposStore: ObservableObject {
    ...
```

これでSimulatorを起動しても紫色の警告が出なくなったことがわかるかと思います

ネットワークとの通信処理はMain ThreadをブロックしないようにBackground Threadで実行されます
通信によって得られた結果をViewに反映させる際に誤ってBackground Threadのまま更新しないように注意しましょう
</details>

### 前セッションとのDiff
[session-1.5..session-2.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.5..session-2.1)

## Next
[2.2. URLSessionによる通信](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.2)
