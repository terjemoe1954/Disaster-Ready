import Foundation

enum SupplyPrioritizer {
    static func recommendations(
        for emergency: EmergencyType,
        household: HouseholdProfile
    ) -> SmartSupplyPlan {
        var home = baseHomeRecommendations
        var grab = baseGrabRecommendations

        applyEventRules(emergency, home: &home, grab: &grab)
        applyHouseholdRules(household, emergency: emergency, home: &home, grab: &grab)

        return SmartSupplyPlan(
            emergencyType: emergency,
            home: sortedUnique(home),
            grab: sortedUnique(grab),
            safetyNoticeKey: safetyNoticeKey(for: emergency)
        )
    }

    // Compatibility API retained for existing callers and tests.
    static func prioritizedSupplies(
        for emergency: EmergencyType,
        household: HouseholdProfile
    ) -> [TemplateSupplyItem] {
        recommendations(for: emergency, household: household).home.map(\.templateItem)
    }

    // Compatibility API retained for existing callers and tests.
    static func prioritizedEvacuationSupplies(
        for emergency: EmergencyType,
        household: HouseholdProfile
    ) -> [TemplateSupplyItem] {
        recommendations(for: emergency, household: household).grab.map(\.templateItem)
    }

    private static func applyEventRules(
        _ emergency: EmergencyType,
        home: inout [SupplyRecommendation],
        grab: inout [SupplyRecommendation]
    ) {
        switch emergency {
        case .powerOutage:
            prioritize(["lighting", "batteries", "radio", "powerBank", "cookingMethod"], as: .critical, in: &home)
            prioritize(["warmth", "shelfStableFood", "water"], as: .high, in: &home)
            prioritize(["phone", "chargerPowerBank"], as: .critical, in: &grab)
        case .flood:
            prioritize(["documentCopies", "medicines", "phone", "chargerPowerBank", "drinkingWater", "grabFood", "warmClothing"], as: .critical, in: &grab)
            prioritize(["identification", "bankCards", "cash"], as: .high, in: &grab)
        case .extremeWeather:
            prioritize(["warmth", "lighting", "radio", "batteries", "powerBank", "water", "shelfStableFood"], as: .critical, in: &home)
            prioritize(["warmClothing", "phone", "chargerPowerBank"], as: .high, in: &grab)
        case .landslide, .wildfire:
            prioritize(["identification", "medicines", "phone", "chargerPowerBank", "documentCopies", "warmClothing"], as: .critical, in: &grab)
            prioritize(["drinkingWater", "grabFood", "bankCards", "cash"], as: .high, in: &grab)
        case .houseFire:
            // The list is only for advance planning. Runtime safety wording explicitly
            // tells people to leave immediately and never delay to collect belongings.
            prioritize(["identification", "medicines", "phone"], as: .high, in: &grab)
        case .waterOutage:
            prioritize(["water", "hygiene"], as: .critical, in: &home)
            prioritize(["drinkingWater"], as: .high, in: &grab)
        case .evacuation:
            prioritize(["identification", "medicines", "phone", "chargerPowerBank", "drinkingWater", "grabFood", "warmClothing", "bankCards", "cash"], as: .critical, in: &grab)
            prioritize(["documentCopies", "assistiveDevices"], as: .high, in: &grab)
        case .hazardousRelease:
            prioritize(["radio", "phone", "chargerPowerBank", "medicines"], as: .critical, in: &grab)
            prioritize(["radio", "powerBank"], as: .high, in: &home)
        case .warOrSecurityIncident:
            prioritize(["radio", "water", "shelfStableFood", "medicines", "powerBank"], as: .high, in: &home)
            prioritize(["identification", "medicines", "phone", "chargerPowerBank"], as: .high, in: &grab)
        }
    }

    private static func applyHouseholdRules(
        _ household: HouseholdProfile,
        emergency: EmergencyType,
        home: inout [SupplyRecommendation],
        grab: inout [SupplyRecommendation]
    ) {
        if household.hasPets {
            home.append(item("petHomeSupplies", category: "pets", priority: .high, kind: .homePreparedness))
            grab.append(item("petEvacuationSupplies", category: "pets", priority: .high, kind: .grabEvacuation))
        }
        if household.hasChildren {
            home.append(item("childHomeSupplies", category: "children", priority: .high, kind: .homePreparedness))
            grab.append(item("childEvacuationSupplies", category: "children", priority: .high, kind: .grabEvacuation))
        }
        if household.hasSpecialAssistanceNeeds {
            home.append(item("essentialSupportSupplies", category: "health", priority: .critical, kind: .homePreparedness))
            grab.append(item("assistanceInformation", category: "health", priority: .critical, kind: .grabEvacuation))
            prioritize(["assistiveDevices", "medicines"], as: .critical, in: &grab)
        }
        if household.hasWoodStove {
            home.append(item("woodStoveFuel", category: "warmth", priority: emergency == .powerOutage ? .critical : .normal, kind: .homePreparedness))
        }
        if household.hasAlternativeHeating {
            home.append(item("alternativeHeatingPreparedness", category: "warmth", priority: [.powerOutage, .extremeWeather].contains(emergency) ? .critical : .normal, kind: .homePreparedness))
        }
        if household.hasElectricHeating, emergency == .powerOutage {
            prioritize(["warmth"], as: .critical, in: &home)
        }
        if household.hasEV {
            grab.append(item("evChargingPlan", category: "transport", priority: [.flood, .evacuation, .wildfire, .landslide].contains(emergency) ? .high : .normal, kind: .grabEvacuation))
        }
        if household.countryCode == "NO",
           household.hasGasInstallation,
           [.powerOutage, .flood, .extremeWeather, .houseFire, .evacuation, .hazardousRelease].contains(emergency) {
            home.append(item("gasInstallationSupplies", category: "home", priority: .high, kind: .homePreparedness))
        }
    }

