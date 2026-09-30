import Foundation

protocol EmergencyTemplateProviding {
    var countryCode: String { get }

    func template(
        for type: EmergencyType,
        household: HouseholdProfile
    ) -> EmergencyPlanTemplate
}

struct NorwayEmergencyTemplateProvider: EmergencyTemplateProviding {
    let countryCode = "NO"

    func template(
        for type: EmergencyType,
        household: HouseholdProfile
    ) -> EmergencyPlanTemplate {
        NorwayEmergencyTemplates.template(for: type, household: household)
    }
}

enum EmergencyTemplateCatalog {
    static func provider(for countryCode: String) -> (any EmergencyTemplateProviding)? {
        switch countryCode.uppercased() {
        case "NO":
            return NorwayEmergencyTemplateProvider()
        default:
            return nil
        }
    }
}
