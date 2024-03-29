import SwiftUI

struct RepoListView: View {
    @State var viewModel: RepoListViewModel

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

#Preview("Default") {
    RepoListView(
        viewModel: RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                repos: .mock,
                error: nil
            )
        )
    )
}
#Preview("Error") {
    RepoListView(
        viewModel: RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                repos: [],
                error: DummyError()
            )
        )
    )
}
