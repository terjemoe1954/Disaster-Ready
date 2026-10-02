import Foundation

enum EmergencyService: String, Codable, Equatable, Sendable {
    case fire
    case police
    case medicalEmergency
    case outOfHoursMedical
}

enum OfficialNumberClassification: String, Codable, Equatable, Sendable {
    case emergency
    case nonEmergencyMedicalAdvice
}

struct OfficialEmergencyNumber: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let number: String
    let service: EmergencyService
    let classification: OfficialNumberClassification
    let titleKey: String
    let descriptionKey: String
    let sourceID: String

    var dialString: String {
        number.filter(\.isNumber)
    }
}

struct CountryEmergencyConfiguration: Equatable, Sendable {
    let countryCode: String
    let emergencyNumbers: [OfficialEmergencyNumber]
}

enum CountryEmergencyConfigurationCatalog {
    static let norway = CountryEmergencyConfiguration(
        countryCode: "NO",
        emergencyNumbers: [
            OfficialEmergencyNumber(
                id: "no.emergency.fire.110",
                number: "110",
                service: .fire,
                classification: .emergency,
                titleKey: "official_contacts.service.fire",
                descriptionKey: "official_contacts.description.fire",
                sourceID: "no-emergency-fire-110"
            ),
            OfficialEmergencyNumber(
                id: "no.emergency.police.112",
                number: "112",
                service: .police,
                classification: .emergency,
                titleKey: "official_contacts.service.police",
                descriptionKey: "official_contacts.description.police",
                sourceID: "no-emergency-police-112"
            ),
            OfficialEmergencyNumber(
                id: "no.emergency.medical.113",
                number: "113",
                service: .medicalEmergency,
                classification: .emergency,
                titleKey: "official_contacts.service.medical_emergency",
                descriptionKey: "official_contacts.description.medical_emergency",
                sourceID: "no-medical-numbers"
            ),
            OfficialEmergencyNumber(
                id: "no.important.legevakt.116117",
                number: "116 117",
                service: .outOfHoursMedical,
                classification: .nonEmergencyMedicalAdvice,
                titleKey: "official_contacts.service.legevakt",
                descriptionKey: "official_contacts.description.legevakt",
                sourceID: "no-medical-numbers"
            )
        ]
    )

    static func configuration(for countryCode: String) -> CountryEmergencyConfiguration? {
        countryCode.uppercased() == norway.countryCode ? norway : nil
    }

    static func numbers(for countryCode: String) -> [OfficialEmergencyNumber] {
        configuration(for: countryCode)?.emergencyNumbers ?? []
    }

    static func numbersRelevantToPlan(
        _ emergencyType: EmergencyType,
        countryCode: String
    ) -> [OfficialEmergencyNumber] {
        guard countryCode.uppercased() == norway.countryCode else { return [] }

        switch emergencyType {
        case .houseFire:
            return norway.emergencyNumbers.filter { $0.service == .fire }
        default:
            return []
        }
    }
}

enum EmergencyCallHandoff {
    static func url(for number: OfficialEmergencyNumber) -> URL? {
        URL(string: "tel:\(number.dialString)")
    }

    static let requiresExplicitUserAction = true
    static let automaticallyPlacesCalls = false
}

enum EmergencyContactPrivacyPolicy {
    static let requiresContactsFrameworkAccess = false
    static let uploadsUserContacts = false
    static let requiresNetworkForOfficialNumbers = false
}
