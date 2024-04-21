import SwiftUI

@main
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            RepoListView(
                store: ReposStore(
                    repoAPIClient: RepoAPIClient()
                )
            )
        }
    }
}
