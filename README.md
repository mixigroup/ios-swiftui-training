## 3.2. XCTest
- MVVMのアーキテクチャを導入したことによるメリットとして、各モジュールをテストしやすくなったという点があります
- せっかくなので、 `RepoListViewModel` のテストを書いてみましょう
- テストしたい項目は以下の通りです
    - Viewが表示されたとき(onAppear時)にリポジトリ一覧を取得して表示する
    - 取得中はloading状態をViewに表示する
    - 取得時にエラーが発生した場合にはエラー状態をViewに表示する
- iOSでテストを書くために、まずはTest Targetを下図のように追加してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115539731-49d0fa00-a2d8-11eb-85a0-87ec3b6548c0.png">

- `GitHubClientTests.swift` というテストファイルがすでに追加されているはずです、 `RepoListViewModelTests` という名前にrenameしましょう
- `setUpWithError` と `tearDownWithError` は各テストの開始, 終了時にそれぞれ呼ばれます
- `test` から始まるメソッドがテストケースとして認識されて実行されます
- とりあえずは `setUpWithError` 以外のメソッドは消してしまい、「正しくリポジトリ一覧が読み込まれること」をテストするメソッドを追加しましょう

```swift
@testable import GitHubClient

class RepoListViewModelTests: XCTestCase {

    override func setUpWithError() throws {
    }

    func test_onAppear_正常系() {
    }
}
```

- テストターゲットからメインターゲットのメソッドやクラスを参照するために `@testable import GitHubClient` を宣言しています
    - 本来ならばpublicで修飾されていなければ外部ターゲットのフィールドにはアクセスできませんが、 `@testable import` によってinternalなフィールドにもアクセス可能になります
- まずは、テストメソッド内でテスト対象の `RepoListViewModel` を初期化してください
- 次に、 `onAppear` を呼び出してリポジトリが読み込まれるか確認...とその前に、このままだとテストを走らせるたびにAPI通信が走ってしまいます
- 常套手段として、 `RepoListViewModel` の依存している `RepoRepository` をモックに差し替えましょう
- そのためには、以下の二つのことをしてあげる必要があります
    - 現在メソッド内で初期化されている `RepoRepository` を外から渡す (Dependency Injection)
    - `RepoRepository` のI/Fを抽象化したprotocolをイニシャライザ引数とする

```swift
protocol RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error>
}

struct RepoDataRepository: RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        RepoAPIClient().getRepos()
    }
}

class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

    private var cancellables = Set<AnyCancellable>()

    private let repoRepository: RepoRepository

    init(repoRepository: RepoRepository = RepoDataRepository()) {
        self.repoRepository = repoRepository
    }
    ...
    private func loadRepos() {
        repoRepository.fetchRepos()
        ...
}
```

- これで `RepoRepository` をモックに差し替える準備が整いました、早速モックを作ってみましょう

```swift
class RepoListViewModelTests: XCTestCase {

    override func setUpWithError() throws {
    }

    func test_onAppear_正常系() {
        let viewModel = RepoListViewModel(
            repoRepository: MockRepoRepository(
                repos: [.mock1, .mock2]
            )
        )
    }
    
    struct MockRepoRepository: RepoRepository {
        let repos: [Repo]

        init(repos: [Repo]) {
            self.repos = repos
        }

        func fetchRepos() -> AnyPublisher<[Repo], Error> {
            Just(repos)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
```

