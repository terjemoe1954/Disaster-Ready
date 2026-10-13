import SwiftUI

struct EmergencyModeLauncherSection: View {
    let language: AppLanguage
    let openEmergencyMode: () -> Void

    var body: some View {
        Button(action: openEmergencyMode) {
            HStack(spacing: 14) {
                Image(systemName: "sos.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.title3.weight(.bold))
                    Text(detail)
                        .font(.subheadline)
                        .opacity(0.9)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(.red.gradient, in: RoundedRectangle(cornerRadius: 18))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("openEmergencyModeButton")
    }

    private var title: String {
        L10n.pick(language: language, english: "When it happens", norwegian: "Når det skjer", thai: "เมื่อเกิดเหตุ")
    }

    private var detail: String {
        L10n.pick(
            language: language,
            english: "Open the essential actions, meeting point, and emergency numbers.",
            norwegian: "Åpne de viktigste handlingene, møtestedet og nødnumrene.",
            thai: "เปิดดูสิ่งที่ต้องทำ จุดนัดพบ และหมายเลขฉุกเฉิน"
        )
    }
}

struct HomeHouseholdSafetyStatusSection: View {
    @State private var showingEndConfirmation = false

    let snapshot: HouseholdSafetySnapshot
    let members: [FamilyContact]
    let scenarioName: String
    let meetingPoint: String
    let language: AppLanguage
    let openEmergencyMode: () -> Void
    let endIncident: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: openEmergencyMode) {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(statusColor)
                        .frame(width: 32)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(detail)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let updatedAt = snapshot.updatedAt {
                            Text(updatedAt, format: .dateTime.hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .environment(\.locale, AppLanguage.locale(for: language))
                        }
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("activeHouseholdStatus")

            Divider()
                .padding(.horizontal, 16)

            if !members.isEmpty {
                ShareLink(item: reportText) {
                    Label(shareTitle, systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .accessibilityIdentifier("shareActiveHouseholdStatus")

                Divider()
                    .padding(.horizontal, 16)
            }

            Button(role: .destructive) {
                showingEndConfirmation = true
            } label: {
                Label(endTitle, systemImage: "xmark.circle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .accessibilityIdentifier("endActiveIncident")
        }
        .background(DashboardCardBackground())
        .confirmationDialog(
            endConfirmationTitle,
            isPresented: $showingEndConfirmation,
            titleVisibility: .visible
        ) {
            Button(endTitle, role: .destructive, action: endIncident)
            Button(cancelTitle, role: .cancel) {}
        } message: {
            Text(endConfirmationMessage)
        }
    }

    private var currentStatuses: [HouseholdSafetyStatus] {
        members.map { snapshot.statuses[$0.id.uuidString] ?? .notChecked }
    }

    private var needsHelpCount: Int {
        currentStatuses.filter { $0 == .needsHelp }.count
    }

    private var unreachableCount: Int {
        currentStatuses.filter { $0 == .unreachable }.count
    }

    private var resolvedCount: Int {
        currentStatuses.filter { $0 != .notChecked }.count
    }

    private var statusColor: Color {
        if needsHelpCount > 0 { return .red }
        if unreachableCount > 0 { return .orange }
        return resolvedCount == members.count && !members.isEmpty ? .green : .blue
    }

    private var systemImage: String {
        if needsHelpCount > 0 { return "exclamationmark.triangle.fill" }
        if unreachableCount > 0 { return "phone.down.circle.fill" }
        return "person.3.fill"
    }

    private var detail: String {
        if needsHelpCount > 0 {
            return L10n.pick(language: language, english: "\(needsHelpCount) need help", norwegian: "\(needsHelpCount) trenger hjelp", thai: "\(needsHelpCount) คนต้องการความช่วยเหลือ")
        }
        if unreachableCount > 0 {
            return L10n.pick(language: language, english: "No contact with \(unreachableCount)", norwegian: "Ikke kontakt med \(unreachableCount)", thai: "ติดต่อไม่ได้ \(unreachableCount) คน")
        }
        return L10n.pick(
            language: language,
            english: "\(resolvedCount) of \(members.count) accounted for",
            norwegian: "\(resolvedCount) av \(members.count) er avklart",
            thai: "ตรวจสอบแล้ว \(resolvedCount) จาก \(members.count) คน"
        )
    }

    private var reportText: String {
        let reportDate = (snapshot.updatedAt ?? Date()).formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened)
                .locale(AppLanguage.locale(for: language))
        )
        var lines = [
            L10n.pick(language: language, english: "Household status", norwegian: "Status i husstanden", thai: "สถานะสมาชิกในบ้าน"),
            "\(L10n.text("scenario", language: language)): \(scenarioName)",
            L10n.pick(language: language, english: "Updated: \(reportDate)", norwegian: "Oppdatert: \(reportDate)", thai: "อัปเดต: \(reportDate)")
        ]

        if !meetingPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append(
                L10n.pick(
                    language: language,
                    english: "Meeting point: \(meetingPoint)",
                    norwegian: "Møtepunkt: \(meetingPoint)",
                    thai: "จุดนัดพบ: \(meetingPoint)"
                )
            )
        }

        lines.append("")
        lines.append(contentsOf: members.map { member in
            let status = snapshot.statuses[member.id.uuidString] ?? .notChecked
            return "• \(member.name): \(label(for: status))"
        })
        return lines.joined(separator: "\n")
    }

    private var title: String {
        L10n.pick(language: language, english: "Active household status", norwegian: "Aktiv husstandsstatus", thai: "สถานะสมาชิกในบ้านที่ใช้งานอยู่")
    }

    private var endTitle: String {
        L10n.pick(language: language, english: "End incident", norwegian: "Avslutt hendelse", thai: "สิ้นสุดเหตุการณ์")
    }

    private var shareTitle: String {
        L10n.pick(language: language, english: "Share status", norwegian: "Del status", thai: "แชร์สถานะ")
    }

    private func label(for status: HouseholdSafetyStatus) -> String {
        switch status {
        case .notChecked:
            L10n.pick(language: language, english: "Not checked", norwegian: "Ikke sjekket", thai: "ยังไม่ได้ตรวจสอบ")
        case .safe:
            L10n.pick(language: language, english: "Safe", norwegian: "Trygg", thai: "ปลอดภัย")
        case .needsHelp:
            L10n.pick(language: language, english: "Needs help", norwegian: "Trenger hjelp", thai: "ต้องการความช่วยเหลือ")
        case .unreachable:
            L10n.pick(language: language, english: "No contact", norwegian: "Ikke fått kontakt", thai: "ติดต่อไม่ได้")
        }
    }

    private var cancelTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }

    private var endConfirmationTitle: String {
        L10n.pick(language: language, english: "End the active incident?", norwegian: "Avslutt den aktive hendelsen?", thai: "สิ้นสุดเหตุการณ์ที่กำลังดำเนินอยู่หรือไม่")
    }

    private var endConfirmationMessage: String {
        L10n.pick(
            language: language,
            english: "The household statuses will be cleared. Your plan and contacts will not be changed.",
            norwegian: "Statusene i husstanden nullstilles. Planen og kontaktene dine blir ikke endret.",
            thai: "สถานะสมาชิกในบ้านจะถูกล้าง แต่แผนและรายชื่อผู้ติดต่อจะไม่เปลี่ยนแปลง"
        )
    }
}

struct EmergencyModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmergencyType: EmergencyType

    let plan: HouseholdPlan?
    let household: HouseholdProfile
    let familyContacts: [FamilyContact]
    let language: AppLanguage

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    EmergencyModeScenarioSection(
                        selection: $selectedEmergencyType,
                        language: language
                    )
                    EmergencyModeActionsSection(
                        emergencyType: selectedEmergencyType,
                        household: household,
                        language: language
                    )
                    EmergencyModeMeetingSection(
                        meetingPoint: plan?.reunionPoint ?? "",
                        evacuationDestination: plan?.evacuationDestination ?? "",
                        language: language
                    )
                    EmergencyModeHouseholdStatusSection(
                        members: familyContacts.filter(\.isHouseholdMember),
                        scenarioName: selectedEmergencyType.localizedName(in: language),
                        meetingPoint: plan?.reunionPoint ?? "",
                        language: language
                    )
                    EmergencyModeContactsSection(
                        familyContacts: familyContacts,
                        officialNumbers: CountryEmergencyConfigurationCatalog.numbers(
                            for: household.countryCode
                        ),
                        language: language
                    )
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(doneTitle) { dismiss() }
                }
            }
        }
    }

    private var title: String {
        L10n.pick(language: language, english: "Emergency mode", norwegian: "Når det skjer", thai: "โหมดฉุกเฉิน")
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จสิ้น")
    }
}

