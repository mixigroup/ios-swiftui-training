import SwiftUI
import Observation

@Observable
class ReposStore {
    private(set) var repos = [Repo]()

    func loadRepos() async {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github+json"
        ]
        // GitHub API のリクエスト数制限(60回/h)回避のためのキャッシュ設定
        urlRequest.cachePolicy = .returnCacheDataElseLoad

        let (data, _) = try! await URLSession.shared.data(for: urlRequest)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        repos = try! decoder.decode([Repo].self, from: data)
    }
}

struct RepoListView: View {
    @State var reposStore = ReposStore()

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
    RepoListView()
}
