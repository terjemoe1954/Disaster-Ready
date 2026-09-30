import Foundation

enum EmergencyType: String, Codable, CaseIterable, Identifiable {
    case powerOutage
    case flood
    case extremeWeather
    case landslide
    case wildfire
    case houseFire
    case waterOutage
    case evacuation
    case hazardousRelease
    case warOrSecurityIncident

    var id: String { rawValue }

    /// Stable, explicit compatibility map for identifiers persisted by Disaster Ready 1.0.1.
    static let legacyIdentifierMapping: [String: EmergencyType] = [
        "brownout": .powerOutage,
        "flood": .flood,
        "storm": .extremeWeather,
        "landslide": .landslide,
        "invasion": .warOrSecurityIncident,
        // These legacy scenarios have no direct 1.1 equivalent. They remain stored
        // unchanged and are shown through the broader evacuation plan category.
        "earthquake": .evacuation,
        "volcano": .evacuation
    ]

    static func migrated(fromLegacyIdentifier identifier: String?) -> EmergencyType? {
        guard let identifier, !identifier.isEmpty else { return nil }
        return legacyIdentifierMapping[identifier] ?? EmergencyType(rawValue: identifier)
    }
}

enum EmergencyPlanMigration {
    static func missingEmergencyTypes(for identifiers: [String?]) -> [EmergencyType] {
        let assignedTypes = Set(
            identifiers.compactMap { identifier in
                EmergencyType.migrated(fromLegacyIdentifier: identifier)
            }
        )
        return EmergencyType.allCases.filter { !assignedTypes.contains($0) }
    }
}

struct PreparednessAction: Codable, Equatable, Identifiable {
    let id: String
    let titleKey: String
    let detailKey: String
}

struct ShelterGuidance: Codable, Equatable, Identifiable {
    let id: String
    let titleKey: String
    let detailKey: String
    let safetyNoticeKey: String

    /// Template guidance always describes a planning location type. It never
    /// represents an authority-designated shelter, centre, or safe address.
    var isOfficialLocation: Bool { false }
}

struct TemplateSupplyItem: Codable, Equatable, Identifiable {
    let id: String
    let nameKey: String
    let categoryKey: String
}

struct EmergencyPlanTemplate: Codable, Equatable, Identifiable {
    let id: String
    let type: EmergencyType
    let titleKey: String
    let summaryKey: String
    let actions: [PreparednessAction]
    let shelterGuidance: [ShelterGuidance]
    let supplyPriorities: [TemplateSupplyItem]
    let evacuationItems: [TemplateSupplyItem]
    let sourceIDs: [String]
}
