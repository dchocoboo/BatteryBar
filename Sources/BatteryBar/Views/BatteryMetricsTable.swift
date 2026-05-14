import SwiftUI

struct BatteryMetricsTable: View {
    let metrics: BatteryMetrics

    var body: some View {
        VStack(spacing: 0) {
            BatteryMetricRow(
                title: "Battery health",
                value: healthValue,
                detail: "Maximum capacity"
            )

            Divider()
                .opacity(0.45)

            BatteryMetricRow(
                title: "Charging watts",
                value: wattsValue,
                detail: "Updates every 2s"
            )
        }
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
    }

    private var healthValue: String {
        guard let healthPercentage = metrics.healthPercentage else {
            return "--"
        }

        return "\(healthPercentage)%"
    }

    private var wattsValue: String {
        guard let chargingWatts = metrics.chargingWatts else {
            return "--"
        }

        if abs(chargingWatts) < 0.05 {
            return "0.0 W"
        }

        return String(format: "%.1f W", chargingWatts)
    }
}

private struct BatteryMetricRow: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
