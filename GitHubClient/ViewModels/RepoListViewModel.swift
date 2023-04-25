import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    @Published private(set) var state: Stateful<[Repo]> = .loading

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
        state = .loading

        do {
            let value = try await repoRepository.fetchRepos()
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}
