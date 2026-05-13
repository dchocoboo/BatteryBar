import Foundation
import ServiceManagement

enum LoginItemManager {
    private static let launchAtLoginPreferenceKey = "launchAtLoginEnabled"

    static var isLaunchAtLoginPreferred: Bool {
        guard UserDefaults.standard.object(forKey: launchAtLoginPreferenceKey) != nil else {
            return true
        }

        return UserDefaults.standard.bool(forKey: launchAtLoginPreferenceKey)
    }

    static func applyLaunchAtLoginPreference() {
        setLaunchAtLoginEnabled(isLaunchAtLoginPreferred, persistPreference: false)
    }

    static func setLaunchAtLoginEnabled(_ enabled: Bool) {
        setLaunchAtLoginEnabled(enabled, persistPreference: true)
    }

    private static func setLaunchAtLoginEnabled(_ enabled: Bool, persistPreference: Bool) {
        if persistPreference {
            UserDefaults.standard.set(enabled, forKey: launchAtLoginPreferenceKey)
        }

        if enabled {
            registerLaunchAtLogin()
        } else {
            unregisterLaunchAtLogin()
        }
    }

    private static func registerLaunchAtLogin() {
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

    private static func unregisterLaunchAtLogin() {
        let service = SMAppService.mainApp

        switch service.status {
        case .notRegistered, .notFound:
            return
        case .enabled, .requiresApproval:
            do {
                try service.unregister()
            } catch {
                NSLog("BatteryBar failed to unregister launch at login: \(error.localizedDescription)")
            }
        @unknown default:
            NSLog("BatteryBar encountered an unknown login item status.")
        }
    }
}
