import Foundation
import Carbon
import Cocoa

let keyCodeAnsiT: UInt32 = 0x11 // T key
let optionCmdModifiers: UInt32 = (1 << 19) | (1 << 20) // Option (Alt) + Command

class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isActive = false

    static let shared = HotkeyManager()

    private init() {}

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
        let modifiers = event.flags.rawValue & 0xFFFF0000

        if keyCode == keyCodeAnsiT && modifiers == optionCmdModifiers {
            print("Hotkey detected: Opt-Command-T")

            DispatchQueue.main.async {
                let kittyAppPath = "/Applications/kitty.app"
                NSWorkspace.shared.open(URL(fileURLWithPath: kittyAppPath))
            }

            return nil
        }

        return Unmanaged.passRetained(event)
    }
}