private struct EmergencyModeHouseholdStatusSection: View {
    @State private var statuses: [String: HouseholdSafetyStatus] = [:]
    @State private var updatedAt: Date?
    @State private var showingResetConfirmation = false

    let members: [FamilyContact]
    let scenarioName: String
    let meetingPoint: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: "person.3.fill")
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)

                Spacer()

                if !statuses.isEmpty {
                    Button(resetTitle) {
                        showingResetConfirmation = true
                    }
                        .font(.caption.weight(.semibold))
                }
            }

            if members.isEmpty {
                Text(emptyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HouseholdSafetySummaryView(
                    resolvedCount: resolvedCount,
                    totalCount: members.count,
                    needsHelpCount: needsHelpCount,
                    unreachableCount: unreachableCount,
                    language: language
                )

                ForEach(members) { member in
                    HouseholdSafetyStatusRow(
                        name: member.name,
                        phoneNumber: member.phoneNumber,
                        status: status(for: member),
                        language: language,
                        setStatus: { update($0, for: member) }
                    )
                }

                if let updatedAt {
                    Text(updatedText(for: updatedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ShareLink(item: reportText) {
                    Label(shareTitle, systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
            }
        }
        .emergencyModeCard()
        .task {
            let snapshot = HouseholdSafetyStatusStore.load()
            statuses = snapshot.statuses
            updatedAt = snapshot.updatedAt
        }
        .confirmationDialog(
            resetConfirmationTitle,
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(resetTitle, role: .destructive, action: reset)
            Button(cancelTitle, role: .cancel) {}
        } message: {
            Text(resetConfirmationMessage)
        }
    }

    private func status(for member: FamilyContact) -> HouseholdSafetyStatus {
        statuses[member.id.uuidString] ?? .notChecked
    }

    private func update(_ status: HouseholdSafetyStatus, for member: FamilyContact) {
        statuses[member.id.uuidString] = status
        updatedAt = Date()
        save()
    }

    private func reset() {
        statuses = [:]
        updatedAt = nil
        save()
    }

    private var resolvedCount: Int {
        members.filter { status(for: $0) != .notChecked }.count
    }

    private var needsHelpCount: Int {
        members.filter { status(for: $0) == .needsHelp }.count
    }

    private var unreachableCount: Int {
        members.filter { status(for: $0) == .unreachable }.count
    }

    private func save() {
        HouseholdSafetyStatusStore.save(
            HouseholdSafetySnapshot(statuses: statuses, updatedAt: updatedAt)
        )
    }

    private func updatedText(for date: Date) -> String {
        let formattedDate = date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened)
                .locale(AppLanguage.locale(for: language))
        )
        return L10n.pick(
            language: language,
            english: "Updated \(formattedDate)",
            norwegian: "Oppdatert \(formattedDate)",
            thai: "อัปเดต \(formattedDate)"
        )
    }

    private var reportText: String {
        let reportDate = (updatedAt ?? Date()).formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened)
                .locale(AppLanguage.locale(for: language))
        )
        var lines = [
            L10n.pick(language: language, english: "Household status", norwegian: "Status i husstanden", thai: "สถานะสมาชิกในบ้าน"),
            "\(L10n.text("scenario", language: language)): \(scenarioName)",
            L10n.pick(language: language, english: "Updated: \(reportDate)", norwegian: "Oppdatert: \(reportDate)", thai: "อัปเดต: \(reportDate)")
        ]

        if !meetingPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append(
                L10n.pick(
                    language: language,
                    english: "Meeting point: \(meetingPoint)",
                    norwegian: "Møtepunkt: \(meetingPoint)",
                    thai: "จุดนัดพบ: \(meetingPoint)"
                )
            )
        }

        lines.append("")
        lines.append(contentsOf: members.map { member in
            "• \(member.name): \(label(for: status(for: member)))"
        })
        return lines.joined(separator: "\n")
    }

    private var title: String {
        L10n.pick(language: language, english: "Household status", norwegian: "Status i husstanden", thai: "สถานะสมาชิกในบ้าน")
    }

    private var resetTitle: String {
        L10n.pick(language: language, english: "Reset", norwegian: "Nullstill", thai: "รีเซ็ต")
    }

    private var cancelTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }

    private var resetConfirmationTitle: String {
        L10n.pick(
            language: language,
            english: "Reset all household statuses?",
            norwegian: "Nullstill all status i husstanden?",
            thai: "รีเซ็ตสถานะสมาชิกในบ้านทั้งหมดหรือไม่"
        )
    }

    private var resetConfirmationMessage: String {
        L10n.pick(
            language: language,
            english: "Everyone will be marked as not checked. This cannot be undone.",
            norwegian: "Alle blir markert som ikke sjekket. Dette kan ikke angres.",
            thai: "ทุกคนจะถูกทำเครื่องหมายว่ายังไม่ได้ตรวจสอบ และไม่สามารถเลิกทำได้"
        )
    }

    private var shareTitle: String {
        L10n.pick(language: language, english: "Share status", norwegian: "Del status", thai: "แชร์สถานะ")
    }

    private var emptyText: String {
        L10n.pick(
            language: language,
            english: "Add household members under Contacts to use this overview.",
            norwegian: "Legg til husstandsmedlemmer under Kontakter for å bruke oversikten.",
            thai: "เพิ่มสมาชิกในบ้านใต้รายชื่อผู้ติดต่อเพื่อใช้ภาพรวมนี้"
        )
    }

    private func label(for status: HouseholdSafetyStatus) -> String {
        switch status {
        case .notChecked:
            L10n.pick(language: language, english: "Not checked", norwegian: "Ikke sjekket", thai: "ยังไม่ได้ตรวจสอบ")
        case .safe:
            L10n.pick(language: language, english: "Safe", norwegian: "Trygg", thai: "ปลอดภัย")
        case .needsHelp:
            L10n.pick(language: language, english: "Needs help", norwegian: "Trenger hjelp", thai: "ต้องการความช่วยเหลือ")
        case .unreachable:
            L10n.pick(language: language, english: "No contact", norwegian: "Ikke fått kontakt", thai: "ติดต่อไม่ได้")
        }
    }
}

