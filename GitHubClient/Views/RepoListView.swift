import SwiftUI

class ReposLoader: ObservableObject {
    @MainActor @Published private(set) var repos = [Repo]()

    func call() async {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.v3+json"
        ]

        let (data, _) = try! await URLSession.shared.data(for: urlRequest)
        let value = try! JSONDecoder().decode([Repo].self, from: data)

        await MainActor.run {
            repos = value
        }
    }
}

struct RepoListView: View {
    @StateObject private var reposLoader = ReposLoader()

    var body: some View {
        NavigationView {
            if reposLoader.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposLoader.repos) { repo in
                    NavigationLink(
                        destination: RepoDetailView(repo: repo)) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
            }
        }
        .task {
            await reposLoader.call()
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
