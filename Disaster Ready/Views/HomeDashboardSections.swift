import SwiftUI

enum HomeOfficialTool: String, CaseIterable, Identifiable {
    case weather
    case shelters
    case sources

    var id: String { rawValue }
}

enum HomeNavigationPolicy {
    static let coreNavigationRequiresWeatherData = false
    static let retainedTabs: [DashboardTab] = [.overview, .plan, .supplies, .contacts]
}

struct HomeMunicipalitySection: View {
    let municipality: String?
    let language: AppLanguage
    let editMunicipality: () -> Void

    var body: some View {
        Button(action: editMunicipality) {
            HStack(spacing: 14) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(displayedMunicipality)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DashboardCardBackground())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("homeMunicipalityButton")
        .accessibilityHint(editHint)
    }

    private var displayedMunicipality: String {
        let value = municipality?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? missingMunicipality : value
    }

    private var title: String {
        L10n.pick(language: language, english: "Your municipality", norwegian: "Din kommune", thai: "เทศบาลของคุณ")
    }

    private var missingMunicipality: String {
        L10n.pick(language: language, english: "Choose municipality", norwegian: "Velg kommune", thai: "เลือกเทศบาล")
    }

    private var editHint: String {
        L10n.pick(language: language, english: "Opens household settings", norwegian: "Åpner innstillinger for husstanden", thai: "เปิดการตั้งค่าครัวเรือน")
    }
}

enum HomeChecklistStatus: Equatable, Sendable {
    case needsAttention
    case inProgress
    case prepared
}

struct HomePreparednessSummary: Equatable, Sendable {
    let household: HomeChecklistStatus
    let supplies: HomeChecklistStatus
    let plan: HomeChecklistStatus
    let payment: HomeChecklistStatus?
    let contacts: HomeChecklistStatus
    let drillsNeedAttention: Bool

    var drills: HomeChecklistStatus {
        drillsNeedAttention ? .needsAttention : .prepared
    }

    var preparedAreaCount: Int {
        checklistStatuses.filter { $0 == .prepared }.count
    }

    var totalAreaCount: Int {
        checklistStatuses.count
    }

    private var checklistStatuses: [HomeChecklistStatus] {
        [household, supplies, plan, contacts, drills] + (payment.map { [$0] } ?? [])
    }

    static let measuresSafety = false

    init(
        household: HouseholdProfile,
        completedPlanItems: Int,
        totalPlanItems: Int,
        packedSupplies: Int,
        totalSupplies: Int,
        suppliesNeedingReview: Int,
        paymentCompleted: Int,
        paymentTotal: Int,
        householdMemberCount: Int,
        drillsNeedAttention: Bool = false
    ) {
        let municipalityRecorded = !(household.municipality ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        let householdDetailsRecorded =
            household.hasChildren ||
            household.hasPets ||
            household.hasElectricHeating ||
            household.hasWoodStove ||
            household.hasGasInstallation ||
            household.hasAlternativeHeating ||
            household.hasCar ||
            household.hasSpecialAssistanceNeeds

        if municipalityRecorded && household.knowsWaterStopcock && household.knowsMainElectricalPanel {
            self.household = .prepared
        } else if municipalityRecorded || householdDetailsRecorded ||
                    household.knowsWaterStopcock || household.knowsMainElectricalPanel {
            self.household = .inProgress
        } else {
            self.household = .needsAttention
        }

        if totalSupplies == 0 {
            supplies = .needsAttention
        } else if packedSupplies >= totalSupplies && suppliesNeedingReview == 0 {
            supplies = .prepared
        } else {
            supplies = .inProgress
        }

        if completedPlanItems == 0 {
            plan = .needsAttention
        } else if totalPlanItems > 0 && completedPlanItems >= totalPlanItems {
            plan = .prepared
        } else {
            plan = .inProgress
        }

        if paymentTotal == 0 {
            payment = nil
        } else if paymentCompleted == 0 {
            payment = .needsAttention
        } else if paymentCompleted >= paymentTotal {
            payment = .prepared
        } else {
            payment = .inProgress
        }

        contacts = householdMemberCount > 0 ? .prepared : .needsAttention
        self.drillsNeedAttention = drillsNeedAttention
    }
}

struct HomePreparednessSection: View {
    @State private var showsDetails = false

    let summary: HomePreparednessSummary
    let language: AppLanguage
    let openHousehold: () -> Void
    let openSupplies: () -> Void
    let openPayment: () -> Void
    let openPlan: () -> Void
    let openContacts: () -> Void
    let openDrills: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)
                    .accessibilityIdentifier("homePreparednessOverview")

