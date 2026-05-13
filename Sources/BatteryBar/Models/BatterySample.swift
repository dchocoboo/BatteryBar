import Foundation

struct BatterySample: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let percentage: Int

    init(id: UUID = UUID(), timestamp: Date, percentage: Int) {
        self.id = id
        self.timestamp = timestamp
        self.percentage = percentage
    }
}
