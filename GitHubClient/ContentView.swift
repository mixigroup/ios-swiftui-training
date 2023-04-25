import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }

            Text("Good evening, world!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