                Spacer(minLength: 12)

                Text(progressCountText)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(
                value: Double(summary.preparedAreaCount),
                total: Double(summary.totalAreaCount)
            )
            .tint(summary.preparedAreaCount == summary.totalAreaCount ? .green : .blue)

            DisclosureGroup(isExpanded: $showsDetails) {
                VStack(alignment: .leading, spacing: 10) {
                    checklistButton(
                        title: householdTitle,
                        status: summary.household,
                        systemImage: "house.fill",
                        identifier: "preparednessOpenHousehold",
                        action: openHousehold
                    )
                    checklistButton(
                        title: suppliesTitle,
                        status: summary.supplies,
                        systemImage: "shippingbox.fill",
                        identifier: "preparednessOpenSupplies",
                        action: openSupplies
                    )
                    checklistButton(
                        title: planTitle,
                        status: summary.plan,
                        systemImage: "checklist",
                        identifier: "preparednessOpenPlan",
                        action: openPlan
                    )
                    if let payment = summary.payment {
                        checklistButton(
                            title: paymentTitle,
                            status: payment,
                            systemImage: "creditcard.fill",
                            identifier: "preparednessOpenPayment",
                            action: openPayment
                        )
                    }
                    checklistButton(
                        title: contactsTitle,
                        status: summary.contacts,
                        systemImage: "person.2.fill",
                        identifier: "preparednessOpenContacts",
                        action: openContacts
                    )
                    checklistButton(
                        title: drillsTitle,
                        status: summary.drills,
                        systemImage: "timer",
                        identifier: "preparednessOpenDrills",
                        action: openDrills
                    )

                    Text(safetyClarification)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .padding(.top, 10)
            } label: {
                Text(detailsTitle)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier("preparednessShortcutsDisclosure")
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func checklistButton(
        title: String,
        status: HomeChecklistStatus,
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                HomeChecklistRow(
                    title: title,
                    status: status,
                    language: language,
                    systemImage: systemImage
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var title: String {
        L10n.pick(language: language, english: "My preparedness", norwegian: "Min beredskap", thai: "ความพร้อมของฉัน")
    }

    private var explanation: String {
        L10n.pick(
            language: language,
            english: "Preparedness checklist progress based only on the information you have completed.",
            norwegian: "Fremdrift i beredskapssjekklisten, basert bare på det du har fylt ut.",
            thai: "ความคืบหน้าของรายการตรวจสอบความพร้อม อ้างอิงเฉพาะข้อมูลที่คุณกรอกแล้ว"
        )
    }

    private var progressCountText: String {
        "\(summary.preparedAreaCount)/\(summary.totalAreaCount)"
    }

    private var detailsTitle: String {
        L10n.pick(
            language: language,
            english: "Status and shortcuts",
            norwegian: "Status og snarveier",
            thai: "สถานะและทางลัด"
        )
    }

    private var safetyClarification: String {
        L10n.pick(
            language: language,
            english: "Checklist progress does not measure or guarantee safety.",
            norwegian: "Fremdriften i sjekklisten måler eller garanterer ikke sikkerhet.",
            thai: "ความคืบหน้าของรายการตรวจสอบไม่ได้วัดหรือรับประกันความปลอดภัย"
        )
    }

    private var householdTitle: String {
        L10n.pick(language: language, english: "Household profile", norwegian: "Husholdningsprofil", thai: "โปรไฟล์ครัวเรือน")
    }

    private var suppliesTitle: String {
        L10n.pick(language: language, english: "Home supplies", norwegian: "Hjemmeberedskap", thai: "อุปกรณ์ที่บ้าน")
    }

    private var planTitle: String {
        L10n.pick(language: language, english: "Emergency plan", norwegian: "Beredskapsplan", thai: "แผนฉุกเฉิน")
    }

    private var paymentTitle: String {
        L10n.text("payment.title", language: language)
    }

    private var contactsTitle: String {
        L10n.pick(
            language: language,
            english: "Household members",
            norwegian: "Husstandsmedlemmer",
            thai: "สมาชิกในครัวเรือน"
        )
    }

    private var drillsTitle: String {
        L10n.pick(
            language: language,
            english: "Preparedness exercises",
            norwegian: "Beredskapsøvelser",
            thai: "แบบฝึกความพร้อมรับมือเหตุฉุกเฉิน"
        )
    }
}

struct PreparednessNextStepSection: View {
    let summary: HomePreparednessSummary
    let language: AppLanguage
    let openHousehold: () -> Void
    let openPlan: () -> Void
    let openSupplies: () -> Void
    let openPayment: () -> Void
    let openContacts: () -> Void
    let openDrills: () -> Void

    var body: some View {
        Button(action: nextStep.action) {
            HStack(spacing: 14) {
                Image(systemName: nextStep.systemImage)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(nextStep.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 8)

                Image(systemName: nextStep.isComplete ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(nextStep.isComplete ? .green : .blue)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(DashboardCardBackground())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(nextStep.isComplete)
        .accessibilityIdentifier("preparednessNextStep")
    }

    private var nextStep: PreparednessNextStep {
        if summary.household != .prepared {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Complete your household profile", norwegian: "Fullfør husstandsprofilen", thai: "กรอกโปรไฟล์ครัวเรือนให้เสร็จ"),
                systemImage: "house.fill",
                isComplete: false,
                action: openHousehold
            )
        }
        if summary.plan != .prepared {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Add meeting and evacuation locations", norwegian: "Legg inn møte- og evakueringssted", thai: "เพิ่มจุดนัดพบและจุดอพยพ"),
                systemImage: "mappin.and.ellipse",
                isComplete: false,
                action: openPlan
            )
        }
        if summary.contacts != .prepared {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Add a household member", norwegian: "Legg til et husstandsmedlem", thai: "เพิ่มสมาชิกในครัวเรือน"),
                systemImage: "person.crop.circle.badge.plus",
                isComplete: false,
                action: openContacts
            )
        }
        if summary.supplies != .prepared {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Review your emergency supplies", norwegian: "Se gjennom beredskapslageret", thai: "ตรวจสอบอุปกรณ์ฉุกเฉิน"),
                systemImage: "shippingbox.fill",
                isComplete: false,
                action: openSupplies
            )
        }
        if summary.payment == .needsAttention || summary.payment == .inProgress {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Complete payment preparedness", norwegian: "Fullfør betalingsberedskapen", thai: "เตรียมความพร้อมด้านการชำระเงินให้เสร็จ"),
                systemImage: "creditcard.fill",
                isComplete: false,
                action: openPayment
            )
        }
        if summary.drillsNeedAttention {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Complete a preparedness exercise", norwegian: "Gjennomfør en beredskapsøvelse", thai: "ทำแบบฝึกความพร้อมรับมือเหตุฉุกเฉิน"),
                systemImage: "timer",
                isComplete: false,
                action: openDrills
            )
        }
        return PreparednessNextStep(
            title: L10n.pick(language: language, english: "Your essential setup is complete", norwegian: "Det viktigste oppsettet er fullført", thai: "การตั้งค่าที่สำคัญเสร็จสมบูรณ์"),
            systemImage: "checkmark.seal.fill",
            isComplete: true,
            action: {}
        )
    }

    private var title: String {
        L10n.pick(language: language, english: "Next step", norwegian: "Neste steg", thai: "ขั้นตอนถัดไป")
    }
}

struct HomePlanReviewSection: View {
    let lastReviewedAt: Date?
    let scenarioName: String
    let language: AppLanguage
    let openPlan: () -> Void

