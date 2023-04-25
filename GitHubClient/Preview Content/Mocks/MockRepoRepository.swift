import Foundation

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
