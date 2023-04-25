import SwiftUI

struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel

    init(repoAPIClient: RepoAPIClientProtocol) {
        _viewModel = StateObject(
            wrappedValue: RepoListViewModel(repoAPIClient: repoAPIClient)
        )
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(destination: RepoDetailView(repo: repo)) {
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
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView(
            repoAPIClient: MockRepoAPIClient(
                repos: [
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ],
                error: nil
            )
        )
        .previewDisplayName("Default")

        RepoListView(
            repoAPIClient: MockRepoAPIClient(
                repos: [],
                error: DummyError()
            )
        )
        .previewDisplayName("Error")
    }
}
