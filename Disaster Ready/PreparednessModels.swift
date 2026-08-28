//
//  PreparednessModels.swift
//  Disaster Ready
//

import SwiftData
import SwiftUI

enum SupplyLocation: String {
    case home = "Home"
    case car = "Car"
}

enum PreparednessScenario: String, CaseIterable, Identifiable {
    case earthquake
    case invasion
    case flood
    case storm
    case brownout
    case volcano

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .earthquake:
            return "waveform.path.ecg.rectangle"
        case .invasion:
            return "shield.lefthalf.filled"
        case .flood:
            return "water.waves"
        case .storm:
            return "cloud.bolt.rain.fill"
        case .brownout:
            return "bolt.slash.fill"
        case .volcano:
            return "mountain.2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .earthquake:
            return .orange
        case .invasion:
            return .red
        case .flood:
            return .teal
        case .storm:
            return .blue
        case .brownout:
            return .yellow
        case .volcano:
            return .brown
        }
    }

    func localizedName(in language: AppLanguage) -> String {
        L10n.text("scenario.\(rawValue).name", language: language)
    }

    func summary(in language: AppLanguage) -> String {
        L10n.text("scenario.\(rawValue).summary", language: language)
    }

    func recommendedAction(in language: AppLanguage) -> String {
        L10n.text("scenario.\(rawValue).action", language: language)
    }

    func goRule(in language: AppLanguage) -> String {
        L10n.text("scenario.\(rawValue).go", language: language)
    }

    func noGoRule(in language: AppLanguage) -> String {
        L10n.text("scenario.\(rawValue).no_go", language: language)
    }

    func checklist(in language: AppLanguage) -> [String] {
        [
            L10n.text("scenario.\(rawValue).checklist.1", language: language),
            L10n.text("scenario.\(rawValue).checklist.2", language: language),
            L10n.text("scenario.\(rawValue).checklist.3", language: language)
        ]
    }
}

struct HouseholdRole: Identifiable {
    let id = UUID()
    let title: String
    let person: String
    let task: String
    let systemImage: String
}

struct Drill: Identifiable {
    let id = UUID()
    let title: String
    let frequency: String
    let duration: String
}

struct OfflineResource: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct FamilyMessageTemplate: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

@Model
final class FamilyContact {
    var id: UUID
    var name: String
    var role: String
    var phoneNumber: String
    var notes: String

    init(id: UUID = UUID(), name: String, role: String, phoneNumber: String, notes: String) {
        self.id = id
        self.name = name
        self.role = role
        self.phoneNumber = phoneNumber
        self.notes = notes
    }
}

@Model
final class ImportantNumber {
    var id: UUID
    var label: String
    var phoneNumber: String
    var notes: String

    init(id: UUID = UUID(), label: String, phoneNumber: String, notes: String) {
        self.id = id
        self.label = label
        self.phoneNumber = phoneNumber
        self.notes = notes
    }
}

@Model
final class SupplyItem {
    var id: UUID
    var name: String
    var detail: String
    var isPacked: Bool
    var storageLocation: String

    init(id: UUID = UUID(), name: String, detail: String, isPacked: Bool, storageLocation: String) {
        self.id = id
        self.name = name
        self.detail = detail
        self.isPacked = isPacked
        self.storageLocation = storageLocation
    }
}

@Model
final class HouseholdPlan {
    var id: UUID
    var reunionPoint: String
    var evacuationDestination: String
    var shelterZone: String
    var gasShutoffNote: String
    var medicalLead: String
    var petLead: String
    var familyPassword: String

    init(
        id: UUID = UUID(),
        reunionPoint: String,
        evacuationDestination: String,
        shelterZone: String,
        gasShutoffNote: String,
        medicalLead: String,
        petLead: String,
        familyPassword: String
    ) {
        self.id = id
        self.reunionPoint = reunionPoint
        self.evacuationDestination = evacuationDestination
        self.shelterZone = shelterZone
        self.gasShutoffNote = gasShutoffNote
        self.medicalLead = medicalLead
        self.petLead = petLead
        self.familyPassword = familyPassword
    }
}
