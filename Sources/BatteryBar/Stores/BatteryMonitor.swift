import Combine
import Foundation

@MainActor
final class BatteryMonitor: ObservableObject {
    @Published private(set) var currentStatus: BatteryStatus = .unavailable
    @Published private(set) var metrics: BatteryMetrics = .unavailable
    @Published private(set) var samples: [BatterySample] = []

    var onStatusChange: ((BatteryStatus) -> Void)?

    private let reader: BatteryReading
    private let store: BatterySampleStore
    private var sampleTimer: Timer?
    private var metricsTimer: Timer?

    init(reader: BatteryReading, store: BatterySampleStore) {
        self.reader = reader
        self.store = store
    }

    func start() {
        samples = store.load()
        refreshStatus()
        refreshMetrics()
        recordCurrentSample()

        sampleTimer?.invalidate()
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordCurrentSample()
            }
        }

        metricsTimer?.invalidate()
        metricsTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshStatus()
                self?.refreshMetrics()
            }
        }
    }

    func stop() {
        sampleTimer?.invalidate()
        sampleTimer = nil
        metricsTimer?.invalidate()
        metricsTimer = nil
    }

    func refreshStatus() {
        let status = reader.readStatus()
        currentStatus = status
        onStatusChange?(status)
    }

    func refreshMetrics() {
        metrics = reader.readMetrics()
    }

    func recordCurrentSample() {
        refreshStatus()

        if let percentage = currentStatus.percentage {
            samples = store.append(percentage: percentage, at: currentStatus.updatedAt)
        } else {
            samples = store.load()
        }
    }
}
