## 3.2. XCTest
- MVVMのアーキテクチャを導入したことによるメリットとして、各モジュールをテストしやすくなったという点があります
- `RepoListViewModel` のテストを書いてみましょう
- テストしたい項目は以下の通りです
    - Viewが表示されたとき(onAppear時)にリポジトリ一覧を取得して表示する
    - 取得時にエラーが発生した場合にはエラー状態をViewに表示する
- iOSでテストを書くために、まずはTest Targetを下図のように追加してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115539731-49d0fa00-a2d8-11eb-85a0-87ec3b6548c0.png">

- `GitHubClientTests.swift` というテストファイルがすでに追加されているはずなので、 `RepoListViewModelTests` にrenameしましょう
- `setUpWithError` と `tearDownWithError` は各テストの開始, 終了時にそれぞれ呼ばれます
- `test` から始まるメソッドがテストケースとして認識されて実行されます
- とりあえずは `setUpWithError`, `tearDownWithError`を消してしまい、「正しくリポジトリ一覧が読み込まれること」をテストするメソッドを追加しましょう

```swift
@testable import GitHubClient

class RepoListViewModelTests: XCTestCase {
    func test_onAppear_正常系()　async {
    }
}
```

- テストターゲットからメインターゲットのメソッドやクラスを参照するために `@testable import GitHubClient` を宣言しています
    - 本来ならばpublicで修飾されていなければ外部ターゲットのフィールドにはアクセスできませんが、 `@testable import` によってinternalなフィールドにもアクセス可能になります
- テストメソッド内で async な関数 `RepoListViewModel.onAppear()` を呼び出したいので、あらかじめテストメソッドに `async` を付与します
- まずはテストメソッド内で、テスト対象の `RepoListViewModel` を初期化し、`onAppear` を呼び出してリポジトリが読み込まれるか確認...
- と、このままだとテストを走らせるたびにAPI通信が走ってしまいます
- 常套手段として、 `RepoListViewModel` が依存している `RepoAPIClient` をモックに差し替えましょう
- そのためには、以下の二つのことをしてあげる必要があります
    - 現在メソッド内で初期化されている `RepoAPIClient` を外から渡す (Dependency Injection)
    - `RepoAPIClient` のI/Fを抽象化したprotocolをイニシャライザ引数とする

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
@MainActor
class RepoListViewModel: ObservableObject {
    @Published private(set) var state: Stateful<[Repo]> = .loading

    private let repoAPIClient: RepoAPIClientProtocol

    init(repoAPIClient: RepoAPIClientProtocol = RepoAPIClient()) {
        self.repoAPIClient = repoAPIClient
    }
    ...
    private func loadRepos() {
        ...
        do {
            let value = try await repoAPIClient.getRepos()
        ...
    }
}
```

- これで `RepoAPIClient` をモックに差し替える準備が整いました、早速モックを作ってみましょう

```swift
class RepoListViewModelTests: XCTestCase {
    ...
    
    struct MockRepoAPIClient: RepoAPIClientProtocol {
        let repos: [Repo]

        func getRepos() async throws -> [Repo] {
            repos
        }
    }
}
```

- モックはこんな感じになります
    - イニシャライザ引数で返り値となる `Array<Repo>` を受け取る
    - `getRepos` でイニシャライザ引数で受け取った値をそのまま返す

- では、モックを使って実際にテストを書いていきましょう
- Viewに反映されるデータは `RepoListViewModel.state` です、テストメソッドでもこの値を監視して想定通りに更新されていることを確認します

```swift
@MainActor
class RepoListViewModelTests: XCTestCase {
    func test_onAppear_正常系() async {
        let viewModel = RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                repos: [.mock1, .mock2]
            )
        )

        await viewModel.onAppear()

        switch viewModel.state {
        case let .loaded(repos):
            XCTAssertEqual(repos, [Repo.mock1, Repo.mock2])
        default:
            XCTFail()
        }
    }
    
    ...
}
```

<details>
    <summary>Test classに@MainActorを付与している理由(余裕があれば確認してみましょう)</summary>
    
- @MainActorを付与しない場合、RepoListViewModel初期化のところで　`Expression is 'async' but is not marked with 'await'`　というエラーが出てしまいます
- エラーの原因は、async関数内で@MainActorでマークされたクラスを初期化する際に、awaitを使用していないことです
- awaitが必要な理由は、@MainActorが付与されたRepoListViewModelの初期化はメインスレッドで実行されるため、@MainActorなしのテストメソッド内で実行されると、非同期処理になる場合があるためです
- Test classに@MainActorを付与することで、テストメソッドもメインスレッドで実行されることが保証され、RepoListViewModel初期化時のawaitを不要にしています

</details>

- 順番に見ていきましょう
- `await viewModel.onAppear()` で `onAppear()` を実行しつつその結果を待ちます
- `onAppear()` が完了すると await 以下のコードが実行され、 `viewModel.state` に対する検証が行われます
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

異常系のテストを書けるようにするために、まずはモックでエラーを表現できるようにMockRepoAPIClientを修正します <br>
イニシャライザ引数でErrorをOptionalで受け取れるようにしておき、もしnilでなければそのErrorをthrowします

```swift
struct DummyError: Error {}

struct MockRepoAPIClient: RepoAPIClientProtocol {
    let repos: [Repo]
    let error: Error?

    func getRepos() async throws -> [Repo] {
        if let error = error {
            throw error
        }

        return repos
    }
}
```

あとは正常系のテストと同じ要領でテストを書いていきます

```swift
func test_onAppear_異常系() async {
    let viewModel = RepoListViewModel(
        repoAPIClient: MockRepoAPIClient(
            repos: [],
            error: DummyError()
        )
    )

    await viewModel.onAppear()

    switch viewModel.state {
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
[3.3. Xcode Previewsの再活用](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.3)
