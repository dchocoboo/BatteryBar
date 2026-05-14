import Foundation

enum BatteryHistoryRange: String, CaseIterable, Identifiable {
    case oneHour = "1h"
    case threeHours = "3h"
    case sixHours = "6h"
    case twelveHours = "12h"
    case twentyFourHours = "24h"

    var id: String { rawValue }

    var title: String {
        rawValue
    }

    var chartTitle: String {
        switch self {
        case .oneHour:
            return "Last hour"
        case .threeHours:
            return "Last 3 hours"
        case .sixHours:
            return "Last 6 hours"
        case .twelveHours:
            return "Last 12 hours"
        case .twentyFourHours:
            return "Last 24 hours"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .oneHour:
            return 60 * 60
        case .threeHours:
            return 3 * 60 * 60
        case .sixHours:
            return 6 * 60 * 60
        case .twelveHours:
            return 12 * 60 * 60
        case .twentyFourHours:
            return 24 * 60 * 60
        }
    }

    var leadingAxisLabel: String {
        switch self {
        case .oneHour:
            return "-1h"
        case .threeHours:
            return "-3h"
        case .sixHours:
            return "-6h"
        case .twelveHours:
            return "-12h"
        case .twentyFourHours:
            return "-24h"
        }
    }
}
