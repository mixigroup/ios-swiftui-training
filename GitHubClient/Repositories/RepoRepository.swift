import Foundation

protocol RepoRepository {
    func fetchRepos() async throws -> [Repo]
}

struct RepoDataRepository: RepoRepository {
    func fetchRepos() async throws -> [Repo] {
        try await RepoAPIClient().getRepos()
    }
}
