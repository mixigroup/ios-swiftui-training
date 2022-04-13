import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

    func onAppear() async {
        await loadRepos()
    }

    func onRetryButtonTapped() async {
        await loadRepos()
    }

    private func loadRepos() async {
        repos = .loading

        do {
            let value = try await RepoRepository().fetchRepos()
            repos = .loaded(value)
        } catch {
            repos = .failed(error)
        }
    }
}
