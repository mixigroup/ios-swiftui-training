import SwiftUI

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        HStack {
            Image("GitHubMark")
                .resizable()
                .frame(
                    width: 44.0,
                    height: 44.0
                )
            VStack(alignment: .leading) {
                Text(repo.owner.name)
                    .font(.caption)
                Text(repo.name)
                    .font(.body)
                    .fontWeight(.semibold)
            }
        }
    }
}
