import SwiftUI

struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel

    init(repoRepository: RepoRepository) {
        _viewModel = StateObject(wrappedValue: RepoListViewModel(repoRepository: repoRepository))
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("loading...")
                case .loaded([]):
                    Text("No repositories")
                        .fontWeight(.bold)
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
        Group {
            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: [
                        .mock1, .mock2, .mock3, .mock4, .mock5
                    ]
                )
            )
            .previewDisplayName("Default")

            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: []
                )
            )
            .previewDisplayName("Empty")

            RepoListView(
                repoRepository: MockRepoRepository(
                    repos: [],
                    error: DummyError()
                )
            )
            .previewDisplayName("Error")
        }
    }
}
