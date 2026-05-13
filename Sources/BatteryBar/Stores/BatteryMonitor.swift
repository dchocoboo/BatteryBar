import Combine
import Foundation

@MainActor
final class BatteryMonitor: ObservableObject {
    @Published private(set) var currentStatus: BatteryStatus = .unavailable
    @Published private(set) var samples: [BatterySample] = []

    var onStatusChange: ((BatteryStatus) -> Void)?

    private let reader: BatteryReading
    private let store: BatterySampleStore
    private var timer: Timer?

    init(reader: BatteryReading, store: BatterySampleStore) {
        self.reader = reader
        self.store = store
    }

    func start() {
        samples = store.load()
        recordCurrentStatus()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordCurrentStatus()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func recordCurrentStatus() {
        let status = reader.readStatus()
        currentStatus = status
        onStatusChange?(status)

        if let percentage = status.percentage {
            samples = store.append(percentage: percentage, at: status.updatedAt)
        } else {
            samples = store.load()
        }
    }
}
