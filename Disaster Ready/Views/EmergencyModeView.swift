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
    @State private var completedActionIDs: Set<String> = []

    let plan: HouseholdPlan?
    let household: HouseholdProfile
    let familyContacts: [FamilyContact]
    let language: AppLanguage
    let openEmergencyPlan: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Text(doneTitle)
                                .font(.headline)
                                .foregroundStyle(Color(uiColor: .systemBackground))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.primary, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    EmergencyModeScenarioSection(
                        selection: $selectedEmergencyType,
                        language: language
                    )
                    OfflineGuidanceStatusSection(
                        sourceIDs: currentTemplate.sourceIDs,
                        language: language
                    )
                    EmergencyModeActionsSection(
                        emergencyType: selectedEmergencyType,
                        household: household,
                        language: language,
                        completedActionIDs: $completedActionIDs
                    )
                    EmergencyModeSectionHeading(
                        title: L10n.pick(language: language, english: "Find help", norwegian: "Finn hjelp", thai: "ค้นหาความช่วยเหลือ"),
                        systemImage: "location.fill"
                    )
                    EmergencyModeMeetingSection(
                        meetingPoint: plan?.reunionPoint ?? "",
                        evacuationDestination: plan?.evacuationDestination ?? "",
                        language: language
                    )
                    if selectedEmergencyType == .powerAndCommunicationsOutage {
                        CommunicationOutageOfflineSection(
                            meetingPoint: plan?.reunionPoint ?? "",
                            reservePlace: plan?.evacuationDestination ?? "",
                            preparednessBuddy: household.preparednessBuddy ?? "",
                            municipalInformationPoint: household.municipalInformationPoint ?? "",
                            offlineDirections: household.offlineDirections ?? "",
                            individualNeedsNote: household.individualNeedsNote ?? "",
                            language: language
                        )
                    }
                    EmergencyModeContactsSection(
                        familyContacts: familyContacts,
                        officialNumbers: CountryEmergencyConfigurationCatalog.numbers(
                            for: household.countryCode
                        ),
                        language: language
                    )
                    EmergencyModeNextStepsSection(
                        emergencyType: selectedEmergencyType,
                        household: household,
                        language: language,
                        openEmergencyPlan: openEmergencyPlan
                    )
                    EmergencyModeHouseholdStatusSection(
                        members: familyContacts.filter(\.isHouseholdMember),
                        scenarioName: selectedEmergencyType.localizedName(in: language),
                        meetingPoint: plan?.reunionPoint ?? "",
                        language: language
                    )
                    EmergencyModeReadMoreSection(
                        emergencyType: selectedEmergencyType,
                        household: household,
                        language: language
                    )
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .onChange(of: selectedEmergencyType) { _, _ in
                completedActionIDs.removeAll()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var title: String {
        L10n.pick(language: language, english: "Emergency mode", norwegian: "Når det skjer", thai: "โหมดฉุกเฉิน")
    }

    private var currentTemplate: EmergencyPlanTemplate {
        EmergencyTemplateCatalog.provider(for: household.countryCode)?.template(
            for: selectedEmergencyType,
            household: household
        ) ?? NorwayEmergencyTemplates.template(for: selectedEmergencyType, household: household)
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จสิ้น")
    }
}

private struct CommunicationOutageOfflineSection: View {
    @State private var cannotReceiveRadio = false

