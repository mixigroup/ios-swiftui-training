import SwiftUI
import Combine

class ReposLoader: ObservableObject {
    @MainActor @Published private(set) var repos: Stateful<[Repo]> = .idle

    func call() async {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.v3+json"
        ]

        await MainActor.run {
            repos = .loading
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let value = try JSONDecoder().decode([Repo].self, from: data)

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

struct RepoListView: View {
    @StateObject private var reposLoader = ReposLoader()

    var body: some View {
        NavigationView {
            Group {
                switch reposLoader.repos {
                case .idle, .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    if repos.isEmpty {
                        Text("No repositories")
                            .fontWeight(.bold)
                    } else {
                            List(repos) { repo in
                                NavigationLink(
                                    destination: RepoDetailView(repo: repo)) {
                                    RepoRow(repo: repo)
                                }
                            }
                    }
                case .failed:
                    VStack {
                        Group {
                            Image("GitHubMark")
                            Text("Failed to load repositories")
                                .padding(.top, 4)
                        }
                        .foregroundColor(.black)
                        .opacity(0.4)
                        Button(
                            action: {
                                Task {
                                    await reposLoader.call()
                                }
                            },
                            label: {
                                Text("Retry")
                                    .fontWeight(.bold)
                            }
                        )
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Repositories")
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
