import Foundation

struct BatteryStatus: Equatable {
    var percentage: Int?
    var isCharging: Bool
    var isPluggedIn: Bool
    var updatedAt: Date

    static let unavailable = BatteryStatus(
        percentage: nil,
        isCharging: false,
        isPluggedIn: false,
        updatedAt: Date()
    )

    var symbolName: String {
        guard let percentage else { return "battery.0percent" }

        if isCharging {
            return "battery.100percent.bolt"
        }

        switch percentage {
        case 0..<20:
            return "battery.0percent"
        case 20..<50:
            return "battery.25percent"
        case 50..<80:
            return "battery.50percent"
        default:
            return "battery.100percent"
        }
    }

    var accessibilityDescription: String {
        guard let percentage else { return "Battery unavailable" }
        return "Battery \(percentage) percent"
    }

    var tooltip: String {
        guard let percentage else { return "Battery unavailable" }

        if isCharging {
            return "Battery \(percentage)% - charging"
        }

        if isPluggedIn {
            return "Battery \(percentage)% - plugged in"
        }

        return "Battery \(percentage)%"
    }

    var menuBarTitle: String {
        guard let percentage else { return "--%" }
        return "\(percentage)%"
    }
}
