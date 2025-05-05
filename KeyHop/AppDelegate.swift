import SwiftUI
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "KeyHop")
            button.action = #selector(toggleWindow)
            button.target = self
        }
    }

    @objc
    private func toggleWindow() {
        if let window = window, window.isVisible {
            window.orderOut(nil)                 // すでに表示中なら隠す
            return
        }

        if window == nil {
            let contentView = ContentView()
                .environment(\.modelContext, KeyHopApp.sharedModelContainer.mainContext)
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 520),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window!.isReleasedWhenClosed = false
            window!.title = "KeyHop"
            window!.contentView = NSHostingView(rootView: contentView)
        }

        window!.center()
        window!.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
