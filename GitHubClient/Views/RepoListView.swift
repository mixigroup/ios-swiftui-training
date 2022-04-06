import SwiftUI

class ReposLoader: ObservableObject {
    @MainActor @Published private(set) var repos = [Repo]()

    func call() async {
        try! await Task.sleep(nanoseconds: 1_000_000_000)

        await MainActor.run {
            repos = [.mock1, .mock2, .mock3, .mock4, .mock5]
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
        .onAppear {
            Task {
                await reposLoader.call()
            }
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
