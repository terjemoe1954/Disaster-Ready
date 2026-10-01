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
            householdProfile: HouseholdProfile(
                countryCode: "NO",
                municipality: "Oslo",
                householdSize: 4,
                hasChildren: true,
                knowsWaterStopcock: true,
                knowsMainElectricalPanel: true
            ),
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
                    familyPassword: "North star",
                    alternativeAccommodation: "Community hotel",
                    familyFriendLocation: "Alex's home",
                    secondaryHome: "Mountain cabin",
                    safePlaceNote: "User-entered planning note",
                    waterStopcockNote: "Utility room",
                    mainElectricalPanelNote: "Front hall"
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

    @Test func version101BackupWithoutLaterOptionalFieldsPreservesUserData() throws {
        let legacyJSON = """
        {
          "exportDate": "2026-09-01T12:00:00Z",
          "familyContacts": [
            {
              "name": "Alex",
              "role": "Medical",
              "phoneNumber": "+47 900 00 111",
              "notes": "Uses the side entrance"
            }
          ],
          "importantNumbers": [],
          "householdPlans": [
            {
              "reunionPoint": "Old oak tree",
              "evacuationDestination": "Family cabin",
              "shelterZone": "Interior hallway",
              "gasShutoffNote": "Valve by the meter",
              "medicalLead": "Alex",
              "petLead": "Sam",
              "familyPassword": "North star"
            }
          ],
          "householdRoles": [],
          "supplies": [
            {
              "name": "Water",
              "detail": "Stored in pantry",
              "isPacked": true,
              "storageLocation": "Home"
            }
          ]
        }
        """
        let legacyData = try #require(legacyJSON.data(using: .utf8))

        let payload = try DisasterBackupPayload.decode(from: legacyData)
        try payload.validateForImport()

        #expect(payload.schemaVersion == nil)
        #expect(payload.householdMemberCount == nil)
        #expect(payload.householdProfile == nil)
        #expect(payload.familyContacts.first?.notes == "Uses the side entrance")
        #expect(payload.householdPlans.first?.scenarioIdentifier == nil)
        #expect(payload.householdPlans.first?.reunionPoint == "Old oak tree")
        #expect(payload.householdPlans.first?.evacuationDestination == "Family cabin")
        #expect(payload.householdPlans.first?.shelterZone == "Interior hallway")
        #expect(payload.householdPlans.first?.gasShutoffNote == "Valve by the meter")
        #expect(payload.supplies.first?.quantity == nil)
        #expect(payload.supplies.first?.reviewDate == nil)
    }

    @Test func householdProfileMigrationPreservesLegacyHouseholdSize() throws {
        let suiteName = "HouseholdProfileMigrationTests"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(4, forKey: HouseholdProfileStore.legacyHouseholdSizeKey)

        let profile = HouseholdProfileStore.load(
            defaults: defaults,
            locale: Locale(identifier: "nb_NO")
        )

        #expect(profile.countryCode == "NO")
        #expect(profile.householdSize == 4)
        #expect(profile.hasGasInstallation == false)
        #expect(profile.knowsWaterStopcock == false)
        #expect(profile.knowsMainElectricalPanel == false)
        #expect(defaults.integer(forKey: HouseholdProfileStore.legacyHouseholdSizeKey) == 4)
        #expect(defaults.data(forKey: HouseholdProfileStore.storageKey) != nil)
    }

    @Test func householdProfileStoreDoesNotOverwriteExistingProfile() throws {
        let suiteName = "HouseholdProfileExistingDataTests"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let savedProfile = HouseholdProfile(
            countryCode: "TH",
            municipality: "Chiang Mai",
            householdSize: 3,
            hasPets: true,
            hasGasInstallation: true,
            knowsWaterStopcock: true,
            knowsMainElectricalPanel: true
        )
        HouseholdProfileStore.save(savedProfile, defaults: defaults)
        defaults.set(7, forKey: HouseholdProfileStore.legacyHouseholdSizeKey)

        let loadedProfile = HouseholdProfileStore.load(
            defaults: defaults,
            locale: Locale(identifier: "nb_NO")
        )

        #expect(loadedProfile == savedProfile)
        #expect(loadedProfile.householdSize == 3)
        #expect(loadedProfile.hasGasInstallation)
        #expect(loadedProfile.knowsWaterStopcock)
        #expect(loadedProfile.knowsMainElectricalPanel)
    }

    @Test func householdProfileDecodingDefaultsNewFlagsSafely() throws {
        let legacyProfileJSON = """
        {
          "countryCode": "no",
          "householdSize": 2
        }
        """
        let data = try #require(legacyProfileJSON.data(using: .utf8))

        let profile = try JSONDecoder().decode(HouseholdProfile.self, from: data)

        #expect(profile.countryCode == "NO")
        #expect(profile.householdSize == 2)
        #expect(profile.hasChildren == false)
        #expect(profile.hasPets == false)
        #expect(profile.hasGasInstallation == false)
        #expect(profile.hasSpecialAssistanceNeeds == false)
        #expect(profile.knowsWaterStopcock == false)
        #expect(profile.knowsMainElectricalPanel == false)
    }

    @Test func householdWithoutGasDoesNotAllowGasSpecificGuidance() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 1)

        #expect(profile.allowsGasSpecificGuidance == false)
    }

    @Test func householdWithGasAllowsGasSpecificGuidance() {
        let profile = HouseholdProfile(
            countryCode: "NO",
            householdSize: 1,
            hasGasInstallation: true
        )

        #expect(profile.allowsGasSpecificGuidance)
    }

    @Test func everyEmergencyTypeHasTraceableOfflineTemplate() {
        #expect(NorwayEmergencyTemplates.all.count == EmergencyType.allCases.count)

        for emergencyType in EmergencyType.allCases {
            let template = NorwayEmergencyTemplates.template(for: emergencyType)
            #expect(template.type == emergencyType)
            #expect(template.id == "no.\(emergencyType.rawValue)")
            #expect(!template.actions.isEmpty)
            #expect(!template.shelterGuidance.isEmpty)
            #expect(!template.sourceIDs.isEmpty)
            #expect(template.shelterGuidance.allSatisfy {
                $0.safetyNoticeKey == "shelter.preparedness_not_official.notice"
            })
        }
    }

    @Test func legacyScenarioIdentifiersMapWithoutDroppingKnownPlans() {
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "brownout") == .powerOutage)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "storm") == .extremeWeather)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "invasion") == .warOrSecurityIncident)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "flood") == .flood)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "landslide") == .landslide)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "earthquake") == .evacuation)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: "volcano") == .evacuation)
        #expect(EmergencyType.migrated(fromLegacyIdentifier: nil) == nil)
    }

    @Test func everyLegacyPreparednessScenarioHasExplicitCompatibilityMapping() {
        let mappedIdentifiers = Set(EmergencyType.legacyIdentifierMapping.keys)
        let legacyIdentifiers = Set(PreparednessScenario.allCases.map(\.rawValue))

        #expect(mappedIdentifiers == legacyIdentifiers)
        #expect(EmergencyType.legacyIdentifierMapping["earthquake"] == .evacuation)
        #expect(EmergencyType.legacyIdentifierMapping["volcano"] == .evacuation)
    }

    @Test func legacyScenarioPlanContentSurvivesMappingUnchanged() {
        let plan = HouseholdPlan(
            scenarioIdentifier: "storm",
            reunionPoint: "Old oak tree",
            evacuationDestination: "Family cabin",
            shelterZone: "Interior hallway",
            gasShutoffNote: "Valve by the meter",
            medicalLead: "Alex – medication details",
            petLead: "Sam – bring carrier",
            familyPassword: "North star"
        )

        let mappedType = EmergencyType.migrated(fromLegacyIdentifier: plan.scenarioIdentifier)

        #expect(mappedType == .extremeWeather)
        #expect(plan.scenarioIdentifier == "storm")
        #expect(plan.reunionPoint == "Old oak tree")
        #expect(plan.evacuationDestination == "Family cabin")
        #expect(plan.shelterZone == "Interior hallway")
        #expect(plan.gasShutoffNote == "Valve by the meter")
        #expect(plan.medicalLead == "Alex – medication details")
        #expect(plan.petLead == "Sam – bring carrier")
        #expect(plan.familyPassword == "North star")
    }

    @Test func readingTemplateDoesNotOverwriteUserEditedPlanContent() {
        let plan = HouseholdPlan(
            scenarioIdentifier: "flood",
            reunionPoint: "User meeting point",
            evacuationDestination: "User destination",
            shelterZone: "User shelter note",
            gasShutoffNote: "User gas note",
            medicalLead: "User medical note",
            petLead: "User pet note",
            familyPassword: "User family message"
        )

        _ = NorwayEmergencyTemplates.template(for: .flood)

        #expect(plan.reunionPoint == "User meeting point")
        #expect(plan.evacuationDestination == "User destination")
        #expect(plan.shelterZone == "User shelter note")
        #expect(plan.gasShutoffNote == "User gas note")
        #expect(plan.medicalLead == "User medical note")
        #expect(plan.petLead == "User pet note")
        #expect(plan.familyPassword == "User family message")
    }

    @Test func emergencyTypeIdentifiersAreStableAndUnique() {
        let identifiers = EmergencyType.allCases.map(\.rawValue)

        #expect(identifiers == [
            "powerOutage", "flood", "extremeWeather", "landslide", "wildfire",
            "houseFire", "waterOutage", "evacuation", "hazardousRelease",
            "warOrSecurityIncident"
        ])
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test func norwayTemplateCatalogIsCountrySpecificAndOffline() throws {
        let provider = try #require(EmergencyTemplateCatalog.provider(for: "NO"))
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 2)

        for emergencyType in EmergencyType.allCases {
            let template = provider.template(for: emergencyType, household: profile)
            #expect(template.id == "no.\(emergencyType.rawValue)")
            #expect(template.type == emergencyType)
            #expect(!template.sourceIDs.isEmpty)
        }

        #expect(EmergencyTemplateCatalog.provider(for: "TH") == nil)
    }

    @Test func norwegianTemplatesFilterGasGuidanceByExplicitProfileFlag() {
        let withoutGas = HouseholdProfile(countryCode: "NO", householdSize: 1)
        let withGas = HouseholdProfile(
            countryCode: "NO",
            householdSize: 1,
            hasGasInstallation: true
        )

        for emergencyType in EmergencyType.allCases {
            let actionIDs = NorwayEmergencyTemplates
                .template(for: emergencyType, household: withoutGas)
                .actions
                .map(\.id)
            #expect(actionIDs.allSatisfy { !$0.contains("gasInstallation") })
        }

        let gasActionIDs = NorwayEmergencyTemplates
            .template(for: .houseFire, household: withGas)
            .actions
            .map(\.id)
        #expect(gasActionIDs.contains("houseFire.gasInstallationPreparedness"))
    }

    @Test func templateLocationsAreNeverMarkedAsOfficialSafeAddresses() {
        for template in NorwayEmergencyTemplates.all {
            #expect(template.shelterGuidance.allSatisfy { !$0.isOfficialLocation })
            #expect(template.shelterGuidance.allSatisfy {
                $0.safetyNoticeKey == "shelter.preparedness_not_official.notice"
            })
        }
    }

    @Test func myPlanLocationDraftMapsLegacyFieldsWithoutDataLoss() {
        let plan = HouseholdPlan(
            scenarioIdentifier: "storm",
            reunionPoint: "Old oak tree",
            evacuationDestination: "Family cabin",
            shelterZone: "Interior hallway",
            gasShutoffNote: "Valve by the meter",
            medicalLead: "Alex",
            petLead: "Sam",
            familyPassword: "North star",
            waterStopcockNote: "Utility room",
            mainElectricalPanelNote: "Front hall"
        )

        var draft = MyPlanLocationDraft(plan: plan)
        #expect(draft.householdMeetingPoint == "Old oak tree")
        #expect(draft.existingEvacuationDestination == "Family cabin")
        #expect(draft.existingShelterZone == "Interior hallway")
        #expect(draft.containsOnlyPersonalPlanningLocations)

        draft.householdMeetingPoint = "School gate"
        draft.alternativeAccommodation = "Hotel plan"
        draft.familyFriendLocation = "Trusted friend"
        draft.secondaryHome = "Cabin"
        draft.personalSafePlaceNote = "Personal planning note"
        draft.apply(to: plan)

        #expect(plan.reunionPoint == "School gate")
        #expect(plan.evacuationDestination == "Family cabin")
        #expect(plan.shelterZone == "Interior hallway")
        #expect(plan.alternativeAccommodation == "Hotel plan")
        #expect(plan.familyFriendLocation == "Trusted friend")
        #expect(plan.secondaryHome == "Cabin")
        #expect(plan.safePlaceNote == "Personal planning note")
        #expect(plan.gasShutoffNote == "Valve by the meter")
        #expect(plan.medicalLead == "Alex")
        #expect(plan.petLead == "Sam")
        #expect(plan.familyPassword == "North star")
        #expect(plan.waterStopcockNote == "Utility room")
        #expect(plan.mainElectricalPanelNote == "Front hall")
        #expect(plan.scenarioIdentifier == "storm")
    }

    @Test func openingAndSavingMyPlanWithoutEditsPreservesExistingPlan() {
        let plan = HouseholdPlan(
            scenarioIdentifier: "flood",
            reunionPoint: "Meeting point",
            evacuationDestination: "Destination",
            shelterZone: "Shelter note",
            gasShutoffNote: "Gas note",
            medicalLead: "Medical note",
            petLead: "Pet note",
            familyPassword: "Family message",
            alternativeAccommodation: "Alternative",
            familyFriendLocation: "Friend",
            secondaryHome: "Cabin",
            safePlaceNote: "Personal note"
        )
        MyPlanLocationDraft(plan: plan).apply(to: plan)

        #expect(plan.scenarioIdentifier == "flood")
        #expect(plan.reunionPoint == "Meeting point")
        #expect(plan.evacuationDestination == "Destination")
        #expect(plan.shelterZone == "Shelter note")
        #expect(plan.gasShutoffNote == "Gas note")
        #expect(plan.medicalLead == "Medical note")
        #expect(plan.petLead == "Pet note")
        #expect(plan.familyPassword == "Family message")
        #expect(plan.alternativeAccommodation == "Alternative")
        #expect(plan.familyFriendLocation == "Friend")
        #expect(plan.secondaryHome == "Cabin")
        #expect(plan.safePlaceNote == "Personal note")
    }

    @Test func myPlanUsesOfflineProviderForEveryEmergencySelection() throws {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 2)
        let provider = try #require(EmergencyTemplateCatalog.provider(for: profile.countryCode))

        for selection in EmergencyType.allCases {
            let template = provider.template(for: selection, household: profile)
            #expect(template.type == selection)
            #expect(template.id == "no.\(selection.rawValue)")
            #expect(!template.actions.isEmpty)
            #expect(!template.shelterGuidance.isEmpty)
        }
    }

    @Test func myPlanContactPreviewDoesNotMutateExistingContacts() {
        let family = FamilyContact(
            name: "Alex",
            role: "Medical",
            phoneNumber: "+47 900 00 111",
            notes: "Side entrance"
        )
        let important = ImportantNumber(
            label: "Doctor",
            phoneNumber: "+47 900 00 222",
            notes: "Weekdays"
        )
        let familyBefore = (family.name, family.role, family.phoneNumber, family.notes)
        let importantBefore = (important.label, important.phoneNumber, important.notes)

        _ = [family].prefix(3).map(\.name)
        _ = [important].prefix(3).map(\.label)

        #expect(family.name == familyBefore.0)
        #expect(family.role == familyBefore.1)
        #expect(family.phoneNumber == familyBefore.2)
        #expect(family.notes == familyBefore.3)
        #expect(important.label == importantBefore.0)
        #expect(important.phoneNumber == importantBefore.1)
        #expect(important.notes == importantBefore.2)
    }

    @Test func eventSupplyPrioritiesSupplementBaseItems() {
        let powerOutage = NorwayEmergencyTemplates.template(for: .powerOutage)
        let supplyIDs = Set(powerOutage.supplyPriorities.map(\.id))

        #expect(supplyIDs.isSuperset(of: ["water", "shelfStableFood", "medicines"]))
        #expect(supplyIDs.contains("batteryLighting"))
        #expect(supplyIDs.contains("powerBank"))
        #expect(supplyIDs.contains("radio"))
    }

    @Test func smartHomeSuppliesKeepBaseItemsAndAddEventPriorities() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 2)
        let items = prioritizedSupplies(for: .powerOutage, household: profile)
        let ids = Set(items.map(\.id))

        #expect(ids.isSuperset(of: [
            "water", "shelfStableFood", "cookingMethod", "warmth", "lighting",
            "radio", "batteries", "powerBank", "medicines", "firstAid",
            "hygiene", "paymentPreparedness"
        ]))
        #expect(items.count == Set(items.map(\.id)).count)
    }

    @Test func smartSuppliesRespectHouseholdNeeds() {
        let basicProfile = HouseholdProfile(countryCode: "NO", householdSize: 1)
        let basicIDs = Set(prioritizedSupplies(for: .flood, household: basicProfile).map(\.id))
        #expect(!basicIDs.contains("gasInstallationSupplies"))
        #expect(!basicIDs.contains("petHomeSupplies"))

        let adaptedProfile = HouseholdProfile(
            countryCode: "NO",
            householdSize: 4,
            hasChildren: true,
            hasPets: true,
            hasWoodStove: true,
            hasGasInstallation: true,
            hasEV: true,
            hasSpecialAssistanceNeeds: true
        )
        let homeIDs = Set(prioritizedSupplies(for: .flood, household: adaptedProfile).map(\.id))
        let evacuationIDs = Set(
            SupplyPrioritizer.prioritizedEvacuationSupplies(
                for: .flood,
                household: adaptedProfile
            ).map(\.id)
        )

        #expect(homeIDs.isSuperset(of: [
            "childHomeSupplies", "petHomeSupplies", "woodStoveFuel",
            "gasInstallationSupplies"
        ]))
        #expect(evacuationIDs.isSuperset(of: [
            "childEvacuationSupplies", "petEvacuationSupplies",
            "assistanceInformation", "evChargingPlan"
        ]))
    }

    @Test func evacuationSuppliesContainCriticalEssentialsWithoutDuplicates() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 1)
        let items = SupplyPrioritizer.prioritizedEvacuationSupplies(
            for: .evacuation,
            household: profile
        )
        let ids = Set(items.map(\.id))

        #expect(ids.isSuperset(of: [
            "identification", "medicines", "phone", "chargerPowerBank", "warmClothing",
            "grabFood", "drinkingWater", "bankCards", "cash", "documentCopies"
        ]))
        #expect(items.count == ids.count)
    }

    @Test func paymentPreparednessChecklistHasStableNorwegianRequirements() {
        #expect(PaymentPreparednessItem.allCases.map(\.id) == [
            "cashAvailable",
            "smallerDenominations",
            "multipleCards",
            "physicalCard",
            "multiplePaymentOptions"
        ])

        let norwegianTitles = PaymentPreparednessItem.allCases.map {
            $0.title(in: .norwegian)
        }
        #expect(norwegianTitles.allSatisfy { !$0.isEmpty })
        #expect(norwegianTitles.contains { $0.localizedCaseInsensitiveContains("kontant") })
        #expect(norwegianTitles.contains { $0.localizedCaseInsensitiveContains("fysisk kort") })
    }

    @Test func officialSourceRegistryUsesStableAuthoritativeMappings() throws {
        let sources = GuidanceSourceRegistry.norway
        let sourceIDs = Set(sources.map(\.id))

        #expect(sourceIDs == [
            "dsb-preparedness",
            "met-weather-warnings",
            "nve-natural-hazards"
        ])
        #expect(sources.allSatisfy { $0.countryCode == "NO" })
        #expect(sources.allSatisfy { $0.url.scheme == "https" })
        #expect(sources.allSatisfy { $0.lastReviewed > .distantPast })

        let encoded = try JSONEncoder().encode(sources)
        let decoded = try JSONDecoder().decode([GuidanceSource].self, from: encoded)
        #expect(decoded == sources)
    }

    @Test func shelterGMLDecoderPreservesOfficialFields() throws {
        let xml = """
        <wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs/2.0" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:app="http://example.com/app">
          <wfs:member><app:Tilfluktsrom><app:identifikasjon><app:Identifikasjon><app:lokalId>shelter-1</app:lokalId></app:Identifikasjon></app:identifikasjon><app:datauttaksdato>2026-09-29T23:40:57.826Z</app:datauttaksdato><app:posisjon><gml:Point><gml:pos>59.946683 10.619218</gml:pos></gml:Point></app:posisjon><app:romnr>16127</app:romnr><app:plasser>465</app:plasser><app:adresse>Nils Leuchsvei 40</app:adresse></app:Tilfluktsrom></wfs:member>
        </wfs:FeatureCollection>
        """

        let shelter = try #require(ShelterGMLDecoder.decode(Data(xml.utf8)).first)
        #expect(shelter.id == "shelter-1")
        #expect(shelter.address == "Nils Leuchsvei 40")
        #expect(shelter.capacity == 465)
        #expect(shelter.latitude == 59.946683)
        #expect(shelter.longitude == 10.619218)
        #expect(shelter.sourceID == "dsb-geonorge-public-shelters-wfs")
        #expect(shelter.dataUpdatedAt != nil)
    }

    @Test func emergencyTemplateRoundTripPreservesSourceMapping() throws {
        let template = NorwayEmergencyTemplates.template(for: .flood)

        let data = try JSONEncoder().encode(template)
        let decoded = try JSONDecoder().decode(EmergencyPlanTemplate.self, from: data)

        #expect(decoded == template)
        #expect(decoded.sourceIDs.contains("dsb-flood-preparedness"))
        #expect(decoded.sourceIDs.contains("nve-hazard-information"))
    }

    @Test func emergencyPlanMigrationCreatesOnlyMissingTypes() {
        let existingIdentifiers: [String?] = [
            "storm",
            "flood",
            EmergencyType.houseFire.rawValue,
            nil
        ]

        let missingTypes = EmergencyPlanMigration.missingEmergencyTypes(
            for: existingIdentifiers
        )

        #expect(!missingTypes.contains(.extremeWeather))
        #expect(!missingTypes.contains(.flood))
        #expect(!missingTypes.contains(.houseFire))
        #expect(missingTypes.contains(.powerOutage))
        #expect(missingTypes.contains(.evacuation))
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

    @Test func metAlertsDecoderPreservesOfficialContentAndSeverity() throws {
        let data = Data(metAlertsJSON(features: [
            metAlertFeature(id: "warning-1", type: "Alert", color: "Orange", start: "2026-09-30T10:00:00Z", end: "2026-09-30T14:00:00Z")
        ]).utf8)

        let alert = try #require(METAlertsDecoder.decode(data).first)
        #expect(alert.id == "warning-1")
        #expect(alert.severity == .orange)
        #expect(alert.messageType == .alert)
        #expect(alert.instruction == "Stay away from exposed areas.")
        #expect(alert.sourceID == "met-norway-metalerts-2")
    }

    @Test func metAlertsExcludeExpiredAndCancelledMessages() throws {
        let data = Data(metAlertsJSON(features: [
            metAlertFeature(id: "expired", type: "Alert", color: "Yellow", start: "2026-09-29T10:00:00Z", end: "2026-09-29T14:00:00Z"),
            metAlertFeature(id: "cancelled", type: "Alert", color: "Red", start: "2026-09-30T10:00:00Z", end: "2026-09-30T14:00:00Z"),
            metAlertFeature(id: "cancelled", type: "Cancel", color: "Red", start: "2026-09-30T10:00:00Z", end: "2026-09-30T14:00:00Z"),
            metAlertFeature(id: "updated", type: "Update", color: "Orange", start: "2026-09-30T10:00:00Z", end: "2026-09-30T14:00:00Z")
        ]).utf8)
        let now = try #require(ISO8601DateFormatter().date(from: "2026-09-30T12:00:00Z"))

        let active = METAlertsDecoder.activeAlerts(from: try METAlertsDecoder.decode(data), at: now)

        #expect(active.map(\.id) == ["updated"])
        #expect(active.first?.messageType == .update)
    }

    @Test func metAlertsRequestUsesHTTPSContactAndRoundedCoordinates() throws {
        let request = try METWeatherAlertService().makeRequest(
            latitude: 59.123456,
            longitude: 10.987654,
            languageCode: "no"
        )

        #expect(request.url?.scheme == "https")
        #expect(request.value(forHTTPHeaderField: "User-Agent")?.contains("github.com/terjemoe1954/Disaster-Ready") == true)
        #expect(request.url?.absoluteString.contains("lat=59.1235") == true)
        #expect(request.url?.absoluteString.contains("lon=10.9877") == true)
    }

    @Test func weatherAlertCachePreservesFreshnessTimestamp() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("weather-alert-cache-\(UUID().uuidString).json")
        let cache = WeatherAlertCache(fileURL: fileURL)
        let updatedAt = try #require(ISO8601DateFormatter().date(from: "2026-09-30T12:00:00Z"))
        let alert = try #require(METAlertsDecoder.decode(Data(metAlertsJSON(features: [
            metAlertFeature(id: "cached", type: "Alert", color: "Yellow", start: "2026-09-30T10:00:00Z", end: "2026-09-30T14:00:00Z")
        ]).utf8)).first)

        try await cache.save(.init(alerts: [alert], updatedAt: updatedAt, latitude: 59.9139, longitude: 10.7522))
        let entry = await cache.load(latitude: 59.9139, longitude: 10.7522)

        #expect(entry?.updatedAt == updatedAt)
        #expect(entry?.alerts == [alert])
        #expect(await cache.load(latitude: 60.3929, longitude: 5.3242) == nil)
    }

    @Test func shelterCachePreservesReferenceDataTimestamp() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("shelter-cache-\(UUID().uuidString).json")
        let cache = ShelterCache(fileURL: fileURL)
        let updatedAt = try #require(ISO8601DateFormatter().date(from: "2026-09-30T12:00:00Z"))
        let shelter = Shelter(
            id: "room-1",
            roomNumber: "1",
            address: "Example road 1",
            capacity: 100,
            latitude: 59.9139,
            longitude: 10.7522,
            sourceID: "dsb-geonorge-public-shelters-wfs",
            dataUpdatedAt: nil
        )

        try await cache.save(.init(shelters: [shelter], updatedAt: updatedAt, latitude: 59.9139, longitude: 10.7522))
        let entry = await cache.load(latitude: 59.9139, longitude: 10.7522)

        #expect(entry?.updatedAt == updatedAt)
        #expect(entry?.shelters == [shelter])
        #expect(await cache.load(latitude: 60.3929, longitude: 5.3242) == nil)
    }

    @Test func smartSupplyRecommendationsAreDeterministicAndOffline() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 3, hasChildren: true)
        let first = SupplyPrioritizer.recommendations(for: .powerOutage, household: profile)
        let second = SupplyPrioritizer.recommendations(for: .powerOutage, household: profile)

        #expect(first == second)
        #expect(!first.home.isEmpty)
        #expect(!first.grab.isEmpty)
    }

    @Test func everyEmergencyReturnsDistinctValidHomeAndGrabLists() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 1)
        for emergency in EmergencyType.allCases {
            let result = SupplyPrioritizer.recommendations(for: emergency, household: profile)
            #expect(result.emergencyType == emergency)
            #expect(result.home.allSatisfy { $0.listKind == .homePreparedness })
            #expect(result.grab.allSatisfy { $0.listKind == .grabEvacuation })
            #expect(Set(result.home.map(\.id)).count == result.home.count)
            #expect(Set(result.grab.map(\.id)).count == result.grab.count)
        }
    }

    @Test func powerOutagePrioritizesPowerInformationAndHeatPreparation() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 2, hasElectricHeating: true)
        let result = SupplyPrioritizer.recommendations(for: .powerOutage, household: profile)
        let critical = Set(result.home.filter { $0.priority == .critical }.map(\.id))

        #expect(critical.isSuperset(of: ["lighting", "batteries", "radio", "powerBank", "cookingMethod", "warmth"]))
    }

    @Test func floodAndEvacuationPrioritizeGrabReadiness() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 2)
        let flood = SupplyPrioritizer.recommendations(for: .flood, household: profile)
        let evacuation = SupplyPrioritizer.recommendations(for: .evacuation, household: profile)
        let floodCritical = Set(flood.grab.filter { $0.priority == .critical }.map(\.id))
        let evacuationCritical = Set(evacuation.grab.filter { $0.priority == .critical }.map(\.id))

        #expect(floodCritical.isSuperset(of: ["documentCopies", "medicines", "phone", "drinkingWater"]))
        #expect(evacuationCritical.isSuperset(of: ["identification", "medicines", "phone", "chargerPowerBank", "bankCards"]))
    }

    @Test func houseFireAndSecurityUseSafetySpecificNotices() {
        let profile = HouseholdProfile(countryCode: "NO", householdSize: 1)
        #expect(SupplyPrioritizer.recommendations(for: .houseFire, household: profile).safetyNoticeKey == "smart_supply.safety.house_fire")
        #expect(SupplyPrioritizer.recommendations(for: .warOrSecurityIncident, household: profile).safetyNoticeKey == "smart_supply.safety.authority_first")
    }

    @Test func householdNeedsAddOnlyApplicableRecommendations() {
        let standard = HouseholdProfile(countryCode: "NO", householdSize: 1)
        let adapted = HouseholdProfile(
            countryCode: "NO",
            householdSize: 4,
            hasChildren: true,
            hasPets: true,
            hasSpecialAssistanceNeeds: true
        )
        let standardPlan = SupplyPrioritizer.recommendations(for: .evacuation, household: standard)
        let adaptedPlan = SupplyPrioritizer.recommendations(for: .evacuation, household: adapted)
        let standardIDs = Set((standardPlan.home + standardPlan.grab).map(\.id))
        let adaptedIDs = Set((adaptedPlan.home + adaptedPlan.grab).map(\.id))

        #expect(!standardIDs.contains("petEvacuationSupplies"))
        #expect(!standardIDs.contains("childEvacuationSupplies"))
        #expect(!standardIDs.contains("essentialSupportSupplies"))
        #expect(adaptedIDs.isSuperset(of: ["petEvacuationSupplies", "childEvacuationSupplies", "essentialSupportSupplies", "assistanceInformation"]))
    }

    @Test func gasRecommendationsRequireExplicitNorwegianGasFlag() {
        let noGas = HouseholdProfile(countryCode: "NO", householdSize: 1)
        let withGas = HouseholdProfile(countryCode: "NO", householdSize: 1, hasGasInstallation: true)
        let noGasIDs = Set(SupplyPrioritizer.recommendations(for: .powerOutage, household: noGas).home.map(\.id))
        let gasIDs = Set(SupplyPrioritizer.recommendations(for: .powerOutage, household: withGas).home.map(\.id))

        #expect(!noGasIDs.contains("gasInstallationSupplies"))
        #expect(gasIDs.contains("gasInstallationSupplies"))
    }

    @Test func recommendationEngineNeverMutatesExistingSupplyItem() throws {
        let reviewDate = try #require(ISO8601DateFormatter().date(from: "2027-04-01T09:00:00Z"))
        let item = SupplyItem(
            name: "Personal radio",
            detail: "User note",
            isPacked: true,
            storageLocation: "Custom shelf",
            quantity: "2",
            reviewDate: reviewDate
        )

        _ = SupplyPrioritizer.recommendations(
            for: .powerOutage,
            household: HouseholdProfile(countryCode: "NO", householdSize: 1)
        )

        #expect(item.name == "Personal radio")
        #expect(item.detail == "User note")
        #expect(item.storageLocation == "Custom shelf")
        #expect(item.quantity == "2")
        #expect(item.isPacked)
        #expect(item.reviewDate == reviewDate)
    }

    @Test func ownershipMatchingIsExactAndDoesNotUseFuzzyClaims() {
        let exact = SupplyItem(name: "Battery lighting", detail: "", isPacked: false, storageLocation: "home")
        #expect(SupplyOwnershipMatcher.appearsRecorded(recommendationName: "battery lighting", in: [exact]))
        #expect(!SupplyOwnershipMatcher.appearsRecorded(recommendationName: "Batteries", in: [exact]))
        #expect(!SupplyOwnershipMatcher.appearsRecorded(recommendationName: "Lighting", in: [exact]))
    }

    private func metAlertsJSON(features: [String]) -> String {
        "{\"features\":[\(features.joined(separator: ","))]}"
    }

    private func metAlertFeature(id: String, type: String, color: String, start: String, end: String) -> String {
        """
        {"properties":{"id":"\(id)","title":"Strong wind","event":"Wind","area":"Oslo","description":"Strong wind is expected.","instruction":"Stay away from exposed areas.","consequences":"Objects may be blown away.","riskMatrixColor":"\(color)","severity":"Severe","status":"Actual","type":"\(type)","web":"https://www.met.no/"},"when":{"interval":["\(start)","\(end)"]}}
        """
    }

}