    var body: some View {
        Button(action: openPlan) {
            HStack(spacing: 14) {
                Image(systemName: needsReview ? "calendar.badge.exclamationmark" : "checkmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(needsReview ? .orange : .green)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(statusText)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let reviewTimingText {
                        Text(reviewTimingText)
                            .font(.caption)
                            .foregroundStyle(needsReview ? .orange : .secondary)
                    }
                    Text(scenarioName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(DashboardCardBackground())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("planReviewStatus")
    }

    private var needsReview: Bool {
        guard let reviewDeadline else { return true }
        return reviewDeadline <= Date()
    }

    private var reviewDeadline: Date? {
        guard let lastReviewedAt else { return nil }
        return Calendar.current.date(byAdding: .month, value: 6, to: lastReviewedAt)
    }

    private var statusText: String {
        guard lastReviewedAt != nil else {
            return L10n.pick(language: language, english: "The plan has not been reviewed", norwegian: "Planen er ikke gjennomgått", thai: "ยังไม่ได้ตรวจสอบแผน")
        }

        if needsReview {
            return L10n.pick(language: language, english: "The plan should be reviewed again", norwegian: "Planen bør gjennomgås på nytt", thai: "ควรตรวจสอบแผนอีกครั้ง")
        }

        return L10n.pick(language: language, english: "The plan is up to date", norwegian: "Planen er oppdatert", thai: "แผนเป็นปัจจุบัน")
    }

    private var reviewTimingText: String? {
        guard let reviewDeadline else { return nil }
        let date = reviewDeadline.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(AppLanguage.locale(for: language))
        )

        if needsReview {
            return L10n.pick(language: language, english: "Due since \(date)", norwegian: "Forfalt \(date)", thai: "ครบกำหนดตั้งแต่ \(date)")
        }
        return L10n.pick(language: language, english: "Next review: \(date)", norwegian: "Neste gjennomgang: \(date)", thai: "ตรวจสอบครั้งถัดไป: \(date)")
    }

    private var title: String {
        L10n.pick(language: language, english: "Plan review", norwegian: "Gjennomgang av planen", thai: "การตรวจสอบแผน")
    }
}

private struct PreparednessNextStep {
    let title: String
    let systemImage: String
    let isComplete: Bool
    let action: () -> Void
}

private struct HomeChecklistRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let status: HomeChecklistStatus
    let language: AppLanguage
    let systemImage: String

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))

