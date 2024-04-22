import Observation

@Observable
final class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    private(set) var state: Stateful<[Repo]> = .loading

    private let repoAPIClient: RepoAPIClientProtocol

    init(repoAPIClient: RepoAPIClientProtocol = RepoAPIClient()) {
        self.repoAPIClient = repoAPIClient
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear, .onRetryButtonTapped:
            state = .loading

            do {
                let repos = try await repoAPIClient.getRepos()
                state = .loaded(repos)
            } catch {
                state = .failed(error)
            }
        }
    }
}