private struct HouseholdSafetySummaryView: View {
    let resolvedCount: Int
    let totalCount: Int
    let needsHelpCount: Int
    let unreachableCount: Int
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progressText)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(resolvedCount)/\(totalCount)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(resolvedCount), total: Double(totalCount))
                .tint(progressColor)

            if needsHelpCount > 0 {
                Label(needsHelpText, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
            }

            if unreachableCount > 0 {
                Label(unreachableText, systemImage: "phone.down.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private var progressColor: Color {
        if needsHelpCount > 0 { return .red }
        if unreachableCount > 0 { return .orange }
        return resolvedCount == totalCount ? .green : .blue
    }

    private var progressText: String {
        if resolvedCount == totalCount {
            return L10n.pick(language: language, english: "Everyone accounted for", norwegian: "Alle er avklart", thai: "ตรวจสอบครบทุกคนแล้ว")
        }
        return L10n.pick(language: language, english: "People accounted for", norwegian: "Personer avklart", thai: "จำนวนคนที่ตรวจสอบแล้ว")
    }

    private var needsHelpText: String {
        L10n.pick(
            language: language,
            english: "\(needsHelpCount) need help",
            norwegian: "\(needsHelpCount) trenger hjelp",
            thai: "\(needsHelpCount) คนต้องการความช่วยเหลือ"
        )
    }

    private var unreachableText: String {
        L10n.pick(
            language: language,
            english: "No contact with \(unreachableCount)",
            norwegian: "Ikke kontakt med \(unreachableCount)",
            thai: "ติดต่อไม่ได้ \(unreachableCount) คน"
        )
    }
}

private struct HouseholdSafetyStatusRow: View {
    let name: String
    let phoneNumber: String
    let status: HouseholdSafetyStatus
    let language: AppLanguage
    let setStatus: (HouseholdSafetyStatus) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)
                .accessibilityHidden(true)

            Text(name)
                .font(.headline)
                .lineLimit(1)

            Spacer(minLength: 8)

            Menu {
                ForEach(HouseholdSafetyStatus.allCases) { option in
                    Button {
                        setStatus(option)
                    } label: {
                        Label(label(for: option), systemImage: systemImage(for: option))
                    }
                }
            } label: {
                Text(label(for: status))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(color.opacity(0.12), in: Capsule())
            }

            if let telephoneURL {
                Link(destination: telephoneURL) {
                    Image(systemName: "phone.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(callAccessibilityLabel)
            }
        }
    }

    private var systemImage: String { systemImage(for: status) }

    private var telephoneURL: URL? {
        let allowed = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard !allowed.isEmpty else { return nil }
        return URL(string: "tel:\(allowed)")
    }

    private var callAccessibilityLabel: String {
        L10n.pick(
            language: language,
            english: "Call \(name)",
            norwegian: "Ring \(name)",
            thai: "โทรหา \(name)"
        )
    }

    private var color: Color {
        switch status {
        case .notChecked: .secondary
        case .safe: .green
        case .needsHelp: .red
        case .unreachable: .orange
        }
    }

    private func systemImage(for status: HouseholdSafetyStatus) -> String {
        switch status {
        case .notChecked: "questionmark.circle.fill"
        case .safe: "checkmark.circle.fill"
        case .needsHelp: "exclamationmark.triangle.fill"
        case .unreachable: "phone.down.circle.fill"
        }
    }

    private func label(for status: HouseholdSafetyStatus) -> String {
        switch status {
        case .notChecked:
            L10n.pick(language: language, english: "Not checked", norwegian: "Ikke sjekket", thai: "ยังไม่ได้ตรวจสอบ")
        case .safe:
            L10n.pick(language: language, english: "Safe", norwegian: "Trygg", thai: "ปลอดภัย")
        case .needsHelp:
            L10n.pick(language: language, english: "Needs help", norwegian: "Trenger hjelp", thai: "ต้องการความช่วยเหลือ")
        case .unreachable:
            L10n.pick(language: language, english: "No contact", norwegian: "Ikke fått kontakt", thai: "ติดต่อไม่ได้")
        }
    }
}

