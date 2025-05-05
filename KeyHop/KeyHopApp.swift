import SwiftUI
import SwiftData
import AppKit

@main
struct KeyHopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    static var sharedModelContainer: ModelContainer = {
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
        HotkeyManager.shared.setModelContainer(Self.sharedModelContainer)
        HotkeyManager.shared.start()
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
