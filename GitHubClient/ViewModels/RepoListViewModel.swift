import Observation

@MainActor
@Observable
final class RepoListViewModel {
    private(set) var state: Stateful<[Repo]> = .loading

    func onAppear() async {
        await loadRepos()
    }

    func onRetryButtonTapped() async {
        await loadRepos()
    }

    private func loadRepos() async {
        state = .loading

        do {
            let value = try await RepoAPIClient().getRepos()
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}
