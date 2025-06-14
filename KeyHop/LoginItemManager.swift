import Foundation
import ServiceManagement

class LoginItemManager: ObservableObject {
    static let shared = LoginItemManager()

    @Published var isEnabled: Bool = false

    private init() {
        checkLoginItemStatus()
    }

    func setLoginItem(enabled: Bool) {
        Task { @MainActor in
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
                self.isEnabled = enabled
                print("LoginItemManager: Successfully \(enabled ? "enabled" : "disabled") launch at login")
            } catch {
                print("LoginItemManager: Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
                self.checkLoginItemStatus()
            }
        }
    }

    private func checkLoginItemStatus() {
        switch SMAppService.mainApp.status {
        case .enabled:
            isEnabled = true
        case .notRegistered, .notFound, .requiresApproval:
            isEnabled = false
        @unknown default:
            isEnabled = false
        }
        print("LoginItemManager: Login item status checked - enabled: \(isEnabled)")
    }
}
