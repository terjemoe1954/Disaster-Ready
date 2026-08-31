//
//  LocalizationSupport.swift
//  Disaster Ready
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case norwegian = "nb"
    case thai = "th"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .norwegian:
            return "Norsk"
        case .thai:
            return "ไทย"
        }
    }

    var shortLabel: String {
        switch self {
        case .english:
            return "EN"
        case .norwegian:
            return "NO"
        case .thai:
            return "TH"
        }
    }

    static var current: AppLanguage {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        switch code {
        case "nb", "nn", "no":
            return .norwegian
        case "th":
            return .thai
        default:
            return .english
        }
    }

    static func locale(for language: AppLanguage) -> Locale {
        Locale(identifier: language.rawValue)
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .system:
            return L10n.pick(language: language, english: "System", norwegian: "System", thai: "ระบบ")
        case .light:
            return L10n.pick(language: language, english: "Light", norwegian: "Lys", thai: "สว่าง")
        case .dark:
            return L10n.pick(language: language, english: "Dark", norwegian: "Mørk", thai: "มืด")
        }
    }
}

enum L10n {
    static func text(_ key: String, language: AppLanguage) -> String {
        bundle(for: language).localizedString(forKey: key, value: key, table: nil)
    }

    static func format(_ key: String, language: AppLanguage, _ arguments: CVarArg...) -> String {
        let format = text(key, language: language)
        return String(format: format, locale: locale(for: language), arguments: arguments)
    }

    static func pick(
        language: AppLanguage,
        english: String,
        norwegian: String,
        thai: String
    ) -> String {
        switch language {
        case .english:
            return english
        case .norwegian:
            return norwegian
        case .thai:
            return thai
        }
    }

    private static func locale(for language: AppLanguage) -> Locale {
        Locale(identifier: language.rawValue)
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }
}
