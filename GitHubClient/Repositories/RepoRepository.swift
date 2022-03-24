import Foundation
import Combine

protocol RepoRepository {
    func fetchRepos() async throws -> [Repo]
}

struct RepoDataRepository: RepoRepository {
    func fetchRepos() async throws -> [Repo] {
        return try await RepoAPIClient().getRepos()
    }
}
