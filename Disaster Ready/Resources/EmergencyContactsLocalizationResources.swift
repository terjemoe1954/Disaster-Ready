import Foundation

enum EmergencyContactsLocalizationResources {
    static let values: [LocalizedStringResource] = [
        LocalizedStringResource("official_contacts.title", defaultValue: "Official emergency numbers", comment: "Heading for bundled country-specific official emergency numbers"),
        LocalizedStringResource("official_contacts.subtitle", defaultValue: "Bundled official numbers for the selected country. Available offline.", comment: "Explains that official contact data is bundled and offline"),
        LocalizedStringResource("official_contacts.emergency_heading", defaultValue: "Emergency", comment: "Heading for services intended for emergencies"),
        LocalizedStringResource("official_contacts.other_heading", defaultValue: "Other important official numbers", comment: "Heading for useful official services that are distinct from emergency numbers"),
        LocalizedStringResource("official_contacts.unsupported", defaultValue: "Official country-specific emergency numbers have not yet been added for this country. Your contacts remain available below.", comment: "Safe state for countries without reviewed official numbers"),
        LocalizedStringResource("official_contacts.service.fire", defaultValue: "Fire and rescue", comment: "Official emergency service name for Norway 110"),
        LocalizedStringResource("official_contacts.service.police", defaultValue: "Police emergency", comment: "Official emergency service name for Norway 112"),
        LocalizedStringResource("official_contacts.service.medical_emergency", defaultValue: "Medical emergency", comment: "Official emergency service name for Norway 113"),
        LocalizedStringResource("official_contacts.service.legevakt", defaultValue: "Out-of-hours medical service", comment: "Norwegian legevakt service, distinct from medical emergency 113"),
        LocalizedStringResource("official_contacts.description.fire", defaultValue: "For fire, accidents or other acute rescue situations.", comment: "Factual purpose of Norway 110 based on DSB"),
        LocalizedStringResource("official_contacts.description.police", defaultValue: "For urgent help from the police.", comment: "Factual purpose of Norway 112 based on Politiet"),
        LocalizedStringResource("official_contacts.description.medical_emergency", defaultValue: "For accidents, serious illness or other situations where life may be at risk.", comment: "Factual purpose of Norway 113 based on Helsenorge"),
        LocalizedStringResource("official_contacts.description.legevakt", defaultValue: "When your regular doctor is unavailable and medical help cannot wait. Not the medical emergency number.", comment: "Factual purpose of Norway 116 117 and explicit distinction from 113"),
        LocalizedStringResource("official_contacts.call", defaultValue: "Call %@", comment: "Button label; placeholder is the visible official phone number"),
        LocalizedStringResource("official_contacts.confirm_title", defaultValue: "Call %@?", comment: "Confirmation title; placeholder is the visible phone number"),
        LocalizedStringResource("official_contacts.confirm_message", defaultValue: "Disaster Ready will hand this number to the Phone app. Connection is not guaranteed.", comment: "Explains tel handoff without promising connection"),
        LocalizedStringResource("official_contacts.confirm_call", defaultValue: "Continue to Phone", comment: "Confirmation action before opening the tel URL"),
        LocalizedStringResource("official_contacts.cancel", defaultValue: "Cancel", comment: "Cancels an official-number call handoff"),
        LocalizedStringResource("official_contacts.source", defaultValue: "Official source", comment: "Link label for the authority source"),
        LocalizedStringResource("official_contacts.my_contacts", defaultValue: "My contacts", comment: "Heading separating user-created contacts from bundled official contacts"),
        LocalizedStringResource("official_contacts.myplan_notice", defaultValue: "Official contact information for this plan. This is static reference information, not an instruction to call.", comment: "Safety wording for official numbers shown in My Plan"),
        LocalizedStringResource("official_contacts.accessibility_call", defaultValue: "%1$@, %2$@. Call action.", comment: "VoiceOver label; service name then phone number")
    ]

    static func text(_ key: String, language: AppLanguage) -> String {
        if language == .english {
            return englishValues[key] ?? key
        }
        return L10n.text(key, language: language)
    }

    static func format(_ key: String, language: AppLanguage, _ arguments: CVarArg...) -> String {
        let format = text(key, language: language)
        return String(format: format, locale: AppLanguage.locale(for: language), arguments: arguments)
    }

    static func englishValue(for key: String) -> String? {
        englishValues[key]
    }

    private static let englishValues: [String: String] = [
        "official_contacts.title": "Official emergency numbers",
        "official_contacts.subtitle": "Bundled official numbers for the selected country. Available offline.",
        "official_contacts.emergency_heading": "Emergency",
        "official_contacts.other_heading": "Other important official numbers",
        "official_contacts.unsupported": "Official country-specific emergency numbers have not yet been added for this country. Your contacts remain available below.",
        "official_contacts.service.fire": "Fire and rescue",
        "official_contacts.service.police": "Police emergency",
        "official_contacts.service.medical_emergency": "Medical emergency",
        "official_contacts.service.legevakt": "Out-of-hours medical service",
        "official_contacts.description.fire": "For fire, accidents or other acute rescue situations.",
        "official_contacts.description.police": "For urgent help from the police.",
        "official_contacts.description.medical_emergency": "For accidents, serious illness or other situations where life may be at risk.",
        "official_contacts.description.legevakt": "When your regular doctor is unavailable and medical help cannot wait. Not the medical emergency number.",
        "official_contacts.call": "Call %@",
        "official_contacts.confirm_title": "Call %@?",
        "official_contacts.confirm_message": "Disaster Ready will hand this number to the Phone app. Connection is not guaranteed.",
        "official_contacts.confirm_call": "Continue to Phone",
        "official_contacts.cancel": "Cancel",
        "official_contacts.source": "Official source",
        "official_contacts.my_contacts": "My contacts",
        "official_contacts.myplan_notice": "Official contact information for this plan. This is static reference information, not an instruction to call.",
        "official_contacts.accessibility_call": "%1$@, %2$@. Call action."
    ]
}
