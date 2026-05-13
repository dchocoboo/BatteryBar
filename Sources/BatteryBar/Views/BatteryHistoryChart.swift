import SwiftUI

struct BatteryHistoryChart: View {
    let samples: [BatterySample]
    let range: BatteryHistoryRange
    @Binding var hoveredBucket: BatteryHistoryBucket?

    private let bucketCount = 30
    private let chartHeight: CGFloat = 92

    var body: some View {
        let buckets = BatteryHistoryBuckets.make(
            samples: samples,
            bucketCount: bucketCount,
            duration: range.duration
        )

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(range.chartTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 18)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(buckets) { bucket in
                    BatteryHistoryBar(
                        bucket: bucket,
                        chartHeight: chartHeight,
                        isHovered: hoveredBucket?.id == bucket.id
                    )
                    .onHover { isHovering in
                        hoveredBucket = isHovering ? bucket : nil
                    }
                }
            }
            .frame(height: chartHeight, alignment: .bottom)

            HStack {
                Text(range.leadingAxisLabel)
                Spacer()
                Text("now")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
    }
}

private struct BatteryHistoryBar: View {
    let bucket: BatteryHistoryBucket
    let chartHeight: CGFloat
    let isHovered: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(fillStyle)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .top) {
                if isHovered, bucket.sample != nil {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(.primary.opacity(0.45), lineWidth: 1)
                }
            }
            .contentShape(Rectangle())
            .help(helpText)
    }

    private var height: CGFloat {
        guard let percentage = bucket.sample?.percentage else {
            return 8
        }

        return max(8, chartHeight * CGFloat(percentage) / 100)
    }

    private var fillStyle: AnyShapeStyle {
        guard let percentage = bucket.sample?.percentage else {
            return AnyShapeStyle(Color.secondary.opacity(0.16))
        }

        if percentage <= 20 {
            return AnyShapeStyle(Color.red.gradient)
        }

        if percentage <= 50 {
            return AnyShapeStyle(Color.orange.gradient)
        }

        return AnyShapeStyle(Color.green.gradient)
    }

    private var helpText: String {
        guard let sample = bucket.sample else {
            return "No sample"
        }

        return "\(sample.percentage)% at \(BatteryDateFormatters.time.string(from: sample.timestamp))"
    }
}
