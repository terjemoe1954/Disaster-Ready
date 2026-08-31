//
//  BackupSupport.swift
//  Disaster Ready
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DisasterBackupPayload: Codable {
    var exportDate: Date
    var familyContacts: [FamilyContactSnapshot]
    var importantNumbers: [ImportantNumberSnapshot]
    var householdPlans: [HouseholdPlanSnapshot]
    var householdRoles: [HouseholdRoleSnapshot]
    var supplies: [SupplyItemSnapshot]

    static let empty = DisasterBackupPayload(
        exportDate: .distantPast,
        familyContacts: [],
        importantNumbers: [],
        householdPlans: [],
        householdRoles: [],
        supplies: []
    )
}

struct FamilyContactSnapshot: Codable {
    var name: String
    var role: String
    var phoneNumber: String
    var notes: String
}

struct ImportantNumberSnapshot: Codable {
    var label: String
    var phoneNumber: String
    var notes: String
}

struct HouseholdPlanSnapshot: Codable {
    var scenarioIdentifier: String?
    var reunionPoint: String
    var evacuationDestination: String
    var shelterZone: String
    var gasShutoffNote: String
    var medicalLead: String
    var petLead: String
    var familyPassword: String

}

struct HouseholdRoleSnapshot: Codable {
    var title: String
    var person: String
    var task: String
    var systemImage: String
}

struct SupplyItemSnapshot: Codable {
    var name: String
    var detail: String
    var isPacked: Bool
    var storageLocation: String

}

struct DisasterBackupDocument: Sendable {
    var payload: DisasterBackupPayload

    init(payload: DisasterBackupPayload) {
        self.payload = payload
    }
}

extension DisasterBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        payload = try decoder.decode(DisasterBackupPayload.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return FileWrapper(regularFileWithContents: data)
    }
}
