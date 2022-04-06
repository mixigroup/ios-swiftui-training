import Foundation

struct RepoRepository {
    func fetchRepos() async throws -> [Repo] {
        try await RepoAPIClient().getRepos()
    }
}
