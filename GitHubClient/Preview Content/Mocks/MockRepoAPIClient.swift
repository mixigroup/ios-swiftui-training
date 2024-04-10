import Foundation

struct MockRepoAPIClient: RepoAPIClientProtocol {
    var getRepos: () async throws -> [Repo]

    func getRepos() async throws -> [Repo] {
        try await getRepos()
    }
}
