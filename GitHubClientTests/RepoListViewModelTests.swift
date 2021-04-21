import XCTest
@testable import GitHubClient
import Combine

class RepoListViewModelTests: XCTestCase {

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

    struct DummyError: Error {}
}
