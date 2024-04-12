import SwiftUI
import Observation

@MainActor
@Observable
class ReposStore {
    private(set) var repos = [Repo]()

    func loadRepos() async {
        try! await Task.sleep(nanoseconds: 1_000_000_000)

        repos = [.mock1, .mock2, .mock3, .mock4, .mock5]
    }
}

struct RepoListView: View {
    @State var reposStore: ReposStore

    var body: some View {
        NavigationStack {
            if reposStore.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposStore.repos) { repo in
                    NavigationLink(value: repo) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
                .navigationDestination(for: Repo.self) { repo in
                    RepoDetailView(repo: repo)
                }
            }
        }
        .task {
            await reposStore.loadRepos()
        }
    }
}

#Preview {
    RepoListView(reposStore: ReposStore())
}
