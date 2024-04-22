import Observation

@Observable
final class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    private(set) var state: Stateful<[Repo]> = .loading

    func send(_ action: Action) async {
        switch action {
        case .onAppear, .onRetryButtonTapped:
            state = .loading

            do {
                let value = try await RepoAPIClient().getRepos()
                state = .loaded(value)
            } catch {
                state = .failed(error)
            }
        }
    }
}
