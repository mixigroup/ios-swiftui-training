import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    @Published private(set) var state: Stateful<[Repo]> = .idle

    func onAppear() async {
        await loadRepos()
    }

    func onRetryButtonTapped() async {
        await loadRepos()
    }

    private func loadRepos() async {
        state = .loading

        do {
            let value = try await RepoRepository().fetchRepos()
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}
