import Foundation
import SwiftData

@Model
final class KeybindingsData {
    var applicationPath: String
    @Attribute(.transformable(by: NSStringArrayTransformer.self)) var modifies: [String]
    var key: String
    var order: Int = 0

    init(applicationPath: String, modifies: [String], key: String) {
        self.applicationPath = applicationPath
        self.modifies = modifies
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

    var formattedKeybinding: String {
        let modifiersText = modifies.map { $0.capitalized }.joined(separator: "-")
        return modifies.isEmpty ? key.capitalized : "\(modifiersText)-\(key.capitalized)"
    }
}
