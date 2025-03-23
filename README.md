## 3.2. Swift Testing
- 責務の分離を施したことによるメリットとして、各クラスをテストしやすくなったという点があります
- `ReposStore` のテストを書いてみましょう
- テストしたい項目は以下の通りです
    - Viewが表示されたとき(onAppear actionを受け取ったとき)にリポジトリ一覧を取得して表示する
    - 取得時にエラーが発生した場合にはstateには`.failed`がセットされていること
- iOSでテストを書くために、まずはTest Targetを下図のように追加してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115539731-49d0fa00-a2d8-11eb-85a0-87ec3b6548c0.png">

- `GitHubClientTests.swift` というテストファイルがすでに追加されているはずなので、 `ReposStoreTests` にrenameしましょう
- `@Test` を付けたメソッドがテストケースとして認識されて実行されます
- まずは、「リポジトリ一覧が正常に読み込まれること」をテストするメソッドを追加しましょう

```swift
@testable import GitHubClient

struct ReposStoreTests {
    @Test func onAppear_正常系() async {
    }
}
```

- テストターゲットからメインターゲットのメソッドやクラスを参照するために `@testable import GitHubClient` を宣言しています
    - 本来ならばpublicで修飾されていなければ外部ターゲットのフィールドにはアクセスできませんが、 `@testable import` によってinternalなフィールドにもアクセス可能になります
- テストメソッド内で async な関数 `ReposStore`の`send(.onAppear)` を呼び出したいので、あらかじめテストメソッドに `async` を付与します
- まずはテストメソッド内で、テスト対象の `ReposStore` を初期化し、`send(.onAppear)` を呼び出してリポジトリが読み込まれるか確認...
- と、このままだとテストを走らせるたびにAPI通信が走ってしまいます
- 常套手段として、 `ReposStore` が依存している `RepoAPIClient` をモックに差し替えましょう
- そのためには、以下の2つのことをしてあげる必要があります
    - 現在メソッド内で初期化されている `RepoAPIClient` を外から渡す (Dependency Injection)
    - `RepoAPIClient` のインターフェースを抽象化したprotocolを`ReposStore`のイニシャライザ引数とする

```swift
protocol RepositoryHandling {
    func getRepos() async throws -> [Repo]
}

struct RepoAPIClient: RepositoryHandling {
    func getRepos() async throws -> [Repo] {
        ...
    }
}
```

```swift
@Observable
final class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    private(set) var state: Stateful<[Repo]> = .loading

    private let repoAPIClient: RepositoryHandling

    init(repoAPIClient: RepositoryHandling = RepoAPIClient()) {
        self.repoAPIClient = repoAPIClient
    }
    ...
    func send(_ action: Action) async {
        ...
        do {
            let repos = try await repoAPIClient.getRepos()
        ...
    }
}
```

- これで `RepoAPIClient` をモックに差し替える準備が整いました、早速モックを作ってみましょう

```swift
struct ReposStoreTests {
    ...
    
    struct MockRepoAPIClient: RepositoryHandling {
        var getRepos: () async throws -> [Repo]

        func getRepos() async throws -> [Repo] {
            try await getRepos()
        }
    }
}
```

- このモックのポイントは以下になります。
    - イニシャライザの引数で、`getRepos()`を呼び出したときのふるまいを定義する
    - `getRepos()` ではイニシャライザ引数で受け取った値をそのまま返す

- では、モックを使って実際にテストを書いていきましょう
- Viewに反映されるデータは `ReposStore.state` です、テストメソッドでもこの値を監視して想定通りに更新されていることを確認します

```swift
struct ReposStoreTests {
    @Test func onAppear_正常系() async {
        let store = ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: { [.mock1, .mock2] }
            )
        )

        await store.send(.onAppear)

        switch store.state {
        case let .loaded(repos):
            #expect(repos == [.mock1, .mock2])
        default:
            Issue.record("state should be `.loaded`")
        }
    }
    
    ...
}
```

- 順番に見ていきましょう
- `await store.send(.onAppear)` を呼び出し、Viewの`onAppear(_:)` が呼ばれたことをシミュレートし、リポジトリ情報の取得を開始しその結果を待ちます
- `sned(.onAppear)` が完了すると await より下に書かれたコードが実行され、 `store.state` に対する検証が行われます
- `⌘ + U` でテストが通ることを確認しましょう

### チャレンジ
- 異常系のテストを書いてみましょう
- 適当なエラーは以下のように定義することが可能です

```swift
struct DummyError: Error {}
let dummyError = DummyError()
```

<details>
    <summary>解説</summary>

正常系のテストと同じ要領でテストを書いていきます

```swift
@Test func onAppear_異常系() async {
    let store = ReposStore(
        repoAPIClient: MockRepoAPIClient(
            getRepos: { throw DummyError() }
        )
    )

    await store.send(.onAppear)

    switch store.state {
    case let .failed(error):
        #expect(error is DummyError)
    default:
        Issue.record("state should be `.failed`")
    }
}
```

テストが通ることが確認できれば完了です

</details>

### 前セッションとのDiff
[session-3.1..session-3.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.1..session-3.2)

## Next
[3.3. Xcode Previewsの再活用](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.3/README.md)
