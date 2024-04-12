import SwiftUI

struct RepoListView: View {
    @State private var mockRepos: [Repo] = []

    var body: some View {
        NavigationStack {
            if mockRepos.isEmpty {
                ProgressView("loading...")
            } else {
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
        .onAppear {
            loadRepos()
        }
    }

    private func loadRepos() {
        // 1秒後にモックデータを読み込む
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            mockRepos = [
                .mock1, .mock2, .mock3, .mock4, .mock5
            ]
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
