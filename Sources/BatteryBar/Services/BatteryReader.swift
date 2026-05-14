import Foundation
import IOKit
import IOKit.ps

protocol BatteryReading {
    func readStatus() -> BatteryStatus
    func readMetrics() -> BatteryMetrics
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

    func readMetrics() -> BatteryMetrics {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else {
            return .unavailable
        }
        defer { IOObjectRelease(service) }

        let designCapacity = registryIntValue("DesignCapacity", service: service)
        let maximumCapacity = registryIntValue("AppleRawMaxCapacity", service: service)
            ?? registryIntValue("MaxCapacity", service: service)
            ?? registryIntValue("NominalChargeCapacity", service: service)
        let voltage = registryIntValue("Voltage", service: service)
        let amperage = registryIntValue("InstantAmperage", service: service)
            ?? registryIntValue("Amperage", service: service)

        let healthPercentage = healthPercentage(
            maximumCapacity: maximumCapacity,
            designCapacity: designCapacity
        )
        let watts = chargingWatts(voltageMillivolts: voltage, amperageMilliamps: amperage)

        return BatteryMetrics(
            healthPercentage: healthPercentage,
            chargingWatts: watts,
            updatedAt: Date()
        )
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

    private func registryIntValue(_ key: String, service: io_registry_entry_t) -> Int? {
        guard
            let value = IORegistryEntryCreateCFProperty(
                service,
                key as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue()
        else {
            return nil
        }

        return intValue(value)
    }

    private func healthPercentage(maximumCapacity: Int?, designCapacity: Int?) -> Int? {
        guard
            let maximumCapacity,
            let designCapacity,
            designCapacity > 0
        else {
            return nil
        }

        let percentage = Int(round(Double(maximumCapacity) / Double(designCapacity) * 100))
        return min(100, max(0, percentage))
    }

    private func chargingWatts(voltageMillivolts: Int?, amperageMilliamps: Int?) -> Double? {
        guard
            let voltageMillivolts,
            let amperageMilliamps
        else {
            return nil
        }

        return Double(voltageMillivolts * amperageMilliamps) / 1_000_000
    }
}