- モックはこんな感じになります
    - イニシャライザ引数で返り値となる `Array<Repo>` を受け取る
    - `fetchRepos` では [Just](https://developer.apple.com/documentation/combine/just) のPublisherを使ってイニシャライザ引数で受け取った値を返す

- ここから「正しくリポジトリ一覧が読み込まれること」をテストするためには少し工夫が必要になります
- Viewに反映されるデータは `RepoListViewModel.repos` です、テストメソッドでもこの値を監視して想定通りに更新されていることを確認します
- 先に正解を示すと以下のような書き方になります

```swift
private var cancellables = Set<AnyCancellable>()

override func setUpWithError() throws {
    cancellables = .init()
}
    
func test_onAppear_正常系() {
    let expectedToBeLoading = expectation(description: "読み込み中のステータスになること")
    let expectedToBeLoaded = expectation(description: "期待通りリポジトリが読み込まれること")

    let viewModel = RepoListViewModel(
        repoRepository: MockRepoRepository(
            repos: [.mock1, .mock2]
        )
    )
    viewModel.$repos.sink { result in
        switch result {
        case .loading: expectedToBeLoading.fulfill()
        case let .loaded(repos):
            if repos.count == 2 &&
                repos.map({ $0.id }) == [Repo.mock1.id, Repo.mock2.id] {
                expectedToBeLoaded.fulfill()
            } else {
                XCTFail("Unexpected: \(result)")
            }
        default: break
        }
    }.store(in: &cancellables)

    viewModel.onAppear()

    wait(
        for: [expectedToBeLoading, expectedToBeLoaded],
        timeout: 2.0,
        enforceOrder: true
    )
}
```

- 順番に見ていきましょう
- `viewModel.$repos.sink`
    - `$repos` によって @Published でannotateされて生成されたPublisherにアクセスすることができます
    - それをSinkでsubscribeして値の変更を監視しておいて、`viewModel.onAppear()` を実行することでViewが表示されたことをエミュレートします
- [expectation(description:)](https://developer.apple.com/documentation/xctest/xctestcase/1500899-expectation)
    - 非同期に実行される処理をテストする際に用います
    - Sinkに流れてくるデータが期待するものであった場合に対応する `expectation` に対して [fulfill()](https://developer.apple.com/documentation/xctest/xctestexpectation/1501027-fulfill) を呼んであげます
- [wait(for:timeout:enforceOrder:)](https://developer.apple.com/documentation/xctest/xctestcase/2806857-wait)
    - timeoutまでに各 `expectation` に `fulfill` が実行されればテスト成功となります
    - `enforceOrder` にtrueを渡すと `expectation` の順番通りにfulfillが実行されたかどうかも見てくれます

- `⌘ + U` でテストが通ることを確認しましょう
- 以上がViewModelのテストの書き方です
- (ちょっと複雑でしたね、、非同期ではないテストの書き方はもっと簡単で直感的なのですが。。。)

### チャレンジ
- 異常系のテストを書いてみましょう
- 適当なエラーは以下のように定義することが可能です

```swift
struct DummyError: Error {}
let dummyError = DummyError()
```

<details>
    <summary>解説</summary>

異常系のテストを書けるようにするために、まずはモックでエラーを表現できるようにMockRepositoryを修正します <br>
イニシャライザ引数でErrorをOptionalで受け取れるようにしておき、もしnilでなければそのErrorを [Fail](https://developer.apple.com/documentation/combine/fail) というPublisherで返すようにします

```swift
struct DummyError: Error {}

struct MockRepoRepository: RepoRepository {
    let repos: [Repo]
    let error: Error?

    init(repos: [Repo], error: Error? = nil) {
        self.repos = repos
        self.error = error
    }

    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        if let error = error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return Just(repos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
```

あとは正常系のテストと同じ要領でテストを書いていきます

```swift
func test_onAppear_異常系() {
    let expectedToBeLoading = expectation(description: "読み込み中のステータスになること")
    let expectedToBeFailed = expectation(description: "エラー状態になること")

    let viewModel = RepoListViewModel(
        repoRepository: MockRepoRepository(
            repos: [],
            error: DummyError()
        )
    )
    viewModel.$repos.sink { result in
        switch result {
        case .loading: expectedToBeLoading.fulfill()
        case let .failed(error):
            if error is DummyError {
                expectedToBeFailed.fulfill()
            } else {
                XCTFail("Unexpected: \(result)")
            }
        default: break
        }
    }.store(in: &cancellables)

    viewModel.onAppear()

    wait(
        for: [expectedToBeLoading, expectedToBeFailed],
        timeout: 2.0,
        enforceOrder: true
    )
}
```

テストが通ることが確認できれば完了です
</details>

### 前セッションとのDiff
[session-3.1..session-3.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.1..session-3.2)

## Next
[3.3. Xcode Previewsの再活用](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.3)