        layout {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(title)
                .font(.body)

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }

            Text(statusTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var statusTitle: String {
        switch status {
        case .needsAttention:
            L10n.pick(language: language, english: "Needs attention", norwegian: "Trenger oppfølging", thai: "ต้องตรวจสอบ")
        case .inProgress:
            L10n.pick(language: language, english: "In progress", norwegian: "Påbegynt", thai: "กำลังดำเนินการ")
        case .prepared:
            L10n.pick(language: language, english: "Prepared", norwegian: "Forberedt", thai: "เตรียมพร้อม")
        }
    }
}

struct HomeOfficialToolSheet: View {
    @Environment(\.dismiss) private var dismiss

    let tool: HomeOfficialTool
    let language: AppLanguage
    let openPlan: (EmergencyType) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch tool {
                    case .weather:
                        OfficialWeatherAlertsSection(language: language, openPlan: openPlan)
                    case .shelters:
                        PublicSheltersSection(language: language)
                    case .sources:
                        OfficialSourcesSection(
                            sources: GuidanceSourceRegistry.norway,
                            language: language
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(doneTitle) { dismiss() }
                        .accessibilityIdentifier("homeOfficialToolDone")
                }
            }
        }
        .environment(\.locale, AppLanguage.locale(for: language))
    }

    private var navigationTitle: String {
        switch tool {
        case .weather:
            L10n.pick(language: language, english: "Weather warnings", norwegian: "Farevarsler", thai: "คำเตือนสภาพอากาศ")
        case .shelters:
            L10n.pick(language: language, english: "Public shelters", norwegian: "Tilfluktsrom", thai: "ที่หลบภัยสาธารณะ")
        case .sources:
            L10n.text("source.section.title", language: language)
        }
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จสิ้น")
    }
}

struct HomeHouseholdProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var profile: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        NavigationStack {
            HouseholdProfileEditor(profile: $profile, language: language)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(doneTitle) { dismiss() }
                            .accessibilityIdentifier("homeHouseholdDone")
                    }
                }
        }
        .environment(\.locale, AppLanguage.locale(for: language))
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จสิ้น")
    }
}

struct HomeOfficialToolsSection: View {
    let showsShelters: Bool
    let language: AppLanguage
    let openWeather: () -> Void
    let openShelters: () -> Void
    let openSources: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            toolButton(weatherTitle, systemImage: "exclamationmark.triangle", identifier: "homeOpenWeather", action: openWeather)
            if showsShelters {
                toolButton(shelterTitle, systemImage: "mappin.and.ellipse", identifier: "homeOpenShelters", action: openShelters)
            }
            toolButton(sourceTitle, systemImage: "building.columns", identifier: "homeOpenSources", action: openSources)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func toolButton(
        _ title: String,
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var title: String {
        L10n.pick(language: language, english: "Official information & tools", norwegian: "Offisiell informasjon og verktøy", thai: "ข้อมูลและเครื่องมือทางการ")
    }

    private var detail: String {
        L10n.pick(
            language: language,
            english: "Open official reference information when you need it. Web source links may require internet.",
            norwegian: "Åpne offisiell referanseinformasjon når du trenger den. Nettlenker til kilder kan kreve internett.",
            thai: "เปิดข้อมูลอ้างอิงทางการเมื่อจำเป็น ลิงก์แหล่งข้อมูลบนเว็บอาจต้องใช้อินเทอร์เน็ต"
        )
    }

    private var weatherTitle: String {
        L10n.pick(language: language, english: "Weather warnings", norwegian: "Farevarsler", thai: "คำเตือนสภาพอากาศ")
    }

    private var shelterTitle: String {
        L10n.text("shelter_reference.title", language: language)
    }

    private var sourceTitle: String {
        L10n.text("source.section.title", language: language)
    }
}
