import Foundation

struct BatteryHistoryBucket: Identifiable {
    let index: Int
    let start: Date
    let end: Date
    let sample: BatterySample?

    var id: Int { index }
}

enum BatteryHistoryBuckets {
    static func make(
        samples: [BatterySample],
        now: Date = Date(),
        bucketCount: Int = 30,
        duration: TimeInterval = 60 * 60
    ) -> [BatteryHistoryBucket] {
        let bucketDuration = duration / Double(bucketCount)
        let startDate = now.addingTimeInterval(-duration)

        return (0..<bucketCount).map { index in
            let start = startDate.addingTimeInterval(Double(index) * bucketDuration)
            let end = start.addingTimeInterval(bucketDuration)
            let sample = samples
                .filter { $0.timestamp >= start && $0.timestamp < end }
                .max { $0.timestamp < $1.timestamp }

            return BatteryHistoryBucket(
                index: index,
                start: start,
                end: end,
                sample: sample
            )
        }
    }
}