private struct EmergencyModeScenarioSection: View {
    @Binding var selection: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Picker(title, selection: $selection) {
                ForEach(EmergencyType.allCases) { emergencyType in
                    Text(emergencyType.localizedName(in: language))
                        .tag(emergencyType)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .emergencyModeCard()
    }

    private var title: String {
        L10n.pick(language: language, english: "What is happening?", norwegian: "Hva skjer?", thai: "เกิดอะไรขึ้น")
    }
}

private struct EmergencyModeActionsSection: View {
    let emergencyType: EmergencyType
    let household: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "checklist")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            ForEach(template.actions.prefix(3)) { action in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.text(action.titleKey, language: language))
                            .font(.headline)
                        Text(L10n.text(action.detailKey, language: language))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .emergencyModeCard()
    }

    private var template: EmergencyPlanTemplate {
        EmergencyTemplateCatalog.provider(for: household.countryCode)?.template(
            for: emergencyType,
            household: household
        ) ?? NorwayEmergencyTemplates.template(for: emergencyType, household: household)
    }

    private var title: String {
        L10n.pick(language: language, english: "Do this first", norwegian: "Gjør dette først", thai: "ทำสิ่งนี้ก่อน")
    }
}

private struct EmergencyModeMeetingSection: View {
    let meetingPoint: String
    let evacuationDestination: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "mappin.and.ellipse")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            EmergencyModeValueRow(title: meetingTitle, value: meetingPoint, language: language)
            EmergencyModeValueRow(title: evacuationTitle, value: evacuationDestination, language: language)
        }
        .emergencyModeCard()
    }

    private var title: String {
        L10n.pick(language: language, english: "Where to meet or go", norwegian: "Hvor dere skal møtes eller dra", thai: "สถานที่นัดพบหรือไป")
    }

    private var meetingTitle: String {
        L10n.pick(language: language, english: "Meeting point", norwegian: "Møtested", thai: "จุดนัดพบ")
    }

    private var evacuationTitle: String {
        L10n.pick(language: language, english: "Evacuation destination", norwegian: "Evakueringssted", thai: "จุดอพยพ")
    }
}

