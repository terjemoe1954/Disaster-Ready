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
    case landslide
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
        case .landslide:
            return "exclamationmark.triangle.fill"
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
        case .landslide:
            return .brown
        case .volcano:
            return .brown
        }
    }

    func localizedName(in language: AppLanguage) -> String {
        if self == .landslide {
            return L10n.pick(
                language: language,
                english: "Landslide / Mudslide",
                norwegian: "Leire / Jordskred",
                thai: "ดินถล่ม / โคลนถล่ม"
            )
        }
        return L10n.text("scenario.\(rawValue).name", language: language)
    }

    func summary(in language: AppLanguage) -> String {
        if self == .landslide {
            return L10n.pick(
                language: language,
                english: "Ground movement can cut roads, damage homes, and trap people with very little warning. Move away from steep slopes, stream channels, and areas below unstable ground.",
                norwegian: "Bevegelse i bakken kan stenge veier, skade boliger og fange mennesker med svært lite varsel. Flytt deg bort fra bratte skråninger, bekkeløp og områder under ustabil grunn.",
                thai: "การเคลื่อนตัวของดินอาจตัดถนน ทำลายบ้าน และทำให้ผู้คนติดอยู่ได้โดยแทบไม่มีสัญญาณเตือน ควรออกห่างจากพื้นที่ลาดชัน ลำธาร และบริเวณใต้ดินที่ไม่มั่นคง"
            )
        }
        return L10n.text("scenario.\(rawValue).summary", language: language)
    }

    func recommendedAction(in language: AppLanguage) -> String {
        if self == .landslide {
            return L10n.pick(
                language: language,
                english: "Evacuate early to stable ground.",
                norwegian: "Evakuer tidlig til stabil grunn.",
                thai: "อพยพแต่เนิ่น ๆ ไปยังพื้นที่มั่นคง"
            )
        }
        return L10n.text("scenario.\(rawValue).action", language: language)
    }

    func goRule(in language: AppLanguage) -> String {
        if self == .landslide {
            return L10n.pick(
                language: language,
                english: "Go if you see new cracks, leaning trees or poles, sudden muddy water, falling rocks, or official evacuation warnings.",
                norwegian: "Dra hvis du ser nye sprekker, trær eller stolper som heller, plutselig grumsete vann, fallende stein eller får offisielle evakueringsvarsler.",
                thai: "ให้ออกทันทีหากเห็นรอยแยกใหม่ ต้นไม้หรือเสาเอียง น้ำขุ่นไหลกะทันหัน หินตก หรือมีคำสั่งอพยพจากทางการ"
            )
        }
        return L10n.text("scenario.\(rawValue).go", language: language)
    }

    func noGoRule(in language: AppLanguage) -> String {
        if self == .landslide {
            return L10n.pick(
                language: language,
                english: "Do not stay in valleys, below steep hillsides, or on roads exposed to debris flow once the slope looks unstable.",
                norwegian: "Ikke bli værende i daler, under bratte skråninger eller på veier utsatt for skredmasser når skråningen virker ustabil.",
                thai: "อย่าอยู่ในหุบเขา ใต้เนินชัน หรือบนถนนที่เสี่ยงต่อมวลดินไหลเมื่อพื้นที่ลาดชันเริ่มไม่มั่นคง"
            )
        }
        return L10n.text("scenario.\(rawValue).no_go", language: language)
    }

    func checklist(in language: AppLanguage) -> [String] {
        if self == .landslide {
            return [
                L10n.pick(
                    language: language,
                    english: "Move people, pets, and vehicles away from slopes and drainage channels.",
                    norwegian: "Flytt mennesker, kjæledyr og kjøretøy bort fra skråninger og dreneringsløp.",
                    thai: "ย้ายคน สัตว์เลี้ยง และยานพาหนะออกห่างจากลาดเขาและทางระบายน้ำ"
                ),
                L10n.pick(
                    language: language,
                    english: "Watch for ground cracks, sticking doors, rumbling sounds, or tilted fences and poles.",
                    norwegian: "Se etter sprekker i bakken, dører som setter seg fast, drønnelyder eller gjerder og stolper som heller.",
                    thai: "สังเกตรอยแยกของพื้น ประตูที่เปิดปิดยาก เสียงครืน หรือรั้วและเสาที่เอียง"
                ),
                L10n.pick(
                    language: language,
                    english: "Leave before heavy rain peaks and avoid returning until the area has been cleared as safe.",
                    norwegian: "Dra før kraftig regn topper seg, og ikke dra tilbake før området er erklært trygt.",
                    thai: "ออกจากพื้นที่ก่อนฝนหนักถึงจุดสูงสุด และอย่ากลับจนกว่าพื้นที่จะได้รับการยืนยันว่าปลอดภัย"
                )
            ]
        }
        return [
            L10n.text("scenario.\(rawValue).checklist.1", language: language),
            L10n.text("scenario.\(rawValue).checklist.2", language: language),
            L10n.text("scenario.\(rawValue).checklist.3", language: language)
        ]
    }
}

@Model
final class HouseholdRole {
    var id: UUID
    var title: String
    var person: String
    var task: String
    var systemImage: String

    init(
        id: UUID = UUID(),
        title: String,
        person: String,
        task: String,
        systemImage: String
    ) {
        self.id = id
        self.title = title
        self.person = person
        self.task = task
        self.systemImage = systemImage
    }
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
    var scenarioIdentifier: String?
    var reunionPoint: String
    var evacuationDestination: String
    var shelterZone: String
    var gasShutoffNote: String
    var medicalLead: String
    var petLead: String
    var familyPassword: String

    init(
        id: UUID = UUID(),
        scenarioIdentifier: String? = nil,
        reunionPoint: String,
        evacuationDestination: String,
        shelterZone: String,
        gasShutoffNote: String,
        medicalLead: String,
        petLead: String,
        familyPassword: String
    ) {
        self.id = id
        self.scenarioIdentifier = scenarioIdentifier
        self.reunionPoint = reunionPoint
        self.evacuationDestination = evacuationDestination
        self.shelterZone = shelterZone
        self.gasShutoffNote = gasShutoffNote
        self.medicalLead = medicalLead
        self.petLead = petLead
        self.familyPassword = familyPassword
    }
}
