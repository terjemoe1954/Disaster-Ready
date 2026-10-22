import Foundation

enum PreparednessSupplyGroup: String, CaseIterable, Identifiable, Sendable {
    case water
    case food
    case warmthAndLight
    case healthAndHygiene
    case informationAndContact

    var id: String { rawValue }

    static func group(for categoryKey: String) -> PreparednessSupplyGroup {
        if categoryKey.hasSuffix(".water") { return .water }
        if categoryKey.hasSuffix(".food") { return .food }
        if categoryKey.hasSuffix(".warmth") || categoryKey.hasSuffix(".light") || categoryKey.hasSuffix(".power") {
            return .warmthAndLight
        }
        if categoryKey.hasSuffix(".health") || categoryKey.hasSuffix(".hygiene") {
            return .healthAndHygiene
        }
        return .informationAndContact
    }
}

struct SupplyCoverageItem: Identifiable, Equatable, Sendable {
    let recommendation: SupplyRecommendation
    let group: PreparednessSupplyGroup
    let isRecorded: Bool

    var id: String { recommendation.id }
    var recommendedCount: Int { 1 }
    var recordedCount: Int { isRecorded ? 1 : 0 }
    var missingCount: Int { max(0, recommendedCount - recordedCount) }
}

struct SupplyCoverageSummary: Equatable, Sendable {
    let items: [SupplyCoverageItem]

    var recommendedCount: Int { items.reduce(0) { $0 + $1.recommendedCount } }
    var recordedCount: Int { items.reduce(0) { $0 + $1.recordedCount } }
    var missingCount: Int { max(0, recommendedCount - recordedCount) }
    var missingItems: [SupplyCoverageItem] { items.filter { $0.missingCount > 0 } }

    func items(in group: PreparednessSupplyGroup) -> [SupplyCoverageItem] {
        items.filter { $0.group == group }
    }
}

enum SupplyCoverageCalculator {
    static func summary(
        recommendations: [SupplyRecommendation],
        savedSupplies: [SupplyItem],
        language: AppLanguage
    ) -> SupplyCoverageSummary {
        var seenIDs = Set<String>()
        let items = recommendations.compactMap { recommendation -> SupplyCoverageItem? in
            guard seenIDs.insert(recommendation.id).inserted else { return nil }
            let isRecorded = SupplyOwnershipMatcher.appearsRecorded(
                recommendationName: recommendation.localizedName(in: language),
                in: savedSupplies
            )
            return SupplyCoverageItem(
                recommendation: recommendation,
                group: .group(for: recommendation.categoryKey),
                isRecorded: isRecorded
            )
        }
        return SupplyCoverageSummary(items: items)
    }
}

enum ShoppingListSelectionStore {
    static let storageKey = "shoppingListSelection.v1"

    static func load(defaults: UserDefaults = .standard) -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    static func save(_ selection: Set<String>, defaults: UserDefaults = .standard) {
        defaults.set(selection.sorted(), forKey: storageKey)
    }
}
