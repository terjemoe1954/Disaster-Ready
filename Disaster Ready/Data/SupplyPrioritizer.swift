import Foundation

enum SupplyPrioritizer {
    static func prioritizedSupplies(
        for emergency: EmergencyType,
        household: HouseholdProfile
    ) -> [TemplateSupplyItem] {
        var items = baseHomeSupplies
        items.append(contentsOf: NorwayEmergencyTemplates.template(for: emergency).supplyPriorities)

        if household.hasPets {
            items.append(petHomeSupplies)
        }
        if household.hasChildren {
            items.append(childHomeSupplies)
        }
        if household.hasWoodStove {
            items.append(woodStoveFuel)
        }
        if household.hasGasInstallation {
            items.append(gasInstallationSupplies)
        }

        return unique(items)
    }

    static func prioritizedEvacuationSupplies(
        for emergency: EmergencyType,
        household: HouseholdProfile
    ) -> [TemplateSupplyItem] {
        var items = NorwayEmergencyTemplates.template(for: emergency).evacuationItems

        if household.hasChildren {
            items.append(childEvacuationSupplies)
        }
        if household.hasPets {
            items.append(petEvacuationSupplies)
        }
        if household.hasSpecialAssistanceNeeds {
            items.append(assistanceInformation)
        }
        if household.hasEV {
            items.append(evChargingPlan)
        }

        return unique(items)
    }

    private static func unique(_ items: [TemplateSupplyItem]) -> [TemplateSupplyItem] {
        var seenIDs = Set<String>()
        return items.filter { seenIDs.insert(canonicalID(for: $0.id)).inserted }
    }

    private static func canonicalID(for id: String) -> String {
        switch id {
        case "batteryLighting":
            return "lighting"
        case "warmClothing":
            return "warmth"
        case "hygieneSupplies":
            return "hygiene"
        default:
            return id
        }
    }

    private static func item(
        _ id: String,
        category: String
    ) -> TemplateSupplyItem {
        TemplateSupplyItem(
            id: id,
            nameKey: "supply.\(id)",
            categoryKey: "supply_category.\(category)"
        )
    }

    private static let baseHomeSupplies = [
        item("water", category: "water"),
        item("shelfStableFood", category: "food"),
        item("cookingMethod", category: "food"),
        item("warmth", category: "warmth"),
        item("lighting", category: "light"),
        item("radio", category: "communication"),
        item("batteries", category: "power"),
        item("powerBank", category: "power"),
        item("medicines", category: "health"),
        item("firstAid", category: "health"),
        item("hygiene", category: "hygiene"),
        item("paymentPreparedness", category: "payment")
    ]

    private static let petHomeSupplies = item("petHomeSupplies", category: "pets")
    private static let childHomeSupplies = item("childHomeSupplies", category: "children")
    private static let woodStoveFuel = item("woodStoveFuel", category: "warmth")
    private static let gasInstallationSupplies = item("gasInstallationSupplies", category: "home")
    private static let childEvacuationSupplies = item("childEvacuationSupplies", category: "children")
    private static let petEvacuationSupplies = item("petEvacuationSupplies", category: "pets")
    private static let assistanceInformation = item("assistanceInformation", category: "health")
    private static let evChargingPlan = item("evChargingPlan", category: "transport")
}

func prioritizedSupplies(
    for emergency: EmergencyType,
    household: HouseholdProfile
) -> [TemplateSupplyItem] {
    SupplyPrioritizer.prioritizedSupplies(
        for: emergency,
        household: household
    )
}
