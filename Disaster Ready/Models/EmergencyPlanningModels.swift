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

    static func migrated(fromLegacyIdentifier identifier: String?) -> EmergencyType? {
        guard let identifier, !identifier.isEmpty else { return nil }

        switch identifier {
        case "brownout":
            return .powerOutage
        case "flood":
            return .flood
        case "storm":
            return .extremeWeather
        case "landslide":
            return .landslide
        case "invasion":
            return .warOrSecurityIncident
        case "earthquake", "volcano":
            return .evacuation
        default:
            return EmergencyType(rawValue: identifier)
        }
    }
}

enum EmergencyPlanMigration {
    static func missingEmergencyTypes(for identifiers: [String?]) -> [EmergencyType] {
        let assignedTypes = Set(
            identifiers.compactMap(EmergencyType.migrated(fromLegacyIdentifier:))
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
