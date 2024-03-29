import SwiftUI

struct RepoListView: View {
    @State var viewModel: RepoListViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
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
                                    await viewModel.onRetryButtonTapped()
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
            await viewModel.onAppear()
        }
    }
}

#Preview("Default") {
    RepoListView(
        viewModel: RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    .mock
                }
            )
        )
    )
}
#Preview("Loading") {
    RepoListView(
        viewModel: RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    while true {
                        try await Task.sleep(until: .now + .seconds(1))
                    }
                }
            )
        )
    )
}
#Preview("Error") {
    RepoListView(
        viewModel: RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    throw DummyError()
                }
            )
        )
    )
}
