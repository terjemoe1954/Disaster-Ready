import Foundation

enum NorwayEmergencyTemplates {
    static var all: [EmergencyPlanTemplate] {
        EmergencyType.allCases.map { emergencyType in
            template(for: emergencyType)
        }
    }

    static func template(for type: EmergencyType) -> EmergencyPlanTemplate {
        let eventKey = type.rawValue
        return EmergencyPlanTemplate(
            id: "no.\(eventKey)",
            type: type,
            titleKey: "emergency.\(eventKey).title",
            summaryKey: "emergency.\(eventKey).summary",
            actions: actions(for: type),
            shelterGuidance: shelterGuidance(for: type),
            supplyPriorities: supplyPriorities(for: type),
            evacuationItems: baseEvacuationItems,
            sourceIDs: sourceIDs(for: type)
        )
    }

    static func template(
        for type: EmergencyType,
        household: HouseholdProfile
    ) -> EmergencyPlanTemplate {
        let baseTemplate = template(for: type)
        guard
            household.countryCode == "NO",
            household.hasGasInstallation,
            gasRelevantTypes.contains(type)
        else {
            return baseTemplate
        }

        return EmergencyPlanTemplate(
            id: baseTemplate.id,
            type: baseTemplate.type,
            titleKey: baseTemplate.titleKey,
            summaryKey: baseTemplate.summaryKey,
            actions: baseTemplate.actions + [gasPreparednessAction(for: type)],
            shelterGuidance: baseTemplate.shelterGuidance,
            supplyPriorities: baseTemplate.supplyPriorities,
            evacuationItems: baseTemplate.evacuationItems,
            sourceIDs: baseTemplate.sourceIDs
        )
    }

    private static func actions(for type: EmergencyType) -> [PreparednessAction] {
        [
            PreparednessAction(
                id: "\(type.rawValue).followOfficialInformation",
                titleKey: "action.follow_official_information.title",
                detailKey: "action.follow_official_information.detail"
            ),
            PreparednessAction(
                id: "\(type.rawValue).prepareHousehold",
                titleKey: "action.\(type.rawValue).prepare.title",
                detailKey: "action.\(type.rawValue).prepare.detail"
            )
        ]
    }

    private static let gasRelevantTypes: Set<EmergencyType> = [
        .houseFire,
        .evacuation,
        .hazardousRelease
    ]

    private static func gasPreparednessAction(for type: EmergencyType) -> PreparednessAction {
        PreparednessAction(
            id: "\(type.rawValue).gasInstallationPreparedness",
            titleKey: "action.gas_installation.prepare.title",
            detailKey: "action.gas_installation.prepare.detail"
        )
    }

    private static func shelterGuidance(for type: EmergencyType) -> [ShelterGuidance] {
        let guidanceKey: String

        switch type {
        case .flood, .landslide, .wildfire:
            guidanceKey = "outside_risk_area"
        case .extremeWeather, .hazardousRelease:
            guidanceKey = "robust_indoor_location"
        case .houseFire:
            guidanceKey = "outdoor_meeting_point"
        case .evacuation:
            guidanceKey = "planned_alternative_accommodation"
        case .warOrSecurityIncident:
            guidanceKey = "follow_shelter_instructions"
        case .powerOutage, .waterOutage:
            guidanceKey = "home_or_alternative_accommodation"
        }

        return [
            ShelterGuidance(
                id: "\(type.rawValue).\(guidanceKey)",
                titleKey: "shelter.\(guidanceKey).title",
                detailKey: "shelter.\(guidanceKey).detail",
                safetyNoticeKey: "shelter.preparedness_not_official.notice"
            )
        ]
    }

    private static func supplyPriorities(for type: EmergencyType) -> [TemplateSupplyItem] {
        var items = baseHomeItems

        switch type {
        case .powerOutage:
            items.append(contentsOf: [batteryLighting, powerBank, radio])
        case .flood, .landslide, .wildfire, .evacuation:
            items.append(contentsOf: [documentCopies, warmClothing])
        case .extremeWeather:
            items.append(contentsOf: [batteryLighting, warmClothing, radio])
        case .houseFire:
            items.append(documentCopies)
        case .waterOutage:
            items.append(hygieneSupplies)
        case .hazardousRelease, .warOrSecurityIncident:
            items.append(contentsOf: [radio, hygieneSupplies])
        }

        return unique(items)
    }

    private static func sourceIDs(for type: EmergencyType) -> [String] {
        switch type {
        case .flood:
            return ["dsb-self-preparedness", "dsb-flood-preparedness", "nve-hazard-information"]
        case .landslide:
            return ["dsb-self-preparedness", "nve-hazard-information"]
        case .warOrSecurityIncident:
            return ["dsb-self-preparedness", "dsb-crisis-locations", "dsb-civil-defence-shelters"]
        case .evacuation:
            return ["dsb-self-preparedness", "dsb-crisis-locations", "dsb-evacuation"]
        default:
            return ["dsb-self-preparedness", "dsb-crisis-locations"]
        }
    }

    private static func unique(_ items: [TemplateSupplyItem]) -> [TemplateSupplyItem] {
        var seenIDs = Set<String>()
        return items.filter { seenIDs.insert($0.id).inserted }
    }

    private static let water = TemplateSupplyItem(
        id: "water",
        nameKey: "supply.water",
        categoryKey: "supply_category.water"
    )
    private static let food = TemplateSupplyItem(
        id: "shelfStableFood",
        nameKey: "supply.shelf_stable_food",
        categoryKey: "supply_category.food"
    )
    private static let medicines = TemplateSupplyItem(
        id: "medicines",
        nameKey: "supply.medicines",
        categoryKey: "supply_category.health"
    )
    private static let batteryLighting = TemplateSupplyItem(
        id: "batteryLighting",
        nameKey: "supply.battery_lighting",
        categoryKey: "supply_category.light"
    )
    private static let powerBank = TemplateSupplyItem(
        id: "powerBank",
        nameKey: "supply.power_bank",
        categoryKey: "supply_category.communication"
    )
    private static let radio = TemplateSupplyItem(
        id: "radio",
        nameKey: "supply.radio",
        categoryKey: "supply_category.communication"
    )
    private static let documentCopies = TemplateSupplyItem(
        id: "documentCopies",
        nameKey: "supply.document_copies",
        categoryKey: "supply_category.documents"
    )
    private static let warmClothing = TemplateSupplyItem(
        id: "warmClothing",
        nameKey: "supply.warm_clothing",
        categoryKey: "supply_category.warmth"
    )
    private static let hygieneSupplies = TemplateSupplyItem(
        id: "hygieneSupplies",
        nameKey: "supply.hygiene",
        categoryKey: "supply_category.hygiene"
    )

    private static let baseHomeItems = [water, food, medicines]

    private static let baseEvacuationItems = [
        TemplateSupplyItem(id: "identification", nameKey: "supply.identification", categoryKey: "supply_category.documents"),
        medicines,
        TemplateSupplyItem(id: "assistiveDevices", nameKey: "supply.assistive_devices", categoryKey: "supply_category.health"),
        TemplateSupplyItem(id: "phoneAndCharger", nameKey: "supply.phone_and_charger", categoryKey: "supply_category.communication"),
        warmClothing,
        TemplateSupplyItem(id: "foodAndDrink", nameKey: "supply.food_and_drink", categoryKey: "supply_category.food"),
        TemplateSupplyItem(id: "paymentOptions", nameKey: "supply.payment_options", categoryKey: "supply_category.payment"),
        TemplateSupplyItem(id: "documentCopies", nameKey: "supply.document_copies", categoryKey: "supply_category.documents")
    ]
}
