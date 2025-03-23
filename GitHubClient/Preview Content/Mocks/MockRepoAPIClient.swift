import Foundation

struct MockRepoAPIClient: RepositoryHandling {
    var getRepos: () async throws -> [Repo]

    func getRepos() async throws -> [Repo] {
        try await getRepos()
    }
}