    private static func prioritize(
        _ ids: Set<String>,
        as priority: SupplyRecommendationPriority,
        in recommendations: inout [SupplyRecommendation]
    ) {
        recommendations = recommendations.map { recommendation in
            guard ids.contains(recommendation.id) else { return recommendation }
            return SupplyRecommendation(
                id: recommendation.id,
                nameKey: recommendation.nameKey,
                categoryKey: recommendation.categoryKey,
                priority: min(recommendation.priority, priority),
                listKind: recommendation.listKind
            )
        }
    }

    private static func sortedUnique(
        _ recommendations: [SupplyRecommendation]
    ) -> [SupplyRecommendation] {
        var bestByID: [String: SupplyRecommendation] = [:]
        for recommendation in recommendations {
            if let existing = bestByID[recommendation.id], existing.priority <= recommendation.priority {
                continue
            }
            bestByID[recommendation.id] = recommendation
        }

        return bestByID.values.sorted { first, second in
            if first.priority != second.priority {
                return first.priority < second.priority
            }
            return first.id < second.id
        }
    }

    private static func safetyNoticeKey(for emergency: EmergencyType) -> String {
        switch emergency {
        case .houseFire:
            return "smart_supply.safety.house_fire"
        case .warOrSecurityIncident:
            return "smart_supply.safety.authority_first"
        default:
            return "smart_supply.safety.general"
        }
    }

    private static func item(
        _ id: String,
        category: String,
        priority: SupplyRecommendationPriority,
        kind: SmartSupplyListKind
    ) -> SupplyRecommendation {
        SupplyRecommendation(
            id: id,
            nameKey: "supply.\(id)",
            categoryKey: "supply_category.\(category)",
            priority: priority,
            listKind: kind
        )
    }

    private static let baseHomeRecommendations: [SupplyRecommendation] = [
        item("water", category: "water", priority: .high, kind: .homePreparedness),
        item("shelfStableFood", category: "food", priority: .high, kind: .homePreparedness),
        item("cookingMethod", category: "food", priority: .normal, kind: .homePreparedness),
        item("warmth", category: "warmth", priority: .high, kind: .homePreparedness),
        item("lighting", category: "light", priority: .high, kind: .homePreparedness),
        item("radio", category: "communication", priority: .high, kind: .homePreparedness),
        item("batteries", category: "power", priority: .normal, kind: .homePreparedness),
        item("powerBank", category: "power", priority: .high, kind: .homePreparedness),
        item("medicines", category: "health", priority: .critical, kind: .homePreparedness),
        item("firstAid", category: "health", priority: .high, kind: .homePreparedness),
        item("hygiene", category: "hygiene", priority: .normal, kind: .homePreparedness),
        item("paymentPreparedness", category: "payment", priority: .normal, kind: .homePreparedness)
    ]

    private static let baseGrabRecommendations: [SupplyRecommendation] = [
        item("identification", category: "documents", priority: .critical, kind: .grabEvacuation),
        item("medicines", category: "health", priority: .critical, kind: .grabEvacuation),
        item("assistiveDevices", category: "health", priority: .high, kind: .grabEvacuation),
        item("phone", category: "communication", priority: .critical, kind: .grabEvacuation),
        item("chargerPowerBank", category: "communication", priority: .high, kind: .grabEvacuation),
        item("warmClothing", category: "warmth", priority: .high, kind: .grabEvacuation),
        item("grabFood", category: "food", priority: .high, kind: .grabEvacuation),
        item("drinkingWater", category: "water", priority: .critical, kind: .grabEvacuation),
        item("bankCards", category: "payment", priority: .high, kind: .grabEvacuation),
        item("cash", category: "payment", priority: .normal, kind: .grabEvacuation),
        item("documentCopies", category: "documents", priority: .normal, kind: .grabEvacuation)
    ]
}

private extension SupplyRecommendation {
    var templateItem: TemplateSupplyItem {
        TemplateSupplyItem(id: id, nameKey: nameKey, categoryKey: categoryKey)
    }
}

func prioritizedSupplies(
    for emergency: EmergencyType,
    household: HouseholdProfile
) -> [TemplateSupplyItem] {
    SupplyPrioritizer.prioritizedSupplies(for: emergency, household: household)
}
