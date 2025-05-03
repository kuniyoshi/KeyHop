import Foundation
import SwiftData

@Model
final class KeybindingsData {
    var applicationPath: String
    var keybindings: String
    
    init(applicationPath: String, keybindings: String) {
        self.applicationPath = applicationPath
        self.keybindings = keybindings
    }
}
