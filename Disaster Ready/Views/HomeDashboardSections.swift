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
        contactCount: Int,
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

        contacts = contactCount > 0 ? .prepared : .needsAttention
        self.drillsNeedAttention = drillsNeedAttention
    }
}

struct HomePreparednessSection: View {
    let summary: HomePreparednessSummary
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HomeChecklistRow(
                title: householdTitle,
                status: summary.household,
                language: language,
                systemImage: "house.fill"
            )
            HomeChecklistRow(
                title: suppliesTitle,
                status: summary.supplies,
                language: language,
                systemImage: "shippingbox.fill"
            )
            HomeChecklistRow(
                title: planTitle,
                status: summary.plan,
                language: language,
                systemImage: "checklist"
            )
            if let payment = summary.payment {
                HomeChecklistRow(
                    title: paymentTitle,
                    status: payment,
                    language: language,
                    systemImage: "creditcard.fill"
                )
            }
            HomeChecklistRow(
                title: contactsTitle,
                status: summary.contacts,
                language: language,
                systemImage: "person.2.fill"
            )

            Text(safetyClarification)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("homePreparednessOverview")
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
        L10n.text("contacts", language: language)
    }
}

struct PreparednessNextStepSection: View {
    let summary: HomePreparednessSummary
    let language: AppLanguage
    let openHousehold: () -> Void
    let openPlan: () -> Void
    let openSupplies: () -> Void
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
                title: L10n.pick(language: language, english: "Add an important contact", norwegian: "Legg til en viktig kontakt", thai: "เพิ่มผู้ติดต่อสำคัญ"),
                systemImage: "person.crop.circle.badge.plus",
                isComplete: false,
                action: openContacts
            )
        }
        if summary.supplies != .prepared || summary.payment == .needsAttention || summary.payment == .inProgress {
            return PreparednessNextStep(
                title: L10n.pick(language: language, english: "Review your emergency supplies", norwegian: "Se gjennom beredskapslageret", thai: "ตรวจสอบอุปกรณ์ฉุกเฉิน"),
                systemImage: "shippingbox.fill",
                isComplete: false,
                action: openSupplies
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

struct HomeEmergencyPlanSection: View {
    let selectedEmergencyTitle: String
    let language: AppLanguage
    let openPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(selectedText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: openPlan) {
                Label(actionTitle, systemImage: "checklist")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("homeOpenMyPlan")
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "My emergency plan", norwegian: "Min beredskapsplan", thai: "แผนฉุกเฉินของฉัน")
    }

    private var selectedText: String {
        L10n.pick(
            language: language,
            english: "Selected emergency: \(selectedEmergencyTitle)",
            norwegian: "Valgt hendelse: \(selectedEmergencyTitle)",
            thai: "เหตุฉุกเฉินที่เลือก: \(selectedEmergencyTitle)"
        )
    }

    private var actionTitle: String {
        L10n.pick(language: language, english: "Build / View My Emergency Plan", norwegian: "Lag / vis beredskapsplanen min", thai: "สร้าง / ดูแผนฉุกเฉินของฉัน")
    }
}

struct HomeQuickAccessSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let showsPayment: Bool
    let language: AppLanguage
    let openSupplies: () -> Void
    let openContacts: () -> Void
    let openHousehold: () -> Void
    let openPayment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(offlineNote)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 10) {
                    accessButtons
                }
            } else {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        accessButton(suppliesTitle, systemImage: "shippingbox.fill", identifier: "homeOpenSupplies", action: openSupplies)
                        accessButton(contactsTitle, systemImage: "person.2.fill", identifier: "homeOpenContacts", action: openContacts)
                    }
                    GridRow {
                        accessButton(householdTitle, systemImage: "house.fill", identifier: "homeOpenHousehold", action: openHousehold)
                        if showsPayment {
                            accessButton(paymentTitle, systemImage: "creditcard.fill", identifier: "homeOpenPayment", action: openPayment)
                        } else {
                            Color.clear.accessibilityHidden(true)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    @ViewBuilder
    private var accessButtons: some View {
        accessButton(suppliesTitle, systemImage: "shippingbox.fill", identifier: "homeOpenSupplies", action: openSupplies)
        accessButton(contactsTitle, systemImage: "person.2.fill", identifier: "homeOpenContacts", action: openContacts)
        accessButton(householdTitle, systemImage: "house.fill", identifier: "homeOpenHousehold", action: openHousehold)
        if showsPayment {
            accessButton(paymentTitle, systemImage: "creditcard.fill", identifier: "homeOpenPayment", action: openPayment)
        }
    }

    private func accessButton(
        _ title: String,
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier(identifier)
    }

    private var title: String {
        L10n.pick(language: language, english: "Quick preparedness access", norwegian: "Snarveier til beredskap", thai: "ทางลัดการเตรียมพร้อม")
    }

    private var offlineNote: String {
        L10n.pick(
            language: language,
            english: "Your core preparedness information is available offline.",
            norwegian: "Den viktigste beredskapsinformasjonen din er tilgjengelig uten nett.",
            thai: "ข้อมูลการเตรียมพร้อมหลักของคุณใช้งานได้แบบออฟไลน์"
        )
    }

    private var suppliesTitle: String { L10n.pick(language: language, english: "Supplies", norwegian: "Utstyr", thai: "อุปกรณ์") }
    private var contactsTitle: String { L10n.text("contacts", language: language) }
    private var householdTitle: String { L10n.pick(language: language, english: "Household", norwegian: "Husstand", thai: "ครัวเรือน") }
    private var paymentTitle: String { L10n.text("payment.title", language: language) }
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
