import Foundation

struct Shelter: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let roomNumber: String
    let address: String
    let capacity: Int?
    let latitude: Double
    let longitude: Double
    let sourceID: String
    let dataUpdatedAt: Date?
}

protocol ShelterService {
    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [Shelter]
}
