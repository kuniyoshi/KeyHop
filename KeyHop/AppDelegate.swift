import SwiftUI
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "hare.fill",
                accessibilityDescription: Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            )
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Edit…", action: #selector(showWindow), keyEquivalent: "e"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem?.menu = menu
        }
    }

    @objc
    private func toggleWindow() {
        if let window = window, window.isVisible {
            window.orderOut(nil) // すでに表示中なら隠す
            return
        }

        if window == nil {
            let contentView = ContentView()
                .environment(\.modelContext, KeyHopApp.sharedModelContainer.mainContext)
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 520),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            newWindow.isReleasedWhenClosed = false
            newWindow.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
            newWindow.contentView = NSHostingView(rootView: contentView)
            window = newWindow
        }

        window!.center()
        window!.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func showWindow() {
        toggleWindow()
    }

    @objc
    private func quitApp() {
        NSApp.terminate(nil)
    }
}
