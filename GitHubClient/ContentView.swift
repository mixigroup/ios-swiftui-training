import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Image(.gitHubMark)
                .resizable()
                .frame(
                    width: 44.0,
                    height: 44.0
                )
            VStack(alignment: .leading) {
                Text("Owner Name")
                    .font(.caption)
                Text("Repository Name")
                    .font(.body)
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    ContentView()
}
