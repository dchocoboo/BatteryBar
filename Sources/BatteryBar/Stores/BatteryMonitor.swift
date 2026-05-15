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
        recordCurrentSample()

        sampleTimer?.invalidate()
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordCurrentSample()
            }
        }
        sampleTimer?.tolerance = 20
    }

    func stop() {
        sampleTimer?.invalidate()
        sampleTimer = nil
        stopLiveMetrics()
    }

    func startLiveMetrics() {
        refreshStatus()
        refreshMetrics()

        metricsTimer?.invalidate()
        metricsTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshMetrics()
            }
        }
        metricsTimer?.tolerance = 0.5
    }

    func stopLiveMetrics() {
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
