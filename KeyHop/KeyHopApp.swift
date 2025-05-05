import SwiftUI
import SwiftData

@main
struct KeyHopApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            KeybindingsData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        HotkeyManager.shared.setModelContainer(sharedModelContainer)
        HotkeyManager.shared.start()
    }

    var body: some Scene {
        MenuBarExtra("KeyHop", systemImage: "command") {
            ContentView()
                .frame(width: 400, height: 600)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(sharedModelContainer)
    }
}
