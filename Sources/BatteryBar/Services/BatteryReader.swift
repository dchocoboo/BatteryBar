import Foundation
import IOKit.ps

protocol BatteryReading {
    func readStatus() -> BatteryStatus
}

struct IOKitBatteryReader: BatteryReading {
    func readStatus() -> BatteryStatus {
        guard
            let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef]
        else {
            return .unavailable
        }

        for source in sources {
            guard
                let description = IOPSGetPowerSourceDescription(snapshot, source)?
                    .takeUnretainedValue() as? [String: Any],
                let current = intValue(description[kIOPSCurrentCapacityKey as String]),
                let maximum = intValue(description[kIOPSMaxCapacityKey as String]),
                maximum > 0
            else {
                continue
            }

            let percentage = min(100, max(0, Int(round(Double(current) / Double(maximum) * 100))))
            let powerState = description[kIOPSPowerSourceStateKey as String] as? String
            let charging = boolValue(description[kIOPSIsChargingKey as String])

            return BatteryStatus(
                percentage: percentage,
                isCharging: charging,
                isPluggedIn: powerState == (kIOPSACPowerValue as String),
                updatedAt: Date()
            )
        }

        return .unavailable
    }

    private func intValue(_ value: Any?) -> Int? {
        if let int = value as? Int {
            return int
        }

        if let number = value as? NSNumber {
            return number.intValue
        }

        return nil
    }

    private func boolValue(_ value: Any?) -> Bool {
        if let bool = value as? Bool {
            return bool
        }

        if let number = value as? NSNumber {
            return number.boolValue
        }

        return false
    }
}
