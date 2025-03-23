import SwiftUI

struct RepoListView: View {
    @State var store: ReposStore

    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(value: repo) {
                            RepoRow(repo: repo)
                        }
                    }
                case .failed:
                    VStack {
                        Text("Failed to load repositories")
                        Button(
                            action: {
                                Task {
                                    await store.send(.onRetryButtonTapped)
                                }
                            },
                            label: {
                                Text("Retry")
                            }
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Repositories")
            .navigationDestination(for: Repo.self) { repo in
                RepoDetailView(repo: repo)
            }
        }
        .task {
            await store.send(.onAppear)
        }
    }
}

#Preview("Default") {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    [.mock1, .mock2, .mock3, .mock4, .mock5]
                }
            )
        )
    )
}
#Preview("Loading") {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    try await Task.never()
                }
            )
        )
    )
}
#Preview("Error") {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    throw DummyError()
                }
            )
        )
    )
}
