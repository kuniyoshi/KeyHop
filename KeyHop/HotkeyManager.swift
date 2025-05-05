import Foundation
import Carbon
import Cocoa
import SwiftData

class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isActive = false
    private var modelContainer: ModelContainer?
    private var cachedKeybindings: [KeybindingsData] = []
    private var isRefreshingCache = false

    static let shared = HotkeyManager()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeybindingsDataChange),
            name: Notification.Name("KeybindingsDataChanged"),
            object: nil
        )
    }

    @objc private func handleKeybindingsDataChange() {
        refreshKeybindingsCache()
    }

    func setModelContainer(_ container: ModelContainer) {
        self.modelContainer = container
        print("HotkeyManager: Set model container")

        refreshKeybindingsCache()
    }

    private func refreshKeybindingsCache() {
        guard !isRefreshingCache, let modelContainer = modelContainer else {
            return
        }

        isRefreshingCache = true

        Task { @MainActor in
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<KeybindingsData>()

            do {
                self.cachedKeybindings = try context.fetch(descriptor)
                print("HotkeyManager: Refreshed keybindings cache with \(self.cachedKeybindings.count) items")
            } catch {
                print("HotkeyManager: Failed to fetch keybindings: \(error)")
            }

            self.isRefreshingCache = false
        }
    }

    private func fetchKeybindings() -> [KeybindingsData] {
        return cachedKeybindings
    }

    private func keyCodeToString(_ keyCode: Int) -> String? {
        let keyMapping: [Int: String] = [
            0x00: "a",
            0x0B: "b",
            0x08: "c",
            0x02: "d",
            0x0E: "e",
            0x03: "f",
            0x05: "g",
            0x04: "h",
            0x22: "i",
            0x26: "j",
            0x28: "k",
            0x25: "l",
            0x2E: "m",
            0x2D: "n",
            0x1F: "o",
            0x23: "p",
            0x0C: "q",
            0x0F: "r",
            0x01: "s",
            0x11: "t",
            0x20: "u",
            0x09: "v",
            0x0D: "w",
            0x07: "x",
            0x10: "y",
            0x06: "z",
        ]

        return keyMapping[Int(keyCode)]
    }

    private func modifiersToStrings(_ flags: CGEventFlags) -> [String] {
        var modifiers: [String] = []

        if flags.contains(.maskCommand) {
            modifiers.append("command")
        }
        if flags.contains(.maskAlternate) {
            modifiers.append("option")
        }
        if flags.contains(.maskShift) {
            modifiers.append("shift")
        }
        if flags.contains(.maskControl) {
            modifiers.append("control")
        }

        return modifiers
    }

    deinit {
        stop()
    }

    func start() {
        if isActive { return }

        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                return HotkeyManager.eventCallback(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            return
        }

        eventTap = tap

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        CGEvent.tapEnable(tap: tap, enable: true)

        isActive = true
        print("HotkeyManager: Started global hotkey listener")
    }

    func stop() {
        guard isActive, let tap = eventTap, let source = runLoopSource else { return }

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)

        CGEvent.tapEnable(tap: tap, enable: false)

        eventTap = nil
        runLoopSource = nil
        isActive = false

        print("HotkeyManager: Stopped global hotkey listener")
    }

    private static func eventCallback(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent,
        refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout {
            print("Event tap timed out, re-enabling")
            if let tap = HotkeyManager.shared.eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passRetained(event)
        }

        if type != .keyDown {
            return Unmanaged.passRetained(event)
        }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        let modifierStrings = HotkeyManager.shared.modifiersToStrings(event.flags)

        guard let keyString = HotkeyManager.shared.keyCodeToString(Int(keyCode)) else {
            return Unmanaged.passRetained(event)
        }

        let keybindings = HotkeyManager.shared.fetchKeybindings()

        for binding in keybindings {
            if binding.key == keyString && Set(binding.modifiers) == Set(modifierStrings) {
                print("Hotkey detected: \(binding.formattedKeybinding) for \(binding.applicationPath)")

                DispatchQueue.main.async {
                    NSWorkspace.shared.open(URL(fileURLWithPath: binding.applicationPath))
                }

                return nil // Consume the event
            }
        }

        return Unmanaged.passRetained(event)
    }
}
