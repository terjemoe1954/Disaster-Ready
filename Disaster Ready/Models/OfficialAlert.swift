import Foundation

nonisolated enum OfficialAlertMessageType: String, Codable, Sendable { case alert = "Alert"; case update = "Update"; case cancel = "Cancel" }
nonisolated enum OfficialAlertSeverity: String, Codable, Sendable, CaseIterable { case green = "Green"; case yellow = "Yellow"; case orange = "Orange"; case red = "Red"; case unknown = "Unknown" }

nonisolated struct AlertCoordinate: Codable, Equatable, Sendable { let longitude: Double; let latitude: Double }

nonisolated enum OfficialAlertGeometry: Codable, Equatable, Sendable {
    case polygon([[AlertCoordinate]])
    case multiPolygon([[[AlertCoordinate]]])

    func contains(latitude: Double, longitude: Double) -> Bool {
        let polygons: [[[AlertCoordinate]]]
        switch self { case .polygon(let rings): polygons = [rings]; case .multiPolygon(let value): polygons = value }
        return polygons.contains { rings in
            guard let outer = rings.first, pointInRing(latitude: latitude, longitude: longitude, ring: outer) else { return false }
            return !rings.dropFirst().contains { pointInRing(latitude: latitude, longitude: longitude, ring: $0) }
        }
    }

    private func pointInRing(latitude: Double, longitude: Double, ring: [AlertCoordinate]) -> Bool {
        guard ring.count >= 3 else { return false }
        var inside = false
        var previous = ring.count - 1
        for current in ring.indices {
            let a = ring[current], b = ring[previous]
            if ((a.latitude > latitude) != (b.latitude > latitude))
                && longitude < (b.longitude - a.longitude) * (latitude - a.latitude) / (b.latitude - a.latitude) + a.longitude { inside.toggle() }
            previous = current
        }
        return inside
    }
}

nonisolated struct OfficialAlert: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let source: String
    let event: String
    let severity: OfficialAlertSeverity
    let officialCAPSeverity: String?
    let headline: String?
    let alertDescription: String?
    let instruction: String?
    let consequences: String?
    let effectiveAt: Date?
    let onsetAt: Date?
    let expiresAt: Date?
    let sentAt: Date?
    let updatedAt: Date?
    let geographicDescription: String?
    let sourceID: String
    let messageType: OfficialAlertMessageType
    let status: String
    let referencedAlertIDs: [String]
    let geometry: OfficialAlertGeometry?
    let webURL: URL?

    func isActive(at date: Date = .now) -> Bool {
        guard status.caseInsensitiveCompare("Actual") == .orderedSame, messageType != .cancel,
              let expiresAt, expiresAt > date else { return false }
        return (effectiveAt ?? onsetAt).map { $0 <= date } ?? true
    }

    var planType: EmergencyType? {
        switch event {
        case "rainFlood", "stormSurge": .flood
        case "blowingSnow", "gale", "ice", "icing", "lightning", "polarLow", "rain", "snow", "wind": .extremeWeather
        case "forestFire": .wildfire
        default: nil
        }
    }
}

nonisolated protocol WeatherAlertService: Sendable { func activeAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert] }

nonisolated enum WeatherAlertDiagnostic: String, Codable, Sendable {
    case deprecatedProduct
    case throttled
}

nonisolated struct WeatherAlertSnapshot: Sendable {
    let alerts: [OfficialAlert]
    let fetchedAt: Date
    let isCached: Bool
    let diagnostics: Set<WeatherAlertDiagnostic>
}
