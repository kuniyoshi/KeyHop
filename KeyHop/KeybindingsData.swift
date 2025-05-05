import Foundation
import SwiftData

@Model
final class KeybindingsData {
    var applicationPath: String
    var withOption: Bool = false
    var withCommand: Bool = false
    var withShift: Bool = false
    var withControl: Bool = false
    var key: String
    var order: Int = 0

    init(applicationPath: String, modifies: [String], key: String) {
        self.applicationPath = applicationPath
        self.withOption = modifies.contains("option")
        self.withCommand = modifies.contains("command")
        self.withShift = modifies.contains("shift")
        self.withControl = modifies.contains("control")
        self.key = key
        self.order = 0
    }

    convenience init(applicationPath: String, keybindings: String) {
        let components = keybindings.split(separator: "-")
        var modifies: [String] = []
        var key = ""

        if components.count > 1 {
            modifies = components.dropLast().map { $0.lowercased() }
            key = String(components.last!).lowercased()
        } else if components.count == 1 {
            key = String(components[0]).lowercased()
        }

        self.init(applicationPath: applicationPath, modifies: modifies, key: key)
    }

    var modifiers: [String] {
        var result: [String] = []
        if withOption { result.append("option") }
        if withCommand { result.append("command") }
        if withShift { result.append("shift") }
        if withControl { result.append("control") }
        return result
    }

    var formattedKeybinding: String {
        let modifiers = modifiers
        let modifiersText = modifiers.map { $0.capitalized }.joined(separator: "-")
        return modifiers.isEmpty ? key.capitalized : "\(modifiersText)-\(key.capitalized)"
    }
}
