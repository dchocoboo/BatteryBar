import Foundation

struct BatteryMetrics: Equatable {
    var healthPercentage: Int?
    var chargingWatts: Double?
    var updatedAt: Date

    static let unavailable = BatteryMetrics(
        healthPercentage: nil,
        chargingWatts: nil,
        updatedAt: Date()
    )
}
