import Foundation

enum SupplyRecommendationPriority: Int, Codable, CaseIterable, Comparable {
    case critical
    case high
    case normal

    static func < (
        lhs: SupplyRecommendationPriority,
        rhs: SupplyRecommendationPriority
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var localizationKey: String {
        "smart_supply.priority.\(String(describing: self))"
    }
}

enum SmartSupplyListKind: String, Codable {
    case homePreparedness
    case grabEvacuation
}

struct SupplyRecommendation: Codable, Equatable, Identifiable {
    let id: String
    let nameKey: String
    let categoryKey: String
    let priority: SupplyRecommendationPriority
    let listKind: SmartSupplyListKind
}

struct SmartSupplyPlan: Equatable {
    let emergencyType: EmergencyType
    let home: [SupplyRecommendation]
    let grab: [SupplyRecommendation]
    let safetyNoticeKey: String
}

enum SupplyOwnershipMatcher {
    static func appearsRecorded(
        recommendationName: String,
        in savedSupplies: [SupplyItem]
    ) -> Bool {
        let expected = normalized(recommendationName)
        guard !expected.isEmpty else { return false }

        return savedSupplies.contains { supply in
            normalized(supply.name) == expected
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
