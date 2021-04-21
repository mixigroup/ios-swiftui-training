import Foundation
import Combine

struct MockRepoRepository: RepoRepository {
    let repos: [Repo]
    let error: Error?

    init(repos: [Repo], error: Error? = nil) {
        self.repos = repos
        self.error = error
    }

    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        if let error = error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return Just(repos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
