import Foundation

enum OfficialAlertMessageType: String, Codable, Sendable {
    case alert = "Alert"
    case update = "Update"
    case cancel = "Cancel"
}

enum OfficialAlertSeverity: String, Codable, Sendable {
    case yellow = "Yellow"
    case orange = "Orange"
    case red = "Red"
    case unknown = "Unknown"
}

struct OfficialAlert: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let event: String
    let area: String
    let alertDescription: String
    let instruction: String
    let consequences: String
    let severity: OfficialAlertSeverity
    let messageType: OfficialAlertMessageType
    let status: String
    let startsAt: Date
    let expiresAt: Date
    let webURL: URL?
    let sourceID: String

    func isActive(at date: Date = .now) -> Bool {
        status.caseInsensitiveCompare("Actual") == .orderedSame
            && messageType != .cancel
            && startsAt <= date
            && expiresAt > date
    }
}

protocol WeatherAlertService: Sendable {
    func activeAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert]
}

struct WeatherAlertSnapshot: Sendable {
    let alerts: [OfficialAlert]
    let lastUpdated: Date
    let isCached: Bool
}
