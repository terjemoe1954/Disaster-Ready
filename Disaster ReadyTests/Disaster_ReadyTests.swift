//
//  Disaster_ReadyTests.swift
//  Disaster ReadyTests
//
//  Created by Terje Moe on 28/08/2026.
//

import Foundation
import Testing
@testable import Disaster_Ready

@MainActor
struct Disaster_ReadyTests {

    @Test func stormScenarioRecommendsEvacuationEvaluation() async throws {
        #expect(PreparednessScenario.storm.recommendedAction(in: .english) == "Evaluate evacuation")
        #expect(PreparednessScenario.storm.goRule(in: .english).contains("road closures"))
    }

    @Test func supplyReviewStatusUsesThirtyDayWindow() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 27)))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))
        let inThirtyDays = try #require(calendar.date(byAdding: .day, value: 30, to: today))
        let inThirtyOneDays = try #require(calendar.date(byAdding: .day, value: 31, to: today))

        #expect(SupplyReviewStatus.classify(reviewDate: nil, referenceDate: today, calendar: calendar) == .none)
        #expect(SupplyReviewStatus.classify(reviewDate: yesterday, referenceDate: today, calendar: calendar) == .overdue)
        #expect(SupplyReviewStatus.classify(reviewDate: inThirtyDays, referenceDate: today, calendar: calendar) == .dueSoon)
        #expect(SupplyReviewStatus.classify(reviewDate: inThirtyOneDays, referenceDate: today, calendar: calendar) == .scheduled)
    }

    @Test func supplyReminderUsesThirtyDayLeadTime() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let referenceDate = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 12))
        )
        let reviewDate = try #require(calendar.date(byAdding: .day, value: 60, to: referenceDate))
        let expectedDay = try #require(calendar.date(byAdding: .day, value: 30, to: referenceDate))
        let expectedDelivery = try #require(
            calendar.date(bySettingHour: 9, minute: 0, second: 0, of: expectedDay)
        )

        #expect(
            SupplyReminderScheduler.deliveryDate(
                for: reviewDate,
                referenceDate: referenceDate,
                calendar: calendar
            ) == expectedDelivery
        )
    }

    @Test func supplyReminderSchedulesNearDatesOneMinuteAhead() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let referenceDate = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 12))
        )
        let today = calendar.startOfDay(for: referenceDate)
        let inTwentyDays = try #require(calendar.date(byAdding: .day, value: 20, to: today))
        let expectedDelivery = referenceDate.addingTimeInterval(60)

        #expect(
            SupplyReminderScheduler.deliveryDate(
                for: today,
                referenceDate: referenceDate,
                calendar: calendar
            ) == expectedDelivery
        )
        #expect(
            SupplyReminderScheduler.deliveryDate(
                for: inTwentyDays,
                referenceDate: referenceDate,
                calendar: calendar
            ) == expectedDelivery
        )
    }

    @Test func supplyReminderSkipsExpiredDates() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let referenceDate = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 12))
        )
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: referenceDate))

        #expect(
            SupplyReminderScheduler.deliveryDate(
                for: yesterday,
                referenceDate: referenceDate,
                calendar: calendar
            ) == nil
        )
    }

    @Test func supplyReminderIdentifiersAreStableAndUnique() throws {
        let firstID = try #require(UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"))
        let secondID = try #require(UUID(uuidString: "11111111-2222-3333-4444-555555555555"))

        #expect(SupplyReminderScheduler.reminderIdentifier(for: firstID) == "supply-review-AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
        #expect(SupplyReminderScheduler.reminderIdentifier(for: firstID) != SupplyReminderScheduler.reminderIdentifier(for: secondID))
    }

    @Test func backupPayloadRoundTripPreservesAllFields() throws {
        let exportDate = try #require(ISO8601DateFormatter().date(from: "2026-09-27T12:00:00Z"))
        let reviewDate = try #require(ISO8601DateFormatter().date(from: "2027-03-01T09:00:00Z"))
        let payload = DisasterBackupPayload(
            householdMemberCount: 4,
            exportDate: exportDate,
            familyContacts: [
                FamilyContactSnapshot(name: "Alex", role: "Medical", phoneNumber: "+47 900 00 111", notes: "Neighbor")
            ],
            importantNumbers: [
                ImportantNumberSnapshot(label: "Fire", phoneNumber: "110", notes: "Emergency")
            ],
            householdPlans: [
                HouseholdPlanSnapshot(
                    scenarioIdentifier: "storm",
                    reunionPoint: "School",
                    evacuationDestination: "Cabin",
                    shelterZone: "Basement",
                    gasShutoffNote: "Red valve",
                    medicalLead: "Alex",
                    petLead: "Jordan",
                    familyPassword: "North star"
                )
            ],
            householdRoles: [
                HouseholdRoleSnapshot(title: "Communications", person: "Sam", task: "Bring radio", systemImage: "antenna.radiowaves.left.and.right")
            ],
            supplies: [
                SupplyItemSnapshot(
                    name: "Water",
                    detail: "Store cool and dark",
                    isPacked: true,
                    storageLocation: "home",
                    quantity: "20 liters",
                    reviewDate: reviewDate
                )
            ]
        )

        let restoredPayload = try DisasterBackupPayload.decode(from: payload.encodedData())

        #expect(restoredPayload == payload)
    }

    @Test func backupValidationRejectsEmptyBackup() {
        #expect(throws: DisasterBackupValidationError.emptyBackup) {
            try DisasterBackupPayload.empty.validateForImport()
        }
    }

    @Test func backupValidationRejectsUnknownSupplyLocation() {
        let payload = DisasterBackupPayload(
            exportDate: .now,
            familyContacts: [],
            importantNumbers: [],
            householdPlans: [],
            householdRoles: [],
            supplies: [
                SupplyItemSnapshot(
                    name: "Water",
                    detail: "",
                    isPacked: false,
                    storageLocation: "cloud",
                    quantity: nil,
                    reviewDate: nil
                )
            ]
        )

        #expect(throws: DisasterBackupValidationError.invalidSupplyLocation) {
            try payload.validateForImport()
        }
    }

    @Test func backupValidationRejectsNewerSchemaVersion() {
        let payload = DisasterBackupPayload(
            schemaVersion: DisasterBackupPayload.currentSchemaVersion + 1,
            exportDate: .now,
            familyContacts: [
                FamilyContactSnapshot(name: "Alex", role: "Medical", phoneNumber: "110", notes: "")
            ],
            importantNumbers: [],
            householdPlans: [],
            householdRoles: [],
            supplies: []
        )

        #expect(throws: DisasterBackupValidationError.unsupportedSchemaVersion(2)) {
            try payload.validateForImport()
        }
    }

    @Test func backupValidationRejectsInvalidHouseholdSize() {
        let payload = DisasterBackupPayload(
            householdMemberCount: 0,
            exportDate: .now,
            familyContacts: [
                FamilyContactSnapshot(name: "Alex", role: "Medical", phoneNumber: "110", notes: "")
            ],
            importantNumbers: [],
            householdPlans: [],
            householdRoles: [],
            supplies: []
        )

        #expect(throws: DisasterBackupValidationError.invalidHouseholdMemberCount) {
            try payload.validateForImport()
        }
    }

    @Test func legacyBackupWithoutVersionOrHouseholdSizeStillImports() throws {
        let currentPayload = DisasterBackupPayload(
            householdMemberCount: 3,
            exportDate: .now,
            familyContacts: [
                FamilyContactSnapshot(name: "Alex", role: "Medical", phoneNumber: "110", notes: "")
            ],
            importantNumbers: [],
            householdPlans: [],
            householdRoles: [],
            supplies: []
        )
        let encodedData = try currentPayload.encodedData()
        var legacyObject = try #require(JSONSerialization.jsonObject(with: encodedData) as? [String: Any])
        legacyObject.removeValue(forKey: "schemaVersion")
        legacyObject.removeValue(forKey: "householdMemberCount")
        let legacyData = try JSONSerialization.data(withJSONObject: legacyObject)

        let decodedPayload = try DisasterBackupPayload.decode(from: legacyData)

        #expect(decodedPayload.schemaVersion == nil)
        #expect(decodedPayload.householdMemberCount == nil)
        #expect(throws: Never.self) {
            try decodedPayload.validateForImport()
        }
    }

    @Test func phoneLinkSanitizerSupportsFormattedAndEmergencyNumbers() {
        #expect(PhoneLinkBuilder.sanitizedNumber("+47 900 00 111") == "+4790000111")
        #expect(PhoneLinkBuilder.sanitizedNumber("(+47) 900-00-111") == nil)
        #expect(PhoneLinkBuilder.sanitizedNumber("(900) 00 111") == "90000111")
        #expect(PhoneLinkBuilder.sanitizedNumber("110") == "110")
    }

    @Test func phoneLinkSanitizerRejectsInvalidNumbers() {
        #expect(PhoneLinkBuilder.sanitizedNumber("") == nil)
        #expect(PhoneLinkBuilder.sanitizedNumber("12") == nil)
        #expect(PhoneLinkBuilder.sanitizedNumber("++47 900") == nil)
        #expect(PhoneLinkBuilder.sanitizedNumber("call 110") == nil)
    }

}
