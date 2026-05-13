import SwiftUI

struct BatteryPopoverView: View {
    @ObservedObject var monitor: BatteryMonitor

    @State private var selectedRange: BatteryHistoryRange = .oneHour

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Picker("History range", selection: $selectedRange) {
                ForEach(BatteryHistoryRange.allCases) { range in
                    Text(range.title)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            BatteryHistoryChart(samples: monitor.samples, range: selectedRange)
                .frame(height: 124)
        }
        .padding(18)
        .frame(width: 380, height: 278)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: monitor.currentStatus.symbolName)
                .font(.system(size: 28, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var title: String {
        guard let percentage = monitor.currentStatus.percentage else {
            return "Battery unavailable"
        }

        return "\(percentage)%"
    }

    private var subtitle: String {
        if monitor.currentStatus.isCharging {
            return "Charging"
        }

        if monitor.currentStatus.isPluggedIn {
            return "Plugged in"
        }

        return "Last hour"
    }
}
