import Foundation

class RepoListViewModel: ObservableObject {
    @MainActor @Published private(set) var repos: Stateful<[Repo]> = .idle

    func onAppear() async {
        await loadRepos()
    }

    func onRetryButtonTapped() async {
        await loadRepos()
    }

    private func loadRepos() async {
        await MainActor.run {
            repos = .loading
        }

        do {
            let value = try await RepoRepository().fetchRepos()

            await MainActor.run {
                repos = .loaded(value)
            }
        } catch {
            await MainActor.run {
                repos = .failed(error)
            }
        }
    }
}
