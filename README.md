## 3.2. XCTest
- 責務の分離を施したことによるメリットとして、各クラスをテストしやすくなったという点があります
- `ReposStore` のテストを書いてみましょう
- テストしたい項目は以下の通りです
    - Viewが表示されたとき(onAppear actionを受け取ったとき)にリポジトリ一覧を取得して表示する
    - 取得時にエラーが発生した場合にはstateには`.failed`がセットされていること
- iOSでテストを書くために、まずはTest Targetを下図のように追加してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115539731-49d0fa00-a2d8-11eb-85a0-87ec3b6548c0.png">

- `GitHubClientTests.swift` というテストファイルがすでに追加されているはずなので、 `ReposStoreTests` にrenameしましょう
- `setUpWithError` と `tearDownWithError` は各テストの開始, 終了時にそれぞれ呼ばれます
- `test` から始まるメソッドがテストケースとして認識されて実行されます
- とりあえずは `setUpWithError`, `tearDownWithError`を消してしまい、「正しくリポジトリ一覧が読み込まれること」をテストするメソッドを追加しましょう

```swift
@testable import GitHubClient

class ReposStoreTests: XCTestCase {
    func test_onAppear_正常系() async {
    }
}
```

- テストターゲットからメインターゲットのメソッドやクラスを参照するために `@testable import GitHubClient` を宣言しています
    - 本来ならばpublicで修飾されていなければ外部ターゲットのフィールドにはアクセスできませんが、 `@testable import` によってinternalなフィールドにもアクセス可能になります
- テストメソッド内で async な関数 `ReposStore`の`send(.onAppear)` を呼び出したいので、あらかじめテストメソッドに `async` を付与します
- まずはテストメソッド内で、テスト対象の `ReposStore` を初期化し、`send(.onAppear)` を呼び出してリポジトリが読み込まれるか確認...
- と、このままだとテストを走らせるたびにAPI通信が走ってしまいます
- 常套手段として、 `ReposStore` が依存している `RepoAPIClient` をモックに差し替えましょう
- そのためには、以下の二つのことをしてあげる必要があります
    - 現在メソッド内で初期化されている `RepoAPIClient` を外から渡す (Dependency Injection)
    - `RepoAPIClient` のI/Fを抽象化したprotocolを`ReposStore`のイニシャライザ引数とする

```swift
protocol RepoAPIClientProtocol {
    func getRepos() async throws -> [Repo]
}

struct RepoAPIClient: RepoAPIClientProtocol {
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

    private let repoAPIClient: RepoAPIClientProtocol

    init(repoAPIClient: RepoAPIClientProtocol = RepoAPIClient()) {
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
class ReposStoreTests: XCTestCase {
    ...
    
    struct MockRepoAPIClient: RepoAPIClientProtocol {
        var getRepos: () async throws -> [Repo]

        func getRepos() async throws -> [Repo] {
            try await getRepos()
        }
    }
}
```

- モックはこんな感じになります
    - イニシャライザの引数で、`getRepos()`を呼び出したときのふるまいを定義する
    - `getRepos()` ではイニシャライザ引数で受け取った値をそのまま返す

- では、モックを使って実際にテストを書いていきましょう
- Viewに反映されるデータは `ReposStore.state` です、テストメソッドでもこの値を監視して想定通りに更新されていることを確認します

```swift
class ReposStoreTests: XCTestCase {
    func test_onAppear_正常系() async {
        let store = ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: { [.mock1, .mock2] }
            )
        )

        await store.send(.onAppear)

        switch store.state {
        case let .loaded(repos):
            XCTAssertEqual(repos, [.mock1, .mock2])
        default:
            XCTFail()
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
func test_onAppear_異常系() async {
    let store = ReposStore(
        repoAPIClient: MockRepoAPIClient(
            getRepos: { throw DummyError() }
        )
    )

    await store.send(.onAppear)

    switch store.state {
    case let .failed(error):
        XCTAssert(error is DummyError)
    default:
        XCTFail()
    }
}
```

テストが通ることが確認できれば完了です

</details>

### 前セッションとのDiff
[session-3.1..session-3.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.1..session-3.2)

## Next
[3.3. Xcode Previewsの再活用](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.3/README.md)
