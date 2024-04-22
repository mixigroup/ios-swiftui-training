import XCTest
@testable import GitHubClient

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

    func test_onAppear_異常系() async {
        let store = ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    throw DummyError()
                }
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

    struct MockRepoAPIClient: RepoAPIClientProtocol {
        var getRepos: () async throws -> [Repo]

        func getRepos() async throws -> [Repo] {
            try await getRepos()
        }
    }

    struct DummyError: Error {}
}
