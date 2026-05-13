import Foundation

final class BatterySampleStore {
    private let fileURL: URL
    private let retentionInterval: TimeInterval
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        fileURL: URL? = nil,
        retentionInterval: TimeInterval = 24 * 60 * 60
    ) {
        self.fileURL = fileURL ?? Self.defaultFileURL
        self.retentionInterval = retentionInterval
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load(now: Date = Date()) -> [BatterySample] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }

        guard let samples = try? decoder.decode([BatterySample].self, from: data) else {
            return []
        }

        return pruned(samples, now: now)
    }

    func append(percentage: Int, at timestamp: Date = Date()) -> [BatterySample] {
        let sample = BatterySample(timestamp: timestamp, percentage: min(100, max(0, percentage)))
        let samples = pruned(load(now: timestamp) + [sample], now: timestamp)
        save(samples)
        return samples
    }

    func save(_ samples: [BatterySample]) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(samples)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            NSLog("BatteryBar failed to save samples: \(error.localizedDescription)")
        }
    }

    private func pruned(_ samples: [BatterySample], now: Date) -> [BatterySample] {
        let cutoff = now.addingTimeInterval(-retentionInterval)
        return samples
            .filter { $0.timestamp >= cutoff && $0.timestamp <= now.addingTimeInterval(5) }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private static var defaultFileURL: URL {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.codex.BatteryBar"
        return FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(bundleID, isDirectory: true)
            .appendingPathComponent("battery-samples.json")
    }
}
