import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        KeybindingsDataView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: KeybindingsData.self, inMemory: true)
}
