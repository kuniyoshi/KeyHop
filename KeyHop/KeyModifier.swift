import Foundation

enum KeyModifier: String, CaseIterable {
    case option
    case command
    case shift
    case control

    var displayName: String {
        switch self {
        case .option: return "Option"
        case .command: return "Command"
        case .shift: return "Shift"
        case .control: return "Control"
        }
    }
}
