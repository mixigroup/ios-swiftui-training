import Foundation
import Combine

protocol RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error>
}

struct RepoDataRepository: RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        RepoAPIClient().getRepos()
    }
}
