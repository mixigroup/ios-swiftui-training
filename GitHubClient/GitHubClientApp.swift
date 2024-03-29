import SwiftUI

@main
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            RepoListView(
                viewModel: RepoListViewModel(
                    repoAPIClient: RepoAPIClient()
                )
            )
        }
    }
}
