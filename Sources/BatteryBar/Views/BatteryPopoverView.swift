import SwiftUI

struct BatteryPopoverView: View {
    @ObservedObject var monitor: BatteryMonitor

    @State private var selectedRange: BatteryHistoryRange = .oneHour
    @State private var hoveredBucket: BatteryHistoryBucket?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            topControls

            BatteryHistoryChart(
                samples: monitor.samples,
                range: selectedRange,
                hoveredBucket: $hoveredBucket
            )
                .frame(height: 124)
        }
        .padding(18)
        .frame(width: 380, height: 202)
        .onChange(of: selectedRange) { _ in
            hoveredBucket = nil
        }
    }

    private var topControls: some View {
        HStack(alignment: .center, spacing: 10) {
            Picker("History range", selection: $selectedRange) {
                ForEach(BatteryHistoryRange.allCases) { range in
                    Text(range.title)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 232)

            Spacer()

            hoverDetail
                .frame(width: 92, alignment: .trailing)
        }
        .frame(height: 32)
    }

    @ViewBuilder
    private var hoverDetail: some View {
        if let sample = hoveredBucket?.sample {
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(sample.percentage)%")
                    .font(.headline.monospacedDigit())

                Text(BatteryDateFormatters.time.string(from: sample.timestamp))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.14), value: sample.id)
        } else {
            Color.clear
        }
    }
}
