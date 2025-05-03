//
//  KeyHopApp.swift
//  KeyHop
//
//  Created by Koji Kuniyoshi on 2025-05-01.
//

import SwiftUI
import SwiftData

@main
struct KeyHopApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            KeybindingsData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Items", systemImage: "list.bullet")
                    }
                KeybindingsDataView()
                    .tabItem {
                        Label("Keybindings", systemImage: "keyboard")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
