import Foundation
import Combine

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
        do {
            await MainActor.run { [weak self] in
                self?.repos = .loading
            }

            let repos = try await repoRepository.fetchRepos()

            await MainActor.run { [weak self] in
                self?.repos = .loaded(repos)
            }
        } catch let error {
            await MainActor.run { [weak self] in
                self?.repos = .failed(error)
            }
        }
    }
}
