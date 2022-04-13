import XCTest
@testable import GitHubClient
import Combine

@MainActor
class RepoListViewModelTests: XCTestCase {
    func test_onAppear_正常系() async {
        let viewModel = RepoListViewModel(
            repoRepository: MockRepoRepository(
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

    func test_onAppear_異常系() async {
        let viewModel = RepoListViewModel(
            repoRepository: MockRepoRepository(
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
}