    let meetingPoint: String
    let reservePlace: String
    let preparednessBuddy: String
    let municipalInformationPoint: String
    let offlineDirections: String
    let individualNeedsNote: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "iphone.slash")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Toggle(radioToggleTitle, isOn: $cannotReceiveRadio)
                .accessibilityIdentifier("cannotReceiveRadioToggle")

            if cannotReceiveRadio {
                Divider()
                EmergencyModeValueRow(title: meetingTitle, value: meetingPoint, language: language)
                EmergencyModeValueRow(title: reserveTitle, value: reservePlace, language: language)
                EmergencyModeValueRow(title: buddyTitle, value: preparednessBuddy, language: language)
                EmergencyModeValueRow(title: informationPointTitle, value: municipalInformationPoint, language: language)
                EmergencyModeValueRow(title: directionsTitle, value: offlineDirections, language: language)
                EmergencyModeValueRow(title: needsTitle, value: individualNeedsNote, language: language)
                Text(missingRadioDetail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Label(emergencyCallDetail, systemImage: "phone.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .emergencyModeCard()
        .accessibilityIdentifier("communicationOutageOfflineSection")
    }

    private var title: String { L10n.pick(language: language, english: "Available without a connection", norwegian: "Tilgjengelig uten forbindelse", thai: "ใช้งานได้โดยไม่ต้องเชื่อมต่อ") }
    private var explanation: String { L10n.pick(language: language, english: "The cause may be unknown. Major accidents, sabotage, or extreme space weather can disrupt services, but this app cannot determine the cause. Satellite messaging and positioning may also be unavailable or inaccurate.", norwegian: "Årsaken kan være ukjent. Store ulykker, sabotasje eller ekstremt romvær kan forstyrre tjenester, men appen kan ikke fastslå årsaken. Satellittmeldinger og posisjonering kan også være utilgjengelige eller unøyaktige.", thai: "สาเหตุอาจไม่ทราบ อุบัติเหตุขนาดใหญ่ การก่อวินาศกรรม หรือสภาพอวกาศรุนแรงอาจรบกวนบริการ แต่แอประบุสาเหตุไม่ได้ การส่งข้อความและตำแหน่งผ่านดาวเทียมอาจใช้ไม่ได้หรือคลาดเคลื่อน") }
    private var radioToggleTitle: String { L10n.pick(language: language, english: "I cannot receive radio either", norwegian: "Jeg får heller ikke inn radio", thai: "ฉันรับสัญญาณวิทยุไม่ได้ด้วย") }
    private var missingRadioDetail: String { L10n.pick(language: language, english: "These are your saved planning details, not verified public help centres. Consider safe travel and follow current authority instructions whenever they become available.", norwegian: "Dette er dine lagrede planopplysninger, ikke bekreftede offentlige hjelpesentre. Vurder om ferdsel er trygg, og følg myndighetenes råd når de blir tilgjengelige.", thai: "นี่คือข้อมูลแผนที่คุณบันทึกไว้ ไม่ใช่ศูนย์ช่วยเหลือสาธารณะที่ยืนยันแล้ว โปรดประเมินความปลอดภัยในการเดินทางและปฏิบัติตามคำแนะนำของทางการเมื่อได้รับ") }
    private var emergencyCallDetail: String { L10n.pick(language: language, english: "In immediate danger, try the relevant emergency number. The app cannot tell whether voice or emergency calls are available and cannot send an emergency message.", norwegian: "Ved akutt fare: forsøk relevant nødnummer. Appen kan ikke avgjøre om tale- eller nødanrop er tilgjengelig, og kan ikke sende en nødmelding.", thai: "เมื่อมีอันตรายเร่งด่วน ให้ลองโทรหมายเลขฉุกเฉินที่เกี่ยวข้อง แอปไม่สามารถทราบว่าการโทรใช้งานได้หรือส่งข้อความฉุกเฉินแทนคุณ") }
    private var meetingTitle: String { L10n.pick(language: language, english: "Meeting point", norwegian: "Møteplass", thai: "จุดนัดพบ") }
    private var reserveTitle: String { L10n.pick(language: language, english: "Reserve place", norwegian: "Reserveplass", thai: "สถานที่สำรอง") }
    private var buddyTitle: String { L10n.pick(language: language, english: "Preparedness buddy", norwegian: "Beredskapsvenn", thai: "เพื่อนเตรียมพร้อม") }
    private var informationPointTitle: String { L10n.pick(language: language, english: "Saved municipal information point", norwegian: "Lagret kommunalt informasjonspunkt", thai: "จุดข้อมูลเทศบาลที่บันทึกไว้") }
    private var directionsTitle: String { L10n.pick(language: language, english: "Directions without maps", norwegian: "Veibeskrivelse uten kart", thai: "เส้นทางโดยไม่ใช้แผนที่") }
    private var needsTitle: String { L10n.pick(language: language, english: "Individual needs", norwegian: "Individuelle behov", thai: "ความต้องการเฉพาะ") }
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
    @ScaledMetric(relativeTo: .title3) private var iconWidth: CGFloat = 28
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
                .frame(width: iconWidth)
                .accessibilityHidden(true)

            Text(name)
                .font(.headline)

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
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
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
    @Binding var completedActionIDs: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "checklist")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            ForEach(Array(template.actions.prefix(3))) { action in
                Button {
                    if completedActionIDs.contains(action.id) {
                        completedActionIDs.remove(action.id)
                    } else {
                        completedActionIDs.insert(action.id)
                    }
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.text(action.titleKey, language: language))
                                .font(.headline)
                            Text(L10n.text(action.detailKey, language: language))
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                        }
                    } icon: {
                        Image(systemName: completedActionIDs.contains(action.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(completedActionIDs.contains(action.id) ? .green : .secondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(completedActionIDs.contains(action.id) ? .isSelected : [])
            }

            if !completedActionIDs.isEmpty {
                Button(resetTitle) { completedActionIDs.removeAll() }
                    .font(.subheadline.weight(.semibold))
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

    private var resetTitle: String {
        L10n.pick(language: language, english: "Reset actions", norwegian: "Nullstill handlinger", thai: "รีเซ็ตการดำเนินการ")
    }
}

private struct EmergencyModeSectionHeading: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.title2.bold())
            .accessibilityHeading(.h1)
            .padding(.top, 8)
    }
}

