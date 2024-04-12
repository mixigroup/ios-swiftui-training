import SwiftUI

struct RepoListView: View {
    private let mockRepos: [Repo] = [
        .mock1, .mock2, .mock3, .mock4, .mock5
    ]

    var body: some View {
        NavigationStack {
            List(mockRepos) { repo in
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
}

#Preview {
    RepoListView()
}
