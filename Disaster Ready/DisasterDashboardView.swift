//
//  DisasterDashboardView.swift
//  Disaster Ready
//
//  Created by Terje Moe on 28/08/2026.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DisasterDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("preferredLanguageCode") private var preferredLanguageCode = AppLanguage.current.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("includePlanSummaryInMessages") private var includePlanSummaryInMessages = true
    @AppStorage("showOnlyMissingSupplies") private var showOnlyMissingSupplies = false
    @AppStorage("offlineFirstMode") private var offlineFirstMode = true
    @Query(sort: \FamilyContact.name) private var familyContacts: [FamilyContact]
    @Query(sort: \ImportantNumber.label) private var importantNumbers: [ImportantNumber]
    @Query(sort: \HouseholdPlan.id) private var householdPlans: [HouseholdPlan]
    @Query(
        filter: #Predicate<SupplyItem> { item in
            item.storageLocation == "Home"
        },
        sort: \SupplyItem.name
    ) private var homeSupplies: [SupplyItem]
    @Query(
        filter: #Predicate<SupplyItem> { item in
            item.storageLocation == "Car"
        },
        sort: \SupplyItem.name
    ) private var carSupplies: [SupplyItem]

    @State private var selectedScenario: PreparednessScenario = .storm
    @State private var selectedLanguage: AppLanguage = .current
    @State private var showingSettings = false
    @State private var showingOnboarding = false
    @State private var backupDocument = DisasterBackupDocument(payload: .empty)
    @State private var showingBackupExporter = false
    @State private var showingBackupImporter = false
    @State private var transferMessage: String?
    @State private var showingTransferAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HeroCardSection(language: selectedLanguage)
                    ScenarioSelectorSection(
                        selectedScenario: $selectedScenario,
                        language: selectedLanguage
                    )
                    DecisionCardSection(
                        scenario: selectedScenario,
                        language: selectedLanguage
                    )

                    if let plan = householdPlans.first {
                        HouseholdPlanSection(
                            plan: plan,
                            summary: planSummary(for: plan),
                            language: selectedLanguage
                        )
                    }

                    ContactsSection(
                        familyContacts: familyContacts,
                        importantNumbers: importantNumbers,
                        language: selectedLanguage,
                        addFamily: addFamilyContact,
                        addImportant: addImportantNumber,
                        deleteFamily: deleteFamilyContact,
                        deleteImportant: deleteImportantNumber
                    )

                    MessageTemplatesSection(
                        templates: messageTemplates,
                        shareText: messageBody(for:),
                        language: selectedLanguage
                    )

                    RolesSection(
                        roles: householdRoles,
                        language: selectedLanguage
                    )

                    SuppliesSection(
                        homeSupplies: visibleHomeSupplies,
                        carSupplies: visibleCarSupplies,
                        completionCount: supplyCompletionCount,
                        totalCount: totalSupplyCount,
                        language: selectedLanguage,
                        addItem: addSupplyItem,
                        deleteItem: deleteSupplyItem
                    )

                    DrillsSection(
                        drills: drills,
                        language: selectedLanguage
                    )

                    OfflineResourcesSection(
                        resources: offlineResources,
                        language: selectedLanguage
                    )

                    ReleaseReadinessSection(
                        isOfflineFirst: offlineFirstMode,
                        supportsLocalization: true,
                        hasOnboarding: true,
                        hasLocalPlanStorage: !householdPlans.isEmpty,
                        language: selectedLanguage
                    )

                    PricingSection(language: selectedLanguage)
                }
                .padding(20)
            }
            .background(backgroundGradient)
            .navigationTitle("Disaster Ready")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(L10n.text("language", language: selectedLanguage), selection: $selectedLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                    } label: {
                        Text(selectedLanguage.shortLabel)
                            .font(.caption.weight(.bold))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .environment(\.locale, AppLanguage.locale(for: selectedLanguage))
        .sheet(isPresented: $showingSettings) {
            SettingsSheet(
                selectedLanguage: $selectedLanguage,
                includePlanSummaryInMessages: $includePlanSummaryInMessages,
                showOnlyMissingSupplies: $showOnlyMissingSupplies,
                offlineFirstMode: $offlineFirstMode,
                reopenOnboarding: { showingOnboarding = true },
                exportBackup: prepareBackupExport,
                importBackup: { showingBackupImporter = true },
                language: selectedLanguage
            )
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(
                language: selectedLanguage,
                finish: {
                    hasSeenOnboarding = true
                    showingOnboarding = false
                }
            )
        }
        .task {
            seedDataIfNeeded()
            selectedLanguage = AppLanguage(rawValue: preferredLanguageCode) ?? .current
            if !hasSeenOnboarding {
                showingOnboarding = true
            }
        }
        .fileExporter(
            isPresented: $showingBackupExporter,
            document: backupDocument,
            contentType: .json,
            defaultFilename: backupFileName
        ) { result in
            handleBackupExport(result)
        }
        .fileImporter(
            isPresented: $showingBackupImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleBackupImport(result)
        }
        .alert(transferAlertTitle, isPresented: $showingTransferAlert) {
            Button(alertDoneTitle, role: .cancel) {}
        } message: {
            Text(transferMessage ?? "")
        }
        .onChange(of: selectedLanguage) { _, newValue in
            preferredLanguageCode = newValue.rawValue
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.92, blue: 0.86),
                Color(red: 0.80, green: 0.86, blue: 0.86),
                Color(red: 0.22, green: 0.29, blue: 0.34)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var householdRoles: [HouseholdRole] {
        [
            HouseholdRole(
                title: L10n.text("medical", language: selectedLanguage),
                person: "Alex",
                task: L10n.text("role_medical_task", language: selectedLanguage),
                systemImage: "cross.case.fill"
            ),
            HouseholdRole(
                title: L10n.text("utilities", language: selectedLanguage),
                person: "Jordan",
                task: L10n.text("role_utilities_task", language: selectedLanguage),
                systemImage: "wrench.adjustable.fill"
            ),
            HouseholdRole(
                title: L10n.text("pets", language: selectedLanguage),
                person: "Sam",
                task: L10n.text("role_pets_task", language: selectedLanguage),
                systemImage: "pawprint.fill"
            ),
            HouseholdRole(
                title: L10n.text("communications", language: selectedLanguage),
                person: "Taylor",
                task: L10n.text("role_comms_task", language: selectedLanguage),
                systemImage: "message.fill"
            )
        ]
    }

    private var drills: [Drill] {
        [
            Drill(title: L10n.text("drill_bag_race", language: selectedLanguage), frequency: L10n.text("weekly", language: selectedLanguage), duration: "1 min"),
            Drill(title: L10n.text("drill_gas_breaker", language: selectedLanguage), frequency: L10n.text("monthly", language: selectedLanguage), duration: "5 min"),
            Drill(title: L10n.text("drill_pet_walkthrough", language: selectedLanguage), frequency: L10n.text("monthly", language: selectedLanguage), duration: "7 min"),
            Drill(title: L10n.text("drill_reunion", language: selectedLanguage), frequency: L10n.text("quarterly", language: selectedLanguage), duration: "15 min")
        ]
    }

    private var offlineResources: [OfflineResource] {
        [
            OfflineResource(
                title: L10n.text("offline_home_map", language: selectedLanguage),
                detail: L10n.text("offline_home_map_detail", language: selectedLanguage),
                systemImage: "map.fill"
            ),
            OfflineResource(
                title: L10n.text("offline_field_guides", language: selectedLanguage),
                detail: L10n.text("offline_field_guides_detail", language: selectedLanguage),
                systemImage: "books.vertical.fill"
            ),
            OfflineResource(
                title: L10n.text("offline_first_24", language: selectedLanguage),
                detail: L10n.text("offline_first_24_detail", language: selectedLanguage),
                systemImage: "point.topleft.down.curvedto.point.bottomright.up.fill"
            )
        ]
    }

    private var messageTemplates: [FamilyMessageTemplate] {
        [
            FamilyMessageTemplate(
                title: L10n.text("msg_safe_title", language: selectedLanguage),
                body: L10n.text("msg_safe_body", language: selectedLanguage)
            ),
            FamilyMessageTemplate(
                title: L10n.text("msg_leaving_title", language: selectedLanguage),
                body: L10n.text("msg_leaving_body", language: selectedLanguage)
            ),
            FamilyMessageTemplate(
                title: L10n.text("msg_help_title", language: selectedLanguage),
                body: L10n.text("msg_help_body", language: selectedLanguage)
            )
        ]
    }

    private var totalSupplyCount: Int {
        homeSupplies.count + carSupplies.count
    }

    private var supplyCompletionCount: Int {
        homeSupplies.filter(\.isPacked).count + carSupplies.filter(\.isPacked).count
    }

    private var visibleHomeSupplies: [SupplyItem] {
        showOnlyMissingSupplies ? homeSupplies.filter { !$0.isPacked } : homeSupplies
    }

    private var visibleCarSupplies: [SupplyItem] {
        showOnlyMissingSupplies ? carSupplies.filter { !$0.isPacked } : carSupplies
    }

    private func planSummary(for plan: HouseholdPlan) -> String {
        let reunion = plan.reunionPoint.isEmpty ? L10n.text("not_set", language: selectedLanguage) : plan.reunionPoint
        let evacuation = plan.evacuationDestination.isEmpty ? L10n.text("not_set", language: selectedLanguage) : plan.evacuationDestination
        let shelter = plan.shelterZone.isEmpty ? L10n.text("not_set", language: selectedLanguage) : plan.shelterZone

        return L10n.format(
            "plan_summary_format",
            language: selectedLanguage,
            selectedScenario.localizedName(in: selectedLanguage),
            reunion,
            evacuation,
            shelter
        )
    }

    private func messageBody(for template: FamilyMessageTemplate) -> String {
        var lines = [
            template.body,
            "\(L10n.text("scenario", language: selectedLanguage)): \(selectedScenario.localizedName(in: selectedLanguage))",
            "\(L10n.text("action", language: selectedLanguage)): \(selectedScenario.recommendedAction(in: selectedLanguage))"
        ]

        if includePlanSummaryInMessages, let plan = householdPlans.first {
            lines.append(planSummary(for: plan))
        }

        return lines.joined(separator: "\n")
    }

    private func addFamilyContact() {
        modelContext.insert(FamilyContact(name: "", role: "", phoneNumber: "", notes: ""))
    }

    private func addImportantNumber() {
        modelContext.insert(ImportantNumber(label: "", phoneNumber: "", notes: ""))
    }

    private func addSupplyItem(_ location: SupplyLocation) {
        modelContext.insert(
            SupplyItem(name: "", detail: "", isPacked: false, storageLocation: location.rawValue)
        )
    }

    private func deleteFamilyContact(_ contact: FamilyContact) {
        modelContext.delete(contact)
    }

    private func deleteImportantNumber(_ number: ImportantNumber) {
        modelContext.delete(number)
    }

    private func deleteSupplyItem(_ item: SupplyItem) {
        modelContext.delete(item)
    }

    private func prepareBackupExport() {
        backupDocument = DisasterBackupDocument(
            payload: DisasterBackupPayload(
                exportDate: Date(),
                familyContacts: familyContacts.map {
                    FamilyContactSnapshot(
                        name: $0.name,
                        role: $0.role,
                        phoneNumber: $0.phoneNumber,
                        notes: $0.notes
                    )
                },
                importantNumbers: importantNumbers.map {
                    ImportantNumberSnapshot(
                        label: $0.label,
                        phoneNumber: $0.phoneNumber,
                        notes: $0.notes
                    )
                },
                householdPlans: householdPlans.map {
                    HouseholdPlanSnapshot(
                        reunionPoint: $0.reunionPoint,
                        evacuationDestination: $0.evacuationDestination,
                        shelterZone: $0.shelterZone,
                        gasShutoffNote: $0.gasShutoffNote,
                        medicalLead: $0.medicalLead,
                        petLead: $0.petLead,
                        familyPassword: $0.familyPassword
                    )
                },
                supplies: (homeSupplies + carSupplies).map {
                    SupplyItemSnapshot(
                        name: $0.name,
                        detail: $0.detail,
                        isPacked: $0.isPacked,
                        storageLocation: $0.storageLocation
                    )
                }
            )
        )
        showingBackupExporter = true
    }

    private func handleBackupExport(_ result: Result<URL, Error>) {
        switch result {
        case .success:
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "Local backup exported successfully.",
                norwegian: "Lokal sikkerhetskopi ble eksportert.",
                thai: "ส่งออกข้อมูลสำรองในเครื่องสำเร็จแล้ว"
            )
        case .failure:
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "Backup export failed.",
                norwegian: "Eksport av sikkerhetskopi mislyktes.",
                thai: "การส่งออกข้อมูลสำรองล้มเหลว"
            )
        }
        showingTransferAlert = true
    }

    private func handleBackupImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let payload = try decoder.decode(DisasterBackupPayload.self, from: data)
                restore(from: payload)

                transferMessage = L10n.pick(
                    language: selectedLanguage,
                    english: "Backup imported and local data restored.",
                    norwegian: "Sikkerhetskopi importert og lokale data gjenopprettet.",
                    thai: "นำเข้าข้อมูลสำรองและกู้คืนข้อมูลในเครื่องแล้ว"
                )
            } catch {
                transferMessage = L10n.pick(
                    language: selectedLanguage,
                    english: "Backup import failed. The file could not be read.",
                    norwegian: "Import av sikkerhetskopi mislyktes. Filen kunne ikke leses.",
                    thai: "การนำเข้าข้อมูลสำรองล้มเหลว ไม่สามารถอ่านไฟล์ได้"
                )
            }
        case .failure:
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "Backup import was cancelled.",
                norwegian: "Import av sikkerhetskopi ble avbrutt.",
                thai: "ยกเลิกการนำเข้าข้อมูลสำรองแล้ว"
            )
        }

        showingTransferAlert = true
    }

    private func restore(from payload: DisasterBackupPayload) {
        familyContacts.forEach(modelContext.delete)
        importantNumbers.forEach(modelContext.delete)
        householdPlans.forEach(modelContext.delete)
        homeSupplies.forEach(modelContext.delete)
        carSupplies.forEach(modelContext.delete)

        payload.familyContacts
            .map { FamilyContact(name: $0.name, role: $0.role, phoneNumber: $0.phoneNumber, notes: $0.notes) }
            .forEach(modelContext.insert)
        payload.importantNumbers
            .map { ImportantNumber(label: $0.label, phoneNumber: $0.phoneNumber, notes: $0.notes) }
            .forEach(modelContext.insert)
        payload.householdPlans
            .map {
                HouseholdPlan(
                    reunionPoint: $0.reunionPoint,
                    evacuationDestination: $0.evacuationDestination,
                    shelterZone: $0.shelterZone,
                    gasShutoffNote: $0.gasShutoffNote,
                    medicalLead: $0.medicalLead,
                    petLead: $0.petLead,
                    familyPassword: $0.familyPassword
                )
            }
            .forEach(modelContext.insert)
        payload.supplies
            .map {
                SupplyItem(
                    name: $0.name,
                    detail: $0.detail,
                    isPacked: $0.isPacked,
                    storageLocation: $0.storageLocation
                )
            }
            .forEach(modelContext.insert)
    }

    private func seedDataIfNeeded() {
        guard familyContacts.isEmpty, importantNumbers.isEmpty, householdPlans.isEmpty, homeSupplies.isEmpty, carSupplies.isEmpty else {
            return
        }

        defaultFamilyContacts.forEach(modelContext.insert)
        defaultImportantNumbers.forEach(modelContext.insert)
        modelContext.insert(defaultHouseholdPlan)
        defaultHomeSupplies.forEach(modelContext.insert)
        defaultCarSupplies.forEach(modelContext.insert)
    }

    private var defaultFamilyContacts: [FamilyContact] {
        [
            FamilyContact(
                name: "Alex",
                role: L10n.text("medical", language: selectedLanguage),
                phoneNumber: "+47 900 00 111",
                notes: L10n.text("seed_family_alex", language: selectedLanguage)
            ),
            FamilyContact(
                name: "Jordan",
                role: L10n.text("utilities", language: selectedLanguage),
                phoneNumber: "+47 900 00 222",
                notes: L10n.text("seed_family_jordan", language: selectedLanguage)
            ),
            FamilyContact(
                name: "Sam",
                role: L10n.text("pets", language: selectedLanguage),
                phoneNumber: "+47 900 00 333",
                notes: L10n.text("seed_family_sam", language: selectedLanguage)
            )
        ]
    }

    private var defaultImportantNumbers: [ImportantNumber] {
        [
            ImportantNumber(
                label: L10n.text("seed_emergency_contact", language: selectedLanguage),
                phoneNumber: "112",
                notes: L10n.text("seed_emergency_contact_note", language: selectedLanguage)
            ),
            ImportantNumber(
                label: L10n.text("seed_poison_info", language: selectedLanguage),
                phoneNumber: "22 59 13 00",
                notes: L10n.text("seed_poison_info_note", language: selectedLanguage)
            ),
            ImportantNumber(
                label: L10n.text("seed_neighborhood_checkin", language: selectedLanguage),
                phoneNumber: "+47 900 88 999",
                notes: L10n.text("seed_neighborhood_checkin_note", language: selectedLanguage)
            )
        ]
    }

    private var defaultHouseholdPlan: HouseholdPlan {
        HouseholdPlan(
            reunionPoint: "",
            evacuationDestination: "",
            shelterZone: "",
            gasShutoffNote: "",
            medicalLead: "",
            petLead: "",
            familyPassword: ""
        )
    }

    private var defaultHomeSupplies: [SupplyItem] {
        [
            SupplyItem(name: L10n.text("supply_water", language: selectedLanguage), detail: L10n.text("supply_water_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.home.rawValue),
            SupplyItem(name: L10n.text("supply_shelf_food", language: selectedLanguage), detail: L10n.text("supply_shelf_food_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.home.rawValue),
            SupplyItem(name: L10n.text("supply_cooking_backup", language: selectedLanguage), detail: L10n.text("supply_cooking_backup_detail", language: selectedLanguage), isPacked: false, storageLocation: SupplyLocation.home.rawValue),
            SupplyItem(name: L10n.text("supply_medical_kit", language: selectedLanguage), detail: L10n.text("supply_medical_kit_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.home.rawValue),
            SupplyItem(name: L10n.text("supply_power_light", language: selectedLanguage), detail: L10n.text("supply_power_light_detail", language: selectedLanguage), isPacked: false, storageLocation: SupplyLocation.home.rawValue),
            SupplyItem(name: L10n.text("supply_warmth_shelter", language: selectedLanguage), detail: L10n.text("supply_warmth_shelter_detail", language: selectedLanguage), isPacked: false, storageLocation: SupplyLocation.home.rawValue)
        ]
    }

    private var defaultCarSupplies: [SupplyItem] {
        [
            SupplyItem(name: L10n.text("supply_water_snacks", language: selectedLanguage), detail: L10n.text("supply_water_snacks_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.car.rawValue),
            SupplyItem(name: L10n.text("supply_navigation", language: selectedLanguage), detail: L10n.text("supply_navigation_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.car.rawValue),
            SupplyItem(name: L10n.text("supply_vehicle_recovery", language: selectedLanguage), detail: L10n.text("supply_vehicle_recovery_detail", language: selectedLanguage), isPacked: false, storageLocation: SupplyLocation.car.rawValue),
            SupplyItem(name: L10n.text("supply_weather_gear", language: selectedLanguage), detail: L10n.text("supply_weather_gear_detail", language: selectedLanguage), isPacked: false, storageLocation: SupplyLocation.car.rawValue),
            SupplyItem(name: L10n.text("supply_safety_kit", language: selectedLanguage), detail: L10n.text("supply_safety_kit_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.car.rawValue),
            SupplyItem(name: L10n.text("supply_phone_backup", language: selectedLanguage), detail: L10n.text("supply_phone_backup_detail", language: selectedLanguage), isPacked: true, storageLocation: SupplyLocation.car.rawValue)
        ]
    }

    private var backupFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "disaster-ready-backup-\(formatter.string(from: Date()))"
    }

    private var transferAlertTitle: String {
        L10n.pick(
            language: selectedLanguage,
            english: "Backup",
            norwegian: "Sikkerhetskopi",
            thai: "ข้อมูลสำรอง"
        )
    }

    private var alertDoneTitle: String {
        L10n.pick(language: selectedLanguage, english: "OK", norwegian: "OK", thai: "ตกลง")
    }
}

#Preview {
    DisasterDashboardView()
}
