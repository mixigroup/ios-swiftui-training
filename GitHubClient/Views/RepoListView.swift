import SwiftUI
import Combine

class ReposLoader: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

    private var cancellables = Set<AnyCancellable>()

    func call() {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.v3+json"
        ]

        let reposPublisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Repo].self, decoder: JSONDecoder())

        reposPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                    self?.repos = .failed(error)
                case .finished: print("Finished")
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            }
            ).store(in: &cancellables)
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
                                reposLoader.call()
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
        .onAppear {
            reposLoader.call()
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
