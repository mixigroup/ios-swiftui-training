import Testing
@testable import GitHubClient

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

    @Test func onAppear_異常系() async {
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
            #expect(error is DummyError)
        default:
            Issue.record("state should be `.failed`")
        }
    }

    struct MockRepoAPIClient: RepositoryHandling {
        var getRepos: () async throws -> [Repo]

        func getRepos() async throws -> [Repo] {
            try await getRepos()
        }
    }

    struct DummyError: Error {}
}
