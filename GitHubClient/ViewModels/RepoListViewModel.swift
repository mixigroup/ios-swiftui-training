import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

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
        repos = .loading

        do {
            let value = try await repoRepository.fetchRepos()
            repos = .loaded(value)
        } catch {
            repos = .failed(error)
        }
    }
}
