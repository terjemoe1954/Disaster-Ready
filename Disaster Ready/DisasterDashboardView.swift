//
//  DisasterDashboardView.swift
//  Disaster Ready
//
//  Created by Terje Moe on 28/08/2026.
//

import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DisasterDashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @AppStorage("preferredLanguageCode") private var preferredLanguageCode = AppLanguage.current.rawValue
    @AppStorage("preferredAppearance") private var preferredAppearance = AppAppearance.system.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("includePlanSummaryInMessages") private var includePlanSummaryInMessages = true
    @AppStorage("showOnlyMissingSupplies") private var showOnlyMissingSupplies = false
    @AppStorage("offlineFirstMode") private var offlineFirstMode = true
    @AppStorage("householdMemberCount") private var householdMemberCount = 1
    @AppStorage("supplyReviewRemindersEnabled") private var supplyReviewRemindersEnabled = false
    @Query(sort: \FamilyContact.name) private var familyContacts: [FamilyContact]
    @Query(sort: \ImportantNumber.label) private var importantNumbers: [ImportantNumber]
    @Query(sort: \HouseholdPlan.id) private var householdPlans: [HouseholdPlan]
    @Query(sort: \HouseholdRole.title) private var householdRoles: [HouseholdRole]
    @Query(sort: \SupplyItem.name) private var supplies: [SupplyItem]

    @State private var selectedScenario: PreparednessScenario = .storm
    @State private var selectedEmergencyType: EmergencyType = .extremeWeather
    @State private var householdProfile = HouseholdProfile.defaultProfile(locale: .current, householdSize: 1)
    @State private var paymentPreparedness = PaymentPreparednessChecklist()
    @State private var selectedTab: DashboardTab = .overview
    @State private var selectedLanguage: AppLanguage = .current
    @State private var showingSettings = false
    @State private var showingOnboarding = false
    @State private var backupDocument = DisasterBackupDocument(payload: .empty)
    @State private var showingBackupExporter = false
    @State private var showingBackupImporter = false
    @State private var pendingBackupPayload: DisasterBackupPayload?
    @State private var showingBackupImportConfirmation = false
    @State private var showingNewSupplyEditor = false
    @State private var newSupplyLocation: SupplyLocation = .home
    @State private var supplyErrorMessage: String?
    @State private var showingSupplyError = false
    @State private var reminderMessage: String?
    @State private var showingReminderAlert = false
    @State private var showsReminderSettingsAction = false
    @State private var schedulesTestReminderOnAlertDismiss = false
    @State private var transferMessage: String?
    @State private var showingTransferAlert = false

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Tab(overviewTabTitle, systemImage: "house.fill", value: DashboardTab.overview) {
                    dashboardScrollView {
                        HeroCardSection(language: selectedLanguage)
                        OfficialWeatherAlertsSection(language: selectedLanguage) { emergencyType in
                            selectedEmergencyType = emergencyType
                            selectedTab = .plan
                        }
                        PreparednessOverviewSection(
                            completedPlanItems: completedPlanItems,
                            totalPlanItems: 3,
                            packedSupplies: supplyCompletionCount,
                            totalSupplies: totalSupplyCount,
                            suppliesNeedingReview: suppliesNeedingReviewCount,
                            contactCount: familyContacts.count + importantNumbers.count,
                            language: selectedLanguage,
                            openPlan: { selectedTab = .plan },
                            openSupplies: { selectedTab = .supplies },
                            openContacts: { selectedTab = .contacts }
                        )
                        ScenarioSelectorSection(
                            selectedScenario: $selectedScenario,
                            language: selectedLanguage
                        )
                        DecisionCardSection(
                            scenario: selectedScenario,
                            language: selectedLanguage
                        )
                    }
                }

                Tab(planTabTitle, systemImage: "checklist", value: DashboardTab.plan) {
                    dashboardScrollView {
                        if let plan = currentEmergencyPlan {
                            EventAwareMyPlanView(
                                selectedEmergencyType: $selectedEmergencyType,
                                plan: plan,
                                household: householdProfile,
                                savedSupplies: supplies,
                                paymentPreparedness: paymentPreparedness,
                                familyContacts: familyContacts,
                                importantNumbers: importantNumbers,
                                language: selectedLanguage,
                                openContacts: { selectedTab = .contacts },
                                savePlan: saveCurrentPlan
                            )
                        }
                        RolesSection(
                            roles: householdRoles,
                            language: selectedLanguage,
                            addRole: addHouseholdRole,
                            deleteRole: deleteHouseholdRole
                        )
                        MessageTemplatesSection(
                            templates: messageTemplates,
                            shareText: messageBody(for:),
                            language: selectedLanguage
                        )
                        DrillsSection(drills: drills, language: selectedLanguage)
                    }
                }

                Tab(suppliesTabTitle, systemImage: "shippingbox.fill", value: DashboardTab.supplies) {
                    dashboardScrollView {
                        SmartSupplyRecommendationsSection(
                            homeCount: homeSupplyRecommendations.count,
                            evacuationCount: evacuationSupplyRecommendations.count,
                            language: selectedLanguage,
                            addHome: addSmartHomeSupplies,
                            addEvacuation: addSmartEvacuationSupplies
                        )
                        if householdProfile.countryCode == "NO" {
                            PaymentPreparednessSection(
                                checklist: $paymentPreparedness,
                                language: selectedLanguage
                            )
                        }
                        HomePreparednessGuideSection(
                            householdMemberCount: $householdMemberCount,
                            language: selectedLanguage
                        )
                        SuppliesSection(
                            homeSupplies: visibleHomeSupplies,
                            carSupplies: visibleCarSupplies,
                            completionCount: supplyCompletionCount,
                            totalCount: totalSupplyCount,
                            showOnlyMissing: $showOnlyMissingSupplies,
                            language: selectedLanguage,
                            deleteItem: deleteSupplyItem
                        )
                        OfflineResourcesSection(resources: offlineResources, language: selectedLanguage)
                        OfficialSourcesSection(
                            sources: GuidanceSourceRegistry.norway,
                            language: selectedLanguage
                        )
                        if householdProfile.countryCode == "NO" {
                            PublicSheltersSection(language: selectedLanguage)
                        }
                    }
                }

                Tab(contactsTabTitle, systemImage: "person.2.fill", value: DashboardTab.contacts) {
                    dashboardScrollView {
                        ContactsSection(
                            familyContacts: familyContacts,
                            importantNumbers: importantNumbers,
                            language: selectedLanguage,
                            addFamily: addFamilyContact,
                            addImportant: addImportantNumber,
                            deleteFamily: deleteFamilyContact,
                            deleteImportant: deleteImportantNumber
                        )
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedTab == .supplies {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                addRecommendedHomeSupplies()
                            } label: {
                                Label(addRecommendedTitle, systemImage: "checkmark.circle")
                            }
                            .disabled(!hasRecommendedSupplyUpdates)

                            Button {
                                presentNewSupplyEditor(for: .home)
                            } label: {
                                Label(addHomeSupplyTitle, systemImage: "house.fill")
                            }

                            Button {
                                presentNewSupplyEditor(for: .car)
                            } label: {
                                Label(addCarSupplyTitle, systemImage: "car.fill")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel(addSupplyMenuTitle)
                        .accessibilityIdentifier("addSupplyMenu")
                    }
                }
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
                    .accessibilityLabel("\(languageMenuTitle): \(selectedLanguage.displayName)")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel(settingsButtonTitle)
                    .accessibilityIdentifier("settingsButton")
                }
            }
        }
        .environment(\.locale, AppLanguage.locale(for: selectedLanguage))
        .preferredColorScheme(selectedAppearance.preferredColorScheme)
        .sheet(isPresented: $showingSettings) {
            SettingsSheet(
                selectedLanguage: $selectedLanguage,
                selectedAppearance: $preferredAppearance,
                includePlanSummaryInMessages: $includePlanSummaryInMessages,
                showOnlyMissingSupplies: $showOnlyMissingSupplies,
                offlineFirstMode: $offlineFirstMode,
                supplyReviewRemindersEnabled: $supplyReviewRemindersEnabled,
                householdProfile: $householdProfile,
                sendTestReminder: sendTestSupplyReminder,
                showOnboarding: { showingOnboarding = true },
                exportBackup: prepareBackupExport,
                importBackup: { showingBackupImporter = true },
                resetLocalData: resetLocalData,
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
        .sheet(isPresented: $showingNewSupplyEditor) {
            NewSupplySheet(
                location: newSupplyLocation,
                language: selectedLanguage,
                save: saveNewSupply
            )
            .presentationDetents([.medium, .large])
        }
        .task {
            seedDataIfNeeded()
            ensureEmergencyPlans()
            householdProfile = HouseholdProfileStore.load()
            paymentPreparedness = PaymentPreparednessStore.load(
                countryCode: householdProfile.countryCode
            )
            householdMemberCount = householdProfile.householdSize
            selectedLanguage = AppLanguage(rawValue: preferredLanguageCode) ?? .current
            relocalizeDefaultSupplies(to: selectedLanguage)
            if !hasSeenOnboarding {
                showingOnboarding = true
            }
            if supplyReviewRemindersEnabled {
                await synchronizeSupplyReminders(requestAuthorization: false)
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
        .alert(backupImportConfirmationTitle, isPresented: $showingBackupImportConfirmation) {
            Button(backupImportReplaceTitle, role: .destructive) {
                confirmBackupImport()
            }
            Button(backupImportCancelTitle, role: .cancel) {
                pendingBackupPayload = nil
            }
        } message: {
            Text(backupImportConfirmationMessage)
        }
        .alert(transferAlertTitle, isPresented: $showingTransferAlert) {
            Button(alertDoneTitle, role: .cancel) {}
        } message: {
            Text(transferMessage ?? "")
        }
        .alert(supplyErrorTitle, isPresented: $showingSupplyError) {
            Button(alertDoneTitle, role: .cancel) {}
        } message: {
            Text(supplyErrorMessage ?? "")
        }
        .alert(reminderAlertTitle, isPresented: $showingReminderAlert) {
            if showsReminderSettingsAction {
                Button(openNotificationSettingsTitle) {
                    showsReminderSettingsAction = false
                    guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
                    openURL(settingsURL)
                }
            }
            Button(alertDoneTitle, role: .cancel) {
                showsReminderSettingsAction = false
                guard schedulesTestReminderOnAlertDismiss else { return }
                schedulesTestReminderOnAlertDismiss = false
                scheduleTestSupplyReminder()
            }
        } message: {
            Text(reminderMessage ?? "")
        }
        .onChange(of: selectedLanguage) { _, newValue in
            preferredLanguageCode = newValue.rawValue
            relocalizeDefaultSupplies(to: newValue)
        }
        .onChange(of: selectedEmergencyType) { _, _ in
            ensureEmergencyPlans()
        }
        .onChange(of: householdMemberCount) { oldValue, newValue in
            updateGeneratedWaterQuantity(from: oldValue, to: newValue)
            if householdProfile.householdSize != newValue {
                householdProfile.householdSize = newValue
            }
        }
        .onChange(of: householdProfile) { _, newValue in
            HouseholdProfileStore.save(newValue)
            if householdMemberCount != newValue.householdSize {
                householdMemberCount = newValue.householdSize
            }
        }
        .onChange(of: paymentPreparedness) { _, newValue in
            PaymentPreparednessStore.save(newValue)
        }
        .onChange(of: supplyReviewRemindersEnabled) { _, isEnabled in
            Task {
                if isEnabled {
                    await synchronizeSupplyReminders(requestAuthorization: true)
                } else {
                    await SupplyReminderScheduler.removePendingReminders()
                }
            }
        }
        .onChange(of: supplyReminderFingerprint) { _, _ in
            guard supplyReviewRemindersEnabled else { return }
            Task { await synchronizeSupplyReminders(requestAuthorization: false) }
        }
    }

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: preferredAppearance) ?? .system
    }

    private func dashboardScrollView<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content()
            }
            .padding(20)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 220 : 160)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(backgroundGradient)
    }

    private var navigationTitle: String {
        switch selectedTab {
        case .overview: "Disaster Ready"
        case .plan: planTabTitle
        case .supplies: suppliesTabTitle
        case .contacts: contactsTabTitle
        }
    }

    private var overviewTabTitle: String {
        L10n.pick(language: selectedLanguage, english: "Overview", norwegian: "Oversikt", thai: "ภาพรวม")
    }

    private var planTabTitle: String {
        L10n.pick(language: selectedLanguage, english: "Plan", norwegian: "Plan", thai: "แผน")
    }

    private var suppliesTabTitle: String {
        L10n.pick(language: selectedLanguage, english: "Supplies", norwegian: "Utstyr", thai: "อุปกรณ์")
    }

    private var contactsTabTitle: String {
        L10n.pick(language: selectedLanguage, english: "Contacts", norwegian: "Kontakter", thai: "ผู้ติดต่อ")
    }

    private var languageMenuTitle: String {
        L10n.pick(language: selectedLanguage, english: "Language", norwegian: "Språk", thai: "ภาษา")
    }

    private var settingsButtonTitle: String {
        L10n.pick(language: selectedLanguage, english: "Settings", norwegian: "Innstillinger", thai: "การตั้งค่า")
    }

    private var addSupplyMenuTitle: String {
        L10n.pick(language: selectedLanguage, english: "Add supplies", norwegian: "Legg til utstyr", thai: "เพิ่มอุปกรณ์")
    }

    private var addRecommendedTitle: String {
        L10n.pick(language: selectedLanguage, english: "Add recommended items", norwegian: "Legg til anbefalte varer", thai: "เพิ่มรายการแนะนำ")
    }

    private var addHomeSupplyTitle: String {
        L10n.pick(language: selectedLanguage, english: "New home item", norwegian: "Nytt hjemmeutstyr", thai: "อุปกรณ์ในบ้านใหม่")
    }

    private var addCarSupplyTitle: String {
        L10n.pick(
            language: selectedLanguage,
            english: "New grab / evacuation item",
            norwegian: "Nytt evakueringsutstyr",
            thai: "อุปกรณ์อพยพใหม่"
        )
    }

    private var supplyReviewReminders: [SupplyReviewReminder] {
        supplies.compactMap { item in
            guard let reviewDate = item.reviewDate else { return nil }
            return SupplyReviewReminder(id: item.id, name: item.name, reviewDate: reviewDate)
        }
    }

    private var supplyReminderFingerprint: String {
        supplyReviewReminders
            .map { "\($0.id.uuidString)|\($0.name)|\($0.reviewDate.timeIntervalSinceReferenceDate)" }
            .sorted()
            .joined(separator: ";")
    }

    private var reminderAlertTitle: String {
        L10n.pick(language: selectedLanguage, english: "Reminders", norwegian: "Påminnelser", thai: "การแจ้งเตือน")
    }

    private var openNotificationSettingsTitle: String {
        L10n.pick(
            language: selectedLanguage,
            english: "Open Settings",
            norwegian: "Åpne Innstillinger",
            thai: "เปิดการตั้งค่า"
        )
    }

    private func sendTestSupplyReminder() {
        showsReminderSettingsAction = false
        reminderMessage = L10n.pick(
            language: selectedLanguage,
            english: "Tap OK, then leave the app. A test reminder will appear in five seconds.",
            norwegian: "Trykk OK, og forlat deretter appen. En testpåminnelse vises om fem sekunder.",
            thai: "แตะตกลง แล้วออกจากแอป การแจ้งเตือนทดสอบจะแสดงในอีกห้าวินาที"
        )
        schedulesTestReminderOnAlertDismiss = true
        showingReminderAlert = true
    }

    private func scheduleTestSupplyReminder() {
        Task {
            do {
                let wasScheduled = try await SupplyReminderScheduler.scheduleTestNotification(
                    language: selectedLanguage
                )
                guard !wasScheduled else { return }
                showsReminderSettingsAction = true
                reminderMessage = L10n.pick(
                    language: selectedLanguage,
                    english: "Notifications are disabled in system settings.",
                    norwegian: "Varslinger er slått av i systeminnstillingene.",
                    thai: "การแจ้งเตือนถูกปิดในการตั้งค่าระบบ"
                )
                showingReminderAlert = true
            } catch {
                showsReminderSettingsAction = false
                reminderMessage = error.localizedDescription
                showingReminderAlert = true
            }
        }
    }

    @MainActor
    private func synchronizeSupplyReminders(requestAuthorization: Bool) async {
        showsReminderSettingsAction = false
        do {
            let wasEnabled = try await SupplyReminderScheduler.requestAuthorizationAndSchedule(
                reminders: supplyReviewReminders,
                language: selectedLanguage
            )
            guard wasEnabled else {
                supplyReviewRemindersEnabled = false
                if requestAuthorization {
                    showsReminderSettingsAction = true
                    reminderMessage = L10n.pick(
                        language: selectedLanguage,
                        english: "Notifications are disabled. You can allow them in system settings.",
                        norwegian: "Varslinger er slått av. Du kan tillate dem i systeminnstillingene.",
                        thai: "การแจ้งเตือนถูกปิด คุณสามารถอนุญาตได้ในการตั้งค่าระบบ"
                    )
                    showingReminderAlert = true
                }
                return
            }
        } catch {
            supplyReviewRemindersEnabled = false
            reminderMessage = error.localizedDescription
            showingReminderAlert = true
        }
    }

    private var completedPlanItems: Int {
        guard let plan = currentEmergencyPlan else { return 0 }
        return [plan.reunionPoint, plan.evacuationDestination, plan.shelterZone]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.08, green: 0.11, blue: 0.14),
                    Color(red: 0.12, green: 0.18, blue: 0.22),
                    Color(red: 0.20, green: 0.16, blue: 0.12)
                ]
                : [
                    Color(red: 0.95, green: 0.92, blue: 0.86),
                    Color(red: 0.80, green: 0.86, blue: 0.86),
                    Color(red: 0.22, green: 0.29, blue: 0.34)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
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

    private var homeSupplyRecommendations: [TemplateSupplyItem] {
        SupplyPrioritizer.prioritizedSupplies(
            for: selectedEmergencyType,
            household: householdProfile
        )
    }

    private var evacuationSupplyRecommendations: [TemplateSupplyItem] {
        SupplyPrioritizer.prioritizedEvacuationSupplies(
            for: selectedEmergencyType,
            household: householdProfile
        )
    }

    private var homeSupplies: [SupplyItem] {
        prioritizedSupplies(
            supplies.filter { $0.storageLocation == SupplyLocation.home.rawValue }
        )
    }

    private var carSupplies: [SupplyItem] {
        prioritizedSupplies(
            supplies.filter { $0.storageLocation == SupplyLocation.car.rawValue }
        )
    }

    private func prioritizedSupplies(_ items: [SupplyItem]) -> [SupplyItem] {
        items.sorted { first, second in
            let firstPriority = supplyPriority(first)
            let secondPriority = supplyPriority(second)

            if firstPriority != secondPriority {
                return firstPriority < secondPriority
            }

            if let firstDate = first.reviewDate, let secondDate = second.reviewDate, firstDate != secondDate {
                return firstDate < secondDate
            }

            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
    }

    private func supplyPriority(_ item: SupplyItem) -> Int {
        switch item.reviewStatus() {
        case .overdue:
            return 0
        case .dueSoon:
            return 1
        case .none, .scheduled:
            return item.isPacked ? 3 : 2
        }
    }

    private var supplyCompletionCount: Int {
        homeSupplies.filter(\.isPacked).count + carSupplies.filter(\.isPacked).count
    }

    private var suppliesNeedingReviewCount: Int {
        supplies.filter {
            let status = $0.reviewStatus()
            return status == .overdue || status == .dueSoon
        }.count
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
            selectedEmergencyType.localizedName(in: selectedLanguage),
            reunion,
            evacuation,
            shelter
        )
    }

    private func saveCurrentPlan() -> Bool {
        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }

    private func messageBody(for template: FamilyMessageTemplate) -> String {
        var lines = [
            template.body,
            "\(L10n.text("scenario", language: selectedLanguage)): \(selectedEmergencyType.localizedName(in: selectedLanguage))",
            "\(L10n.text("action", language: selectedLanguage)): \(selectedEmergencyType.preparationGuidance(in: selectedLanguage))"
        ]

        if includePlanSummaryInMessages, let plan = currentEmergencyPlan {
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

    private func presentNewSupplyEditor(for location: SupplyLocation) {
        newSupplyLocation = location
        showingNewSupplyEditor = true
    }

    private func saveNewSupply(
        name: String,
        quantity: String,
        detail: String,
        reviewDate: Date?
    ) -> Bool {
        let item = SupplyItem(
            name: name,
            detail: detail,
            isPacked: false,
            storageLocation: newSupplyLocation.rawValue,
            quantity: quantity,
            reviewDate: reviewDate
        )
        modelContext.insert(item)

        do {
            try modelContext.save()
            return true
        } catch {
            modelContext.delete(item)
            supplyErrorMessage = error.localizedDescription
            showingSupplyError = true
            return false
        }
    }

    private func addSmartHomeSupplies() {
        addSupplyRecommendations(
            homeSupplyRecommendations,
            location: .home
        )
    }

    private func addSmartEvacuationSupplies() {
        addSupplyRecommendations(
            evacuationSupplyRecommendations,
            location: .car
        )
    }

    private func addSupplyRecommendations(
        _ recommendations: [TemplateSupplyItem],
        location: SupplyLocation
    ) {
        var existingNames = Set(
            supplies
                .filter { $0.storageLocation == location.rawValue }
                .map { $0.name.localizedLowercase }
        )
        let detail = L10n.pick(
            language: selectedLanguage,
            english: "Recommended for your household and selected emergency.",
            norwegian: "Anbefalt for husstanden og valgt hendelse.",
            thai: "แนะนำสำหรับครัวเรือนและเหตุฉุกเฉินที่เลือก"
        )

        for recommendation in recommendations {
            let name = recommendation.localizedName(in: selectedLanguage)
            guard !existingNames.contains(name.localizedLowercase) else { continue }
            existingNames.insert(name.localizedLowercase)

            modelContext.insert(
                SupplyItem(
                    name: name,
                    detail: detail,
                    isPacked: false,
                    storageLocation: location.rawValue,
                    quantity: recommendation.id == "water" ? recommendedWaterQuantity : ""
                )
            )
        }
    }

    private func addRecommendedHomeSupplies() {
        for key in recommendedHomeSupplyKeys {
            if let existingItem = homeSupplies.first(where: {
                localizedSupplyNames(for: key).contains($0.name.trimmingCharacters(in: .whitespacesAndNewlines))
            }) {
                if existingItem.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    existingItem.quantity = recommendedQuantity(for: key)
                }
            } else {
                modelContext.insert(
                    recommendedHomeSupply(
                        key,
                        detailKey: key + "_detail",
                        quantity: recommendedQuantity(for: key)
                    )
                )
            }
        }
    }

    private func addHouseholdRole() {
        modelContext.insert(
            HouseholdRole(
                title: "",
                person: "",
                task: "",
                systemImage: "person.fill"
            )
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

    private func deleteHouseholdRole(_ role: HouseholdRole) {
        modelContext.delete(role)
    }

    private func prepareBackupExport() {
        backupDocument = DisasterBackupDocument(
            payload: DisasterBackupPayload(
                householdMemberCount: householdMemberCount,
                householdProfile: householdProfile,
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
                        scenarioIdentifier: $0.scenarioIdentifier,
                        reunionPoint: $0.reunionPoint,
                        evacuationDestination: $0.evacuationDestination,
                        shelterZone: $0.shelterZone,
                        gasShutoffNote: $0.gasShutoffNote,
                        medicalLead: $0.medicalLead,
                        petLead: $0.petLead,
                        familyPassword: $0.familyPassword,
                        alternativeAccommodation: $0.alternativeAccommodation,
                        familyFriendLocation: $0.familyFriendLocation,
                        secondaryHome: $0.secondaryHome,
                        safePlaceNote: $0.safePlaceNote,
                        waterStopcockNote: $0.waterStopcockNote,
                        mainElectricalPanelNote: $0.mainElectricalPanelNote
                    )
                },
                householdRoles: householdRoles.map {
                    HouseholdRoleSnapshot(
                        title: $0.title,
                        person: $0.person,
                        task: $0.task,
                        systemImage: $0.systemImage
                    )
                },
                supplies: (homeSupplies + carSupplies).map {
                    SupplyItemSnapshot(
                        name: $0.name,
                        detail: $0.detail,
                        isPacked: $0.isPacked,
                        storageLocation: $0.storageLocation,
                        quantity: $0.quantity,
                        reviewDate: $0.reviewDate
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
                let payload = try DisasterBackupPayload.decode(from: data)
                try payload.validateForImport()
                pendingBackupPayload = payload
                showingBackupImportConfirmation = true
                return
            } catch let validationError as DisasterBackupValidationError {
                transferMessage = backupValidationMessage(for: validationError)
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

    private func backupValidationMessage(for error: DisasterBackupValidationError) -> String {
        switch error {
        case .emptyBackup:
            return L10n.pick(
                language: selectedLanguage,
                english: "The backup contains no plans, contacts, roles, or supplies and was not imported.",
                norwegian: "Sikkerhetskopien inneholder ingen planer, kontakter, roller eller utstyr og ble ikke importert.",
                thai: "ข้อมูลสำรองไม่มีแผน รายชื่อติดต่อ บทบาท หรืออุปกรณ์ จึงไม่ได้นำเข้า"
            )
        case .invalidSupplyLocation:
            return L10n.pick(
                language: selectedLanguage,
                english: "The backup contains an unknown supply location and was not imported.",
                norwegian: "Sikkerhetskopien inneholder en ukjent lagringsplass for utstyr og ble ikke importert.",
                thai: "ข้อมูลสำรองมีตำแหน่งจัดเก็บอุปกรณ์ที่ไม่รู้จัก จึงไม่ได้นำเข้า"
            )
        case .unsupportedSchemaVersion(let version):
            return L10n.pick(
                language: selectedLanguage,
                english: "This backup uses format version \(version), which this app cannot import. Update the app and try again.",
                norwegian: "Sikkerhetskopien bruker formatversjon \(version), som denne appen ikke kan importere. Oppdater appen og prøv igjen.",
                thai: "ข้อมูลสำรองใช้รูปแบบเวอร์ชัน \(version) ซึ่งแอปนี้นำเข้าไม่ได้ โปรดอัปเดตแอปแล้วลองอีกครั้ง"
            )
        case .invalidHouseholdMemberCount:
            return L10n.pick(
                language: selectedLanguage,
                english: "The backup contains an invalid household size and was not imported.",
                norwegian: "Sikkerhetskopien inneholder et ugyldig antall personer i husstanden og ble ikke importert.",
                thai: "ข้อมูลสำรองมีจำนวนสมาชิกในครัวเรือนที่ไม่ถูกต้อง จึงไม่ได้นำเข้า"
            )
        }
    }

    private func confirmBackupImport() {
        guard let payload = pendingBackupPayload else { return }
        pendingBackupPayload = nil

        do {
            try restore(from: payload)
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "Backup imported and local data restored.",
                norwegian: "Sikkerhetskopi importert og lokale data gjenopprettet.",
                thai: "นำเข้าข้อมูลสำรองและกู้คืนข้อมูลในเครื่องแล้ว"
            )
        } catch {
            modelContext.rollback()
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "The backup could not be saved. Your previous local data was restored.",
                norwegian: "Sikkerhetskopien kunne ikke lagres. De tidligere lokale dataene ble gjenopprettet.",
                thai: "ไม่สามารถบันทึกข้อมูลสำรองได้ ระบบได้กู้คืนข้อมูลเดิมในเครื่องแล้ว"
            )
        }

        Task { @MainActor in
            await Task.yield()
            showingTransferAlert = true
        }
    }

    private func resetLocalData() {
        do {
            try modelContext.transaction {
                familyContacts.forEach(modelContext.delete)
                importantNumbers.forEach(modelContext.delete)
                householdPlans.forEach(modelContext.delete)
                householdRoles.forEach(modelContext.delete)
                supplies.forEach(modelContext.delete)
            }

            householdMemberCount = 1
            showOnlyMissingSupplies = false
            supplyReviewRemindersEnabled = false

            Task { @MainActor in
                await SupplyReminderScheduler.removePendingReminders()
                await Task.yield()
                seedDataIfNeeded()
                ensureEmergencyPlans()
                transferMessage = L10n.pick(
                    language: selectedLanguage,
                    english: "Default local data was restored.",
                    norwegian: "Standarddataene på enheten ble gjenopprettet.",
                    thai: "กู้คืนข้อมูลเริ่มต้นในเครื่องแล้ว"
                )
                showingTransferAlert = true
            }
        } catch {
            modelContext.rollback()
            transferMessage = L10n.pick(
                language: selectedLanguage,
                english: "The data could not be reset. Your existing local data was kept.",
                norwegian: "Dataene kunne ikke tilbakestilles. De eksisterende lokale dataene ble beholdt.",
                thai: "ไม่สามารถรีเซ็ตข้อมูลได้ ข้อมูลเดิมในเครื่องยังคงอยู่"
            )
            showingTransferAlert = true
        }
    }

    private func restore(from payload: DisasterBackupPayload) throws {
        try modelContext.transaction {
            familyContacts.forEach(modelContext.delete)
            importantNumbers.forEach(modelContext.delete)
            householdPlans.forEach(modelContext.delete)
            householdRoles.forEach(modelContext.delete)
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
                        scenarioIdentifier: $0.scenarioIdentifier,
                        reunionPoint: $0.reunionPoint,
                        evacuationDestination: $0.evacuationDestination,
                        shelterZone: $0.shelterZone,
                        gasShutoffNote: $0.gasShutoffNote,
                        medicalLead: $0.medicalLead,
                        petLead: $0.petLead,
                        familyPassword: $0.familyPassword,
                        alternativeAccommodation: $0.alternativeAccommodation,
                        familyFriendLocation: $0.familyFriendLocation,
                        secondaryHome: $0.secondaryHome,
                        safePlaceNote: $0.safePlaceNote,
                        waterStopcockNote: $0.waterStopcockNote,
                        mainElectricalPanelNote: $0.mainElectricalPanelNote
                    )
                }
                .forEach(modelContext.insert)
            payload.householdRoles
                .map {
                    HouseholdRole(
                        title: $0.title,
                        person: $0.person,
                        task: $0.task,
                        systemImage: $0.systemImage
                    )
                }
                .forEach(modelContext.insert)
            payload.supplies
                .map {
                    SupplyItem(
                        name: $0.name,
                        detail: $0.detail,
                        isPacked: $0.isPacked,
                        storageLocation: $0.storageLocation,
                        quantity: $0.quantity ?? "",
                        reviewDate: $0.reviewDate
                    )
                }
                .forEach(modelContext.insert)
        }

        if let restoredProfile = payload.householdProfile {
            householdProfile = restoredProfile
            HouseholdProfileStore.save(restoredProfile)
            householdMemberCount = restoredProfile.householdSize
        } else if let restoredHouseholdMemberCount = payload.householdMemberCount {
            householdMemberCount = restoredHouseholdMemberCount
            householdProfile.householdSize = restoredHouseholdMemberCount
            HouseholdProfileStore.save(householdProfile)
        }
    }

    private func seedDataIfNeeded() {
        guard familyContacts.isEmpty, importantNumbers.isEmpty, householdPlans.isEmpty, householdRoles.isEmpty, homeSupplies.isEmpty, carSupplies.isEmpty else {
            return
        }

        defaultFamilyContacts.forEach(modelContext.insert)
        defaultImportantNumbers.forEach(modelContext.insert)
        defaultHouseholdPlans.forEach(modelContext.insert)
        defaultHouseholdRoles.forEach(modelContext.insert)
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
                label: L10n.pick(
                    language: selectedLanguage,
                    english: "Ambulance",
                    norwegian: "Ambulanse",
                    thai: "รถพยาบาล"
                ),
                phoneNumber: "113",
                notes: L10n.pick(
                    language: selectedLanguage,
                    english: "Medical emergency dispatch.",
                    norwegian: "Medisinsk nødtelefon.",
                    thai: "สายด่วนเหตุฉุกเฉินทางการแพทย์"
                )
            ),
            ImportantNumber(
                label: L10n.pick(
                    language: selectedLanguage,
                    english: "Fire",
                    norwegian: "Brann",
                    thai: "ดับเพลิง"
                ),
                phoneNumber: "110",
                notes: L10n.pick(
                    language: selectedLanguage,
                    english: "Fire and rescue emergency dispatch.",
                    norwegian: "Nødtelefon for brann og redning.",
                    thai: "สายด่วนเหตุฉุกเฉินด้านเพลิงไหม้และกู้ภัย"
                )
            ),
            ImportantNumber(
                label: L10n.pick(
                    language: selectedLanguage,
                    english: "Police",
                    norwegian: "Politi",
                    thai: "ตำรวจ"
                ),
                phoneNumber: "112",
                notes: L10n.pick(
                    language: selectedLanguage,
                    english: "Police emergency dispatch.",
                    norwegian: "Politiets nødtelefon.",
                    thai: "สายด่วนเหตุตำรวจ"
                )
            ),
            ImportantNumber(
                label: L10n.pick(
                    language: selectedLanguage,
                    english: "Poison information",
                    norwegian: "Giftinformasjon",
                    thai: "ข้อมูลพิษวิทยา"
                ),
                phoneNumber: "22 59 13 00",
                notes: L10n.pick(
                    language: selectedLanguage,
                    english: "Poison information hotline.",
                    norwegian: "Giftinformasjonens døgnåpne telefon.",
                    thai: "สายด่วนข้อมูลพิษวิทยา"
                )
            )
        ]
    }

    private var currentEmergencyPlan: HouseholdPlan? {
        householdPlans.first { $0.scenarioIdentifier == selectedEmergencyType.rawValue }
            ?? householdPlans.first {
                EmergencyType.migrated(fromLegacyIdentifier: $0.scenarioIdentifier) == selectedEmergencyType
            }
    }

    private var defaultHouseholdPlans: [HouseholdPlan] {
        EmergencyType.allCases.map { emergencyType in
            HouseholdPlan(
                scenarioIdentifier: emergencyType.rawValue,
                reunionPoint: "",
                evacuationDestination: "",
                shelterZone: "",
                gasShutoffNote: "",
                medicalLead: "",
                petLead: "",
                familyPassword: ""
            )
        }
    }

    private func ensureEmergencyPlans() {
        let missingEmergencyTypes = EmergencyPlanMigration.missingEmergencyTypes(
            for: householdPlans.map(\.scenarioIdentifier)
        )

        for emergencyType in missingEmergencyTypes {
            modelContext.insert(
                HouseholdPlan(
                    scenarioIdentifier: emergencyType.rawValue,
                    reunionPoint: "",
                    evacuationDestination: "",
                    shelterZone: "",
                    gasShutoffNote: "",
                    medicalLead: "",
                    petLead: "",
                    familyPassword: ""
                )
            )
        }
    }

    private var defaultHouseholdRoles: [HouseholdRole] {
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

    private var defaultHomeSupplies: [SupplyItem] {
        [
            recommendedHomeSupply("supply_water", detailKey: "supply_water_detail", quantity: recommendedWaterQuantity),
            recommendedHomeSupply("supply_shelf_food", detailKey: "supply_shelf_food_detail", quantity: recommendedFoodQuantity),
            recommendedHomeSupply("supply_cooking_backup", detailKey: "supply_cooking_backup_detail", quantity: recommendedCookingQuantity),
            recommendedHomeSupply("supply_medical_kit", detailKey: "supply_medical_kit_detail", quantity: recommendedMedicalQuantity),
            recommendedHomeSupply("supply_power_light", detailKey: "supply_power_light_detail", quantity: recommendedPowerQuantity),
            recommendedHomeSupply("supply_warmth_shelter", detailKey: "supply_warmth_shelter_detail", quantity: recommendedWarmthQuantity)
        ]
    }

    private func recommendedHomeSupply(
        _ nameKey: String,
        detailKey: String,
        quantity: String
    ) -> SupplyItem {
        SupplyItem(
            name: L10n.text(nameKey, language: selectedLanguage),
            detail: L10n.text(detailKey, language: selectedLanguage),
            isPacked: false,
            storageLocation: SupplyLocation.home.rawValue,
            quantity: quantity
        )
    }

    private var recommendedWaterQuantity: String {
        generatedWaterQuantity(for: householdMemberCount, language: selectedLanguage)
    }

    private func updateGeneratedWaterQuantity(from oldCount: Int, to newCount: Int) {
        let previousGeneratedValues = Set(
            AppLanguage.allCases.map { generatedWaterQuantity(for: oldCount, language: $0) }
        )

        homeSupplies
            .filter {
                localizedSupplyNames(for: "supply_water").contains(
                    $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .filter {
                previousGeneratedValues.contains(
                    $0.quantity.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .forEach {
                $0.quantity = generatedWaterQuantity(for: newCount, language: selectedLanguage)
            }
    }

    private func generatedWaterQuantity(for count: Int, language: AppLanguage) -> String {
        return L10n.pick(
            language: language,
            english: "\(count * 20) liters",
            norwegian: "\(count * 20) liter",
            thai: "\(count * 20) ลิตร"
        )
    }

    private var recommendedFoodQuantity: String {
        L10n.pick(
            language: selectedLanguage,
            english: "7 days per person",
            norwegian: "7 dager per person",
            thai: "7 วันต่อคน"
        )
    }

    private var recommendedCookingQuantity: String {
        L10n.pick(
            language: selectedLanguage,
            english: "1 alternative",
            norwegian: "1 alternativ",
            thai: "1 ทางเลือก"
        )
    }

    private var recommendedMedicalQuantity: String {
        L10n.pick(language: selectedLanguage, english: "1 kit", norwegian: "1 sett", thai: "1 ชุด")
    }

    private var recommendedPowerQuantity: String {
        L10n.pick(
            language: selectedLanguage,
            english: "1 flashlight per person",
            norwegian: "1 lommelykt per person",
            thai: "ไฟฉาย 1 กระบอกต่อคน"
        )
    }

    private var recommendedWarmthQuantity: String {
        L10n.pick(
            language: selectedLanguage,
            english: "1 sleeping bag per person",
            norwegian: "1 sovepose per person",
            thai: "ถุงนอน 1 ใบต่อคน"
        )
    }

    private var recommendedHomeSupplyKeys: [String] {
        [
            "supply_water",
            "supply_shelf_food",
            "supply_cooking_backup",
            "supply_medical_kit",
            "supply_power_light",
            "supply_warmth_shelter"
        ]
    }

    private var missingRecommendedSupplyKeys: [String] {
        let existingNames = Set(homeSupplies.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) })
        return recommendedHomeSupplyKeys.filter { key in
            existingNames.isDisjoint(with: localizedSupplyNames(for: key))
        }
    }

    private var hasRecommendedSupplyUpdates: Bool {
        if !missingRecommendedSupplyKeys.isEmpty {
            return true
        }

        return recommendedHomeSupplyKeys.contains { key in
            homeSupplies.contains {
                localizedSupplyNames(for: key).contains($0.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    && $0.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }

    private func recommendedQuantity(for key: String) -> String {
        switch key {
        case "supply_water": recommendedWaterQuantity
        case "supply_shelf_food": recommendedFoodQuantity
        case "supply_cooking_backup": recommendedCookingQuantity
        case "supply_medical_kit": recommendedMedicalQuantity
        case "supply_power_light": recommendedPowerQuantity
        case "supply_warmth_shelter": recommendedWarmthQuantity
        default: ""
        }
    }

    private func localizedSupplyNames(for key: String) -> Set<String> {
        Set(AppLanguage.allCases.map { L10n.text(key, language: $0) })
    }

    private func relocalizeDefaultSupplies(to language: AppLanguage) {
        let localizedKeys = recommendedHomeSupplyKeys + [
            "supply_water_snacks",
            "supply_navigation",
            "supply_vehicle_recovery",
            "supply_weather_gear",
            "supply_safety_kit",
            "supply_phone_backup"
        ]

        for item in supplies {
            guard let key = localizedKeys.first(where: {
                localizedSupplyNames(for: $0).contains(item.name.trimmingCharacters(in: .whitespacesAndNewlines))
            }) else { continue }

            item.name = L10n.text(key, language: language)

            let detailKey = "\(key)_detail"
            let localizedDetails = Set(AppLanguage.allCases.map { L10n.text(detailKey, language: $0) })
            if localizedDetails.contains(item.detail.trimmingCharacters(in: .whitespacesAndNewlines)) {
                item.detail = L10n.text(detailKey, language: language)
            }
        }
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

    private var backupImportConfirmationTitle: String {
        L10n.pick(
            language: selectedLanguage,
            english: "Replace local data?",
            norwegian: "Erstatte lokale data?",
            thai: "แทนที่ข้อมูลในเครื่องหรือไม่"
        )
    }

    private var backupImportConfirmationMessage: String {
        guard let payload = pendingBackupPayload else {
            return L10n.pick(
                language: selectedLanguage,
                english: "Importing replaces the current local data on this device. This cannot be undone.",
                norwegian: "Import erstatter de lokale dataene på enheten. Dette kan ikke angres.",
                thai: "การนำเข้าจะแทนที่ข้อมูลในเครื่องปัจจุบัน และไม่สามารถย้อนกลับได้"
            )
        }

        let planCount = payload.householdPlans.count
        let contactCount = payload.familyContacts.count + payload.importantNumbers.count
        let roleCount = payload.householdRoles.count
        let supplyCount = payload.supplies.count

        return L10n.pick(
            language: selectedLanguage,
            english: "The backup contains \(planCount) plans, \(contactCount) contacts, \(roleCount) roles, and \(supplyCount) supplies. Importing replaces all current local data and cannot be undone.",
            norwegian: "Sikkerhetskopien inneholder \(planCount) planer, \(contactCount) kontakter, \(roleCount) roller og \(supplyCount) utstyrselementer. Import erstatter alle lokale data og kan ikke angres.",
            thai: "ข้อมูลสำรองมีแผน \(planCount) รายการ รายชื่อติดต่อ \(contactCount) รายการ บทบาท \(roleCount) รายการ และอุปกรณ์ \(supplyCount) รายการ การนำเข้าจะแทนที่ข้อมูลในเครื่องทั้งหมดและไม่สามารถย้อนกลับได้"
        )
    }

    private var backupImportReplaceTitle: String {
        L10n.pick(language: selectedLanguage, english: "Replace data", norwegian: "Erstatt data", thai: "แทนที่ข้อมูล")
    }

    private var backupImportCancelTitle: String {
        L10n.pick(language: selectedLanguage, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
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

    private var supplyErrorTitle: String {
        L10n.pick(language: selectedLanguage, english: "Could not save item", norwegian: "Kunne ikke lagre varen", thai: "ไม่สามารถบันทึกรายการได้")
    }
}

#Preview {
    DisasterDashboardView()
}
