//
//  BackupSupport.swift
//  Disaster Ready
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DisasterBackupPayload: Codable, Equatable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int? = currentSchemaVersion
    var householdMemberCount: Int? = nil
    var householdProfile: HouseholdProfile? = nil
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

    func encodedData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    static func decode(from data: Data) throws -> DisasterBackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DisasterBackupPayload.self, from: data)
    }

    func validateForImport() throws {
        let importedVersion = schemaVersion ?? 1
        guard importedVersion > 0, importedVersion <= Self.currentSchemaVersion else {
            throw DisasterBackupValidationError.unsupportedSchemaVersion(importedVersion)
        }

        if let householdMemberCount, !(1...12).contains(householdMemberCount) {
            throw DisasterBackupValidationError.invalidHouseholdMemberCount
        }

        let containsData = !familyContacts.isEmpty
            || !importantNumbers.isEmpty
            || !householdPlans.isEmpty
            || !householdRoles.isEmpty
            || !supplies.isEmpty
        guard containsData else {
            throw DisasterBackupValidationError.emptyBackup
        }

        let validLocations = Set([SupplyLocation.home.rawValue, SupplyLocation.car.rawValue])
        guard supplies.allSatisfy({ validLocations.contains($0.storageLocation) }) else {
            throw DisasterBackupValidationError.invalidSupplyLocation
        }
    }
}

enum DisasterBackupValidationError: Error, Equatable {
    case emptyBackup
    case invalidSupplyLocation
    case unsupportedSchemaVersion(Int)
    case invalidHouseholdMemberCount
}

struct FamilyContactSnapshot: Codable, Equatable {
    var name: String
    var role: String
    var phoneNumber: String
    var notes: String
}

struct ImportantNumberSnapshot: Codable, Equatable {
    var label: String
    var phoneNumber: String
    var notes: String
}

struct HouseholdPlanSnapshot: Codable, Equatable {
    var scenarioIdentifier: String?
    var reunionPoint: String
    var evacuationDestination: String
    var shelterZone: String
    var gasShutoffNote: String
    var medicalLead: String
    var petLead: String
    var familyPassword: String
    var alternativeAccommodation: String? = nil
    var familyFriendLocation: String? = nil
    var secondaryHome: String? = nil
    var safePlaceNote: String? = nil
    var waterStopcockNote: String? = nil
    var mainElectricalPanelNote: String? = nil

}

struct HouseholdRoleSnapshot: Codable, Equatable {
    var title: String
    var person: String
    var task: String
    var systemImage: String
}

struct SupplyItemSnapshot: Codable, Equatable {
    var name: String
    var detail: String
    var isPacked: Bool
    var storageLocation: String
    var quantity: String?
    var reviewDate: Date?

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

        payload = try DisasterBackupPayload.decode(from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: try payload.encodedData())
    }
}
