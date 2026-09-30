import Foundation

struct HouseholdProfile: Codable, Equatable {
    var countryCode: String
    var municipality: String?
    var householdSize: Int
    var hasChildren: Bool
    var hasPets: Bool
    var hasElectricHeating: Bool
    var hasWoodStove: Bool
    var hasGasInstallation: Bool
    var hasAlternativeHeating: Bool
    var hasCar: Bool
    var hasEV: Bool
    var hasSpecialAssistanceNeeds: Bool
    var knowsWaterStopcock: Bool
    var knowsMainElectricalPanel: Bool

    init(
        countryCode: String,
        municipality: String? = nil,
        householdSize: Int,
        hasChildren: Bool = false,
        hasPets: Bool = false,
        hasElectricHeating: Bool = false,
        hasWoodStove: Bool = false,
        hasGasInstallation: Bool = false,
        hasAlternativeHeating: Bool = false,
        hasCar: Bool = false,
        hasEV: Bool = false,
        hasSpecialAssistanceNeeds: Bool = false,
        knowsWaterStopcock: Bool = false,
        knowsMainElectricalPanel: Bool = false
    ) {
        self.countryCode = countryCode.uppercased()
        self.municipality = municipality
        self.householdSize = max(1, householdSize)
        self.hasChildren = hasChildren
        self.hasPets = hasPets
        self.hasElectricHeating = hasElectricHeating
        self.hasWoodStove = hasWoodStove
        self.hasGasInstallation = hasGasInstallation
        self.hasAlternativeHeating = hasAlternativeHeating
        self.hasCar = hasCar
        self.hasEV = hasEV
        self.hasSpecialAssistanceNeeds = hasSpecialAssistanceNeeds
        self.knowsWaterStopcock = knowsWaterStopcock
        self.knowsMainElectricalPanel = knowsMainElectricalPanel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)?.uppercased() ?? "NO"
        municipality = try container.decodeIfPresent(String.self, forKey: .municipality)
        householdSize = max(1, try container.decodeIfPresent(Int.self, forKey: .householdSize) ?? 1)
        hasChildren = try container.decodeIfPresent(Bool.self, forKey: .hasChildren) ?? false
        hasPets = try container.decodeIfPresent(Bool.self, forKey: .hasPets) ?? false
        hasElectricHeating = try container.decodeIfPresent(Bool.self, forKey: .hasElectricHeating) ?? false
        hasWoodStove = try container.decodeIfPresent(Bool.self, forKey: .hasWoodStove) ?? false
        hasGasInstallation = try container.decodeIfPresent(Bool.self, forKey: .hasGasInstallation) ?? false
        hasAlternativeHeating = try container.decodeIfPresent(Bool.self, forKey: .hasAlternativeHeating) ?? false
        hasCar = try container.decodeIfPresent(Bool.self, forKey: .hasCar) ?? false
        hasEV = try container.decodeIfPresent(Bool.self, forKey: .hasEV) ?? false
        hasSpecialAssistanceNeeds = try container.decodeIfPresent(Bool.self, forKey: .hasSpecialAssistanceNeeds) ?? false
        knowsWaterStopcock = try container.decodeIfPresent(Bool.self, forKey: .knowsWaterStopcock) ?? false
        knowsMainElectricalPanel = try container.decodeIfPresent(Bool.self, forKey: .knowsMainElectricalPanel) ?? false
    }

    var allowsGasSpecificGuidance: Bool {
        hasGasInstallation
    }

    static func defaultProfile(locale: Locale, householdSize: Int) -> HouseholdProfile {
        HouseholdProfile(
            countryCode: locale.region?.identifier ?? "NO",
            householdSize: householdSize
        )
    }
}