private struct EmergencyModeNextStepsSection: View {
    let emergencyType: EmergencyType
    let household: HouseholdProfile
    let language: AppLanguage
    let openEmergencyPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "arrow.right.circle.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            ForEach(template.shelterGuidance.prefix(2)) { guidance in
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.text(guidance.titleKey, language: language))
                        .font(.headline)
                    Text(L10n.text(guidance.detailKey, language: language))
                        .font(.subheadline)
                }
            }

            Button(action: openEmergencyPlan) {
                Label(planTitle, systemImage: "checklist.checked")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("emergencyModeOpenPlanButton")
        }
        .emergencyModeCard()
    }

    private var template: EmergencyPlanTemplate {
        EmergencyTemplateCatalog.provider(for: household.countryCode)?.template(for: emergencyType, household: household)
            ?? NorwayEmergencyTemplates.template(for: emergencyType, household: household)
    }

    private var title: String {
        L10n.pick(language: language, english: "Next steps", norwegian: "Neste steg", thai: "ขั้นตอนถัดไป")
    }

    private var planTitle: String {
        L10n.pick(language: language, english: "Open my emergency plan", norwegian: "Åpne nødplanen min", thai: "เปิดแผนฉุกเฉินของฉัน")
    }
}

private struct EmergencyModeReadMoreSection: View {
    @State private var isExpanded = false

    let emergencyType: EmergencyType
    let household: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(template.actions.dropFirst(3))) { action in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.text(action.titleKey, language: language))
                            .font(.headline)
                        Text(L10n.text(action.detailKey, language: language))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(template.shelterGuidance) { guidance in
                    Text(L10n.text(guidance.safetyNoticeKey, language: language))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)
        } label: {
            Label(title, systemImage: "book.closed.fill")
                .font(.title3.weight(.bold))
        }
        .emergencyModeCard()
        .accessibilityIdentifier("emergencyModeReadMoreSection")
    }

    private var template: EmergencyPlanTemplate {
        EmergencyTemplateCatalog.provider(for: household.countryCode)?.template(for: emergencyType, household: household)
            ?? NorwayEmergencyTemplates.template(for: emergencyType, household: household)
    }

    private var title: String {
        L10n.pick(language: language, english: "Read more", norwegian: "Les mer", thai: "อ่านเพิ่มเติม")
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
