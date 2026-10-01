import Foundation

struct CivilDefenceShelter: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String?
    let roomNumber: String?
    let address: String?
    let municipality: String?
    let capacity: Int?
    let latitude: Double
    let longitude: Double
    let sourceID: String
    let dataUpdatedAt: Date?

    init(
        id: String,
        name: String? = nil,
        roomNumber: String? = nil,
        address: String? = nil,
        municipality: String? = nil,
        capacity: Int? = nil,
        latitude: Double,
        longitude: Double,
        sourceID: String,
        dataUpdatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.roomNumber = roomNumber
        self.address = address
        self.municipality = municipality
        self.capacity = capacity
        self.latitude = latitude
        self.longitude = longitude
        self.sourceID = sourceID
        self.dataUpdatedAt = dataUpdatedAt
    }
}

/// Source-compatible name retained for code and cached values created during development.
typealias Shelter = CivilDefenceShelter

protocol ShelterService {
    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [CivilDefenceShelter]
}

struct ShelterSnapshot: Sendable {
    let shelters: [CivilDefenceShelter]
    let lastUpdated: Date
    let isCached: Bool
    let datasetUpdatedAt: Date?
    let origin: ShelterCoordinate?

    init(
        shelters: [CivilDefenceShelter],
        lastUpdated: Date,
        isCached: Bool,
        datasetUpdatedAt: Date? = nil,
        origin: ShelterCoordinate? = nil
    ) {
        self.shelters = shelters
        self.lastUpdated = lastUpdated
        self.isCached = isCached
        self.datasetUpdatedAt = datasetUpdatedAt
        self.origin = origin
    }
}

struct ShelterCoordinate: Equatable, Sendable {
    let latitude: Double
    let longitude: Double

    var isValid: Bool {
        (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }
}

struct ShelterDistance: Equatable, Sendable {
    let shelter: CivilDefenceShelter
    let kilometers: Double
}

enum ShelterProximity {
    static func distance(
        from origin: ShelterCoordinate,
        to shelter: CivilDefenceShelter
    ) throws -> Double {
        guard origin.isValid,
              ShelterCoordinate(latitude: shelter.latitude, longitude: shelter.longitude).isValid else {
            throw ShelterServiceError.invalidCoordinate
        }

        let earthRadius = 6_371.0
        let latitudeDelta = (shelter.latitude - origin.latitude) * .pi / 180
        let longitudeDelta = (shelter.longitude - origin.longitude) * .pi / 180
        let originLatitude = origin.latitude * .pi / 180
        let destinationLatitude = shelter.latitude * .pi / 180
        let a = sin(latitudeDelta / 2) * sin(latitudeDelta / 2)
            + cos(originLatitude) * cos(destinationLatitude)
            * sin(longitudeDelta / 2) * sin(longitudeDelta / 2)
        return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    static func sorted(
        shelters: [CivilDefenceShelter],
        from origin: ShelterCoordinate
    ) throws -> [ShelterDistance] {
        guard origin.isValid else { throw ShelterServiceError.invalidCoordinate }
        return try shelters
            .map { shelter in
                ShelterDistance(
                    shelter: shelter,
                    kilometers: try distance(from: origin, to: shelter)
                )
            }
            .sorted {
                if $0.kilometers == $1.kilometers {
                    return $0.shelter.id < $1.shelter.id
                }
                return $0.kilometers < $1.kilometers
            }
    }
}

enum ShelterSafetyPolicy {
    static let nearestMeansRecommended = false

    static func isRelevantInMyPlan(for emergencyType: EmergencyType) -> Bool {
        emergencyType == .warOrSecurityIncident
    }
}

enum ShelterRegisterSearch {
    static func results(
        matching query: String,
        in shelters: [CivilDefenceShelter],
        limit: Int = 50
    ) throws -> [CivilDefenceShelter] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !normalized.isEmpty else { throw ShelterServiceError.invalidRequest }

        return Array(shelters.filter { shelter in
            [shelter.name, shelter.address, shelter.municipality, shelter.roomNumber]
                .compactMap { $0 }
                .contains { value in
                    value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                        .contains(normalized)
                }
        }
        .sorted { ($0.address ?? $0.roomNumber ?? $0.id) < ($1.address ?? $1.roomNumber ?? $1.id) }
        .prefix(limit))
    }
}
