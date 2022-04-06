## 2.1. Combineによる非同期処理

- APIリクエストを送り、レスポンスを受け取ってその結果をViewに表示する際、その間Main Threadを止めてユーザーの自由を奪ってしまってはかなり体験の悪いアプリになってしまいます
- よってAPIリクエストは別スレッドで非同期に送り、結果が帰ってきたらMain ThreadでUIを更新する、という実装をするのが良いとされています
- なので、API通信周りの実装する前に、まずは非同期処理について学ぶ必要があります
- 今回は [Combine](https://developer.apple.com/documentation/combine) というフレームワークを用いて実装していきます
- CombineとはApple製のリアクティブプログラミングのフレームワークです、 `import Combine` を宣言することで利用可能です
- Combineには大きな概念として以下の二つがあります
- [Publisher](https://developer.apple.com/documentation/combine/publisher):
    - 時系列順にイベントを発火する
    - 様々なoperatorによってイベントを加工して流したり、複数のPublisherを合成して一つのストリームにしたりすることが可能
- [Subscriber](https://developer.apple.com/documentation/combine/subscriber):
    - Publisherをsubscribeしてイベントを受け取る
    - 返り値のcancellableを保持しておくことで任意のタイミングでキャンセルすることも可能

- 具体的な例を見せつつ説明します

```swift
struct RepoListView: View {
    ...
    private var cancellables = Set<AnyCancellable>()
    
    var body: some View { ... }

    private mutating func loadRepos() {
        let reposPublisher = Future<[Repo], Error> { promise in
            DispatchQueue.main().asyncAfter(deadline: .now() + 1.0) {
                promise(.success([
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ]))
            }
        }
        reposPublisher.sink(receiveCompletion: { completion in
            print("Finished: \(completion)")
        }, receiveValue: { repos in
            mockRepos = repos
        }
        ).store(in: &cancellables)
    }
}
```

- `loadRepos()` メソッドを見てください、図にすると以下のようなイメージです

<img src="https://user-images.githubusercontent.com/8536870/115534916-396a5080-a2d3-11eb-9c6a-e76302326259.png">

- 説明すると、以下のようなことが実行されています
    1. FutureというPublisherで1秒後にリポジトリ一覧がストリームに流れる
    2. SinkというSubscriberで上記Publisherをsubscribe
    3. `.store(in: &cancellables)` でSubscriberが返す [Cancellable](https://developer.apple.com/documentation/combine/cancellable) を保持  
    4. 1秒後にPublisherから流れてきたArray<Repo>をSinkの `receiveValue` にてmockReposに反映 

- しかし、この状態だと以下のようなエラーが出てしまいます

> Cannot use mutating member on immutable value: 'self' is immutable

- これはsubscribe時に返されるcancellableを構造体である `RepoListView` のメンバ変数である `cancellables` に対して追加しようとしているためエラーが出ています
- 構造体は値型なので、mutatingのキーワードを付与したメソッド内でしかpropertyの更新ができません (よって、 `View.body` 内でエラーが起きている)
- なので、参照型であるclassに「リポジトリ一覧を読み込む処理」を委譲しましょう
- `ReposLoader` というクラスを作ってみてください (ファイルは `RepoListView` と同じで構いません)

```swift
class ReposLoader {
    private(set) var repos = [Repo]()
    
    private var cancellables = Set<AnyCancellable>()
    
    func call() {
        let reposPublisher = Future<[Repo], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promise(.success([
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ]))
            }
        }
        reposPublisher
            .sink(receiveCompletion: { completion in
                print("Finished: \(completion)")
            }, receiveValue: { [weak self] repos in
                self?.repos = repos
            }
            ).store(in: &cancellables)
    }
}
```

- `ReposLoader` を `RepoListView` のpropertyとして初期化して、 `mockRepos` を参照していた箇所を置き換えていきます

```swift
struct RepoListView: View {
    @State private var reposLoader = ReposLoader()

    var body: some View {
        NavigationView {
            if reposLoader.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposLoader.repos) { repo in
                    NavigationLink(
                        destination: RepoDetailView(repo: repo)) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
            }
        }
        .onAppear {
            reposLoader.call()
        }
    }
}
```
    
- この状態でLive Previewを試してみましょう
- loadingのまま何も中身が更新されないことがわかるでしょう
- @Stateはそのproperty自身に変更が加えられた際にViewの再描画を促します、この場合 `ReposLoader` の内部で状態が変わったとしてもクラスのインスタンスが作り変えられるわけでもないので更新は走りません
- `ReposLoader` の `repos` という特定のpropertyを監視する必要があります
- そのためには [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) を使用します
- `ReposLoader` にObservableObjectを適用し、監視させたいpropertyである `repos` には [@Published](https://developer.apple.com/documentation/combine/published) をannotateします
    - @Publishedでannotateすると、そのpropertyの型でPublisherを生成してくれます、これをView側から監視するわけです

```swift
class ReposLoader: ObservableObject {
    @Published private(set) var repos = [Repo]()
```
    
- そして最後に、 `RepoListView` のproperty `reposLoader` には [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject) をannotateします

```swift
struct RepoListView: View {
    @StateObject private var reposLoader = ReposLoader()
```
    
- Live Previewでリポジトリがリスト表示されることを確認しましょう

### チャレンジ
- `ReposLoader.call` 内で `DispatchQueue.main.asyncAfter` を `DispatchQueue.global().asyncAfter` に変更して `⌘ + R` でSimulatorを起動してみてください
- 紫色の警告が表示されるはずなので、なぜ警告が出たのかを理解しつつエラーメッセージの通りに修正してください

<details>
    <summary>解説</summary>
まずは言われた通り <code>DispatchQueue.main.asyncAfter</code> を <code>DispatchQueue.global().asyncAfter</code> に変更して <code>⌘ + R</code> でSimulatorを起動してください <br>
Main ThreadでPublisherにイベントを流していた部分をBackground Threadで流すようにするという変更になっていて、これによってSubscriber側もBakcground Threadでの実行となります

1秒待つと、以下のようなエラーが出るはずです

![スクリーンショット 2021-05-03 16 43 39](https://user-images.githubusercontent.com/8536870/116852205-d8c20880-ac2e-11eb-8dd3-acb9606e5462.png)

> Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.

iOSアプリでUIを更新する場合、不整合が起きないように必ずMain Threadから実行する必要があります <br>
@PublishedはViewにbindされることを前提として作られているため、Backgroud Threadから値を更新しようとするとランタイムに上記のような紫色の警告が出て叱ってくれるというわけです

怒られないようにどうすれば良いかのヒントも併記してくれていて、どうやら [receive(on:)](https://developer.apple.com/documentation/combine/fail/receive(on:options:)) を使ってMain Threadを指定してあげると良いらしいです

以下のようにSinkによるsubscribeの前にreceive(on:)でMain Threadを指定してあげましょう

```swift
reposPublisher
    .receive(on: DispatchQueue.main)
    .sink(...)
```

これでまたSimulatorを起動しても紫色の警告が出なくなったことがわかるかと思います

ネットワークとの通信処理はMain ThreadをブロッキングしないようにBackground Threadで実行されます <br>
通信によって得られた結果をViewに反映させる際に誤ってBackground Threadのまま更新しないように注意して開発しましょう
</details>

### 前セッションとのDiff
[session-1.5..session-2.1](https://github.com/mixigroup/ios-swiftui-training/compare/session-1.5..session-2.1)

## Next
[2.2. URLSessionによる通信](https://github.com/mixigroup/ios-swiftui-training/tree/session-2.2)
