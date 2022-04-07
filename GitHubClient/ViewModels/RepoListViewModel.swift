import Foundation

class RepoListViewModel: ObservableObject {
    @MainActor @Published private(set) var repos: Stateful<[Repo]> = .idle

    private let repoRepository: RepoRepository

    init(repoRepository: RepoRepository = RepoDataRepository()) {
        self.repoRepository = repoRepository
    }

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
            let value = try await repoRepository.fetchRepos()

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