private struct EmergencyModeValueRow: View {
    let title: String
    let value: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(displayValue)
                .font(.body.weight(.medium))
        }
        .accessibilityElement(children: .combine)
    }

    private var displayValue: String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? L10n.pick(language: language, english: "Not set", norwegian: "Ikke angitt", thai: "ยังไม่ได้ตั้งค่า")
            : value
    }
}

private struct EmergencyModeContactsSection: View {
    let familyContacts: [FamilyContact]
    let officialNumbers: [OfficialEmergencyNumber]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "phone.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            ForEach(officialNumbers) { number in
                emergencyLink(
                    title: EmergencyContactsLocalizationResources.text(number.titleKey, language: language),
                    number: number.number
                )
            }

            ForEach(familyContacts.prefix(3)) { contact in
                emergencyLink(title: contact.name, number: contact.phoneNumber)
            }
        }
        .emergencyModeCard()
    }

    @ViewBuilder
    private func emergencyLink(title: String, number: String) -> some View {
        if let url = telephoneURL(for: number) {
            Link(destination: url) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                        Text(number)
                            .font(.subheadline)
                    }
                    Spacer()
                    Image(systemName: "phone.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func telephoneURL(for number: String) -> URL? {
        let allowed = number.filter { $0.isNumber || $0 == "+" }
        guard !allowed.isEmpty else { return nil }
        return URL(string: "tel:\(allowed)")
    }

    private var title: String {
        L10n.pick(language: language, english: "Call", norwegian: "Ring", thai: "โทร")
    }
}

private extension View {
    func emergencyModeCard() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
