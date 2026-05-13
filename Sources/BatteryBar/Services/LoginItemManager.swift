import Foundation
import ServiceManagement

enum LoginItemManager {
    static func enableLaunchAtLogin() {
        let service = SMAppService.mainApp

        switch service.status {
        case .enabled:
            return
        case .requiresApproval:
            NSLog("BatteryBar launch at login requires approval in System Settings.")
        case .notRegistered, .notFound:
            do {
                try service.register()
            } catch {
                NSLog("BatteryBar failed to register launch at login: \(error.localizedDescription)")
            }
        @unknown default:
            NSLog("BatteryBar encountered an unknown login item status.")
        }
    }
}
