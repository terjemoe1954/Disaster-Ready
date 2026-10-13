//
//  DashboardSections.swift
//  Disaster Ready
//

import MessageUI
import SwiftUI

enum DashboardTab: Hashable {
    case overview
    case plan
    case supplies
    case contacts
}

private enum DashboardPalette {
    static func cardFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.15, blue: 0.18).opacity(0.94)
            : Color.white.opacity(0.92)
    }

    static func insetFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.04)
    }

    static func secondaryPanelFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.17, green: 0.20, blue: 0.24).opacity(0.92)
            : Color.white.opacity(0.88)
    }
}

struct HeroCardSection: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(L10n.text("works_without_internet", language: language), systemImage: "wifi.slash")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.18), in: Capsule())

            Text(L10n.text("hero_title", language: language))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .accessibilityHeading(.h1)

            Text(L10n.text("hero_subtitle", language: language))
                .font(.callout)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.10, green: 0.17, blue: 0.21))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 42))
                        .accessibilityHidden(true)
                        .foregroundStyle(.white.opacity(0.14))
                        .padding()
                }
        )
    }

}

struct PreparednessOverviewSection: View {
    let completedPlanItems: Int
    let totalPlanItems: Int
    let packedSupplies: Int
    let totalSupplies: Int
    let suppliesNeedingReview: Int
    let contactCount: Int
    let language: AppLanguage
    let openPlan: () -> Void
    let openSupplies: () -> Void
    let openContacts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            recommendedNextStep

            PreparednessActionCard(
                title: planTitle,
                status: "\(completedPlanItems)/\(totalPlanItems)",
                detail: planDetail,
                systemImage: "checklist",
                tint: .orange,
                action: openPlan
            )

            PreparednessActionCard(
                title: suppliesTitle,
                status: "\(packedSupplies)/\(totalSupplies)",
                detail: suppliesDetail,
                systemImage: "shippingbox.fill",
                tint: .indigo,
                action: openSupplies
            )

            if suppliesNeedingReview > 0 {
                PreparednessActionCard(
                    title: reviewTitle,
                    status: "\(suppliesNeedingReview)",
                    detail: reviewDetail,
                    systemImage: "calendar.badge.exclamationmark",
                    tint: .red,
                    action: openSupplies
                )
            }

            PreparednessActionCard(
                title: contactsTitle,
                status: "\(contactCount)",
                detail: contactsDetail,
                systemImage: "person.2.fill",
                tint: .blue,
                action: openContacts
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    @ViewBuilder
    private var recommendedNextStep: some View {
        if suppliesNeedingReview > 0 {
            RecommendedNextStepCard(
                title: nextStepReviewTitle,
                detail: nextStepReviewDetail,
                systemImage: "calendar.badge.exclamationmark",
                tint: .red,
                action: openSupplies
            )
        } else if completedPlanItems < totalPlanItems {
            RecommendedNextStepCard(
                title: nextStepPlanTitle,
                detail: nextStepPlanDetail,
                systemImage: "arrow.right.circle.fill",
                tint: .orange,
                action: openPlan
            )
        } else if packedSupplies < totalSupplies {
            RecommendedNextStepCard(
                title: nextStepSuppliesTitle,
                detail: nextStepSuppliesDetail,
                systemImage: "shippingbox.fill",
                tint: .indigo,
                action: openSupplies
            )
        } else if contactCount == 0 {
            RecommendedNextStepCard(
                title: nextStepContactsTitle,
                detail: nextStepContactsDetail,
                systemImage: "person.crop.circle.badge.plus",
                tint: .blue,
                action: openContacts
            )
        } else {
            RecommendedNextStepCard(
                title: allReadyTitle,
                detail: allReadyDetail,
                systemImage: "checkmark.seal.fill",
                tint: .green,
                action: openSupplies
            )
        }
    }

    private var nextStepReviewTitle: String {
        L10n.pick(language: language, english: "Next: Review your supplies", norwegian: "Neste: Kontroller utstyret", thai: "ถัดไป: ตรวจสอบอุปกรณ์")
    }

    private var nextStepReviewDetail: String {
        L10n.pick(language: language, english: "Some review dates are due or approaching.", norwegian: "Noen kontrolldatoer er passert eller nærmer seg.", thai: "วันตรวจสอบบางรายการถึงกำหนดหรือใกล้ถึงกำหนดแล้ว")
    }

    private var nextStepPlanTitle: String {
        L10n.pick(language: language, english: "Next: Complete your household plan", norwegian: "Neste: Fullfør familieplanen", thai: "ถัดไป: ทำแผนครอบครัวให้เสร็จ")
    }

    private var nextStepPlanDetail: String {
        L10n.pick(language: language, english: "Add the missing meeting, evacuation, or shelter location.", norwegian: "Legg inn manglende møteplass, evakueringssted eller tilfluktssted.", thai: "เพิ่มจุดนัดพบ สถานที่อพยพ หรือที่พักพิงที่ยังขาด")
    }

    private var nextStepSuppliesTitle: String {
        L10n.pick(language: language, english: "Next: Pack one missing item", norwegian: "Neste: Pakk én ting som mangler", thai: "ถัดไป: เตรียมของที่ขาดหนึ่งรายการ")
    }

    private var nextStepSuppliesDetail: String {
        L10n.pick(language: language, english: "Open your supplies and choose one easy item to complete.", norwegian: "Åpne utstyrslisten og velg én enkel ting å gjøre ferdig.", thai: "เปิดรายการอุปกรณ์แล้วเลือกของง่าย ๆ หนึ่งรายการให้เสร็จ")
    }

    private var nextStepContactsTitle: String {
        L10n.pick(language: language, english: "Next: Add an important contact", norwegian: "Neste: Legg til en viktig kontakt", thai: "ถัดไป: เพิ่มผู้ติดต่อสำคัญ")
    }

    private var nextStepContactsDetail: String {
        L10n.pick(language: language, english: "Save a family member or another number you may need.", norwegian: "Lagre et familiemedlem eller et annet nummer du kan få bruk for.", thai: "บันทึกสมาชิกครอบครัวหรือหมายเลขอื่นที่อาจต้องใช้")
    }

    private var allReadyTitle: String {
        L10n.pick(language: language, english: "Your essentials are ready", norwegian: "Det viktigste er klart", thai: "สิ่งจำเป็นพร้อมแล้ว")
    }

    private var allReadyDetail: String {
        L10n.pick(language: language, english: "Review your supplies regularly to stay prepared.", norwegian: "Kontroller utstyret jevnlig for å holde beredskapen ved like.", thai: "ตรวจสอบอุปกรณ์เป็นประจำเพื่อรักษาความพร้อม")
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Your preparedness",
            norwegian: "Din beredskap",
            thai: "ความพร้อมของคุณ"
        )
    }

    private var subtitle: String {
        L10n.pick(
            language: language,
            english: "Start with one small step. You can complete the rest later.",
            norwegian: "Begynn med ett lite steg. Resten kan du fullføre senere.",
            thai: "เริ่มจากขั้นตอนเล็ก ๆ หนึ่งอย่าง แล้วค่อยทำส่วนที่เหลือภายหลัง"
        )
    }

    private var planTitle: String {
        L10n.pick(language: language, english: "Household plan", norwegian: "Familieplan", thai: "แผนครอบครัว")
    }

    private var planDetail: String {
        L10n.pick(
            language: language,
            english: "Choose meeting and evacuation locations",
            norwegian: "Velg møteplass og evakueringssted",
            thai: "เลือกจุดนัดพบและสถานที่อพยพ"
        )
    }

    private var suppliesTitle: String {
        L10n.pick(language: language, english: "Emergency supplies", norwegian: "Beredskapsutstyr", thai: "อุปกรณ์ฉุกเฉิน")
    }

    private var suppliesDetail: String {
        L10n.pick(
            language: language,
            english: "Review what is packed and what is missing",
            norwegian: "Se hva som er pakket og hva som mangler",
            thai: "ตรวจสอบสิ่งที่เตรียมแล้วและสิ่งที่ยังขาด"
        )
    }

    private var reviewTitle: String {
        L10n.pick(
            language: language,
            english: "Supplies to review",
            norwegian: "Utstyr som må kontrolleres",
            thai: "อุปกรณ์ที่ต้องตรวจสอบ"
        )
    }

    private var reviewDetail: String {
        L10n.pick(
            language: language,
            english: "Review dates are due or approaching",
            norwegian: "Kontrolldatoer er passert eller nærmer seg",
            thai: "ถึงหรือใกล้ถึงวันที่ตรวจสอบแล้ว"
        )
    }

    private var contactsTitle: String {
        L10n.pick(language: language, english: "Important contacts", norwegian: "Viktige kontakter", thai: "ผู้ติดต่อสำคัญ")
    }

    private var contactsDetail: String {
        L10n.pick(
            language: language,
            english: "Keep family and emergency numbers together",
            norwegian: "Samle familie- og nødnumre på ett sted",
            thai: "เก็บหมายเลขครอบครัวและฉุกเฉินไว้ด้วยกัน"
        )
    }
}

private struct RecommendedNextStepCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var iconFrameSize: CGFloat = 36

    let title: String
    let detail: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(spacing: 14))

            layout {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(tint.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tint.opacity(0.22), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("recommendedNextStep")
    }
}

private struct PreparednessActionCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconFrameSize: CGFloat = 36

    let title: String
    let status: String
    let detail: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(spacing: 14))

            layout {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: 8)
                }

                Text(status)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                if !dynamicTypeSize.isAccessibilitySize {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                }
            }
            .padding(14)
            .background(InsetCardBackground())
        }
        .buttonStyle(.plain)
    }
}

struct ScenarioSelectorSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedScenario: PreparednessScenario
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.text("scenario", language: language))
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Picker(L10n.text("scenario", language: language), selection: $selectedScenario) {
                ForEach(PreparednessScenario.allCases) { scenario in
                    Label(scenario.localizedName(in: language), systemImage: scenario.icon)
                        .tag(scenario)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(DashboardPalette.secondaryPanelFill(for: colorScheme))
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(selectedScenario.tint.opacity(0.5), lineWidth: 1.5)
                    }
            )
        }
    }
}

struct DecisionCardSection: View {
    let scenario: PreparednessScenario
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: scenario.icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(scenario.tint)
                    .frame(width: 28)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.localizedName(in: language))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(scenario.recommendedAction(in: language))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(scenario.tint.opacity(0.16), in: Capsule())
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(scenario.summary(in: language))
                .font(.body)

            ruleRow(title: L10n.text("go", language: language), text: scenario.goRule(in: language), color: .green)
            ruleRow(title: L10n.text("no_go", language: language), text: scenario.noGoRule(in: language), color: .red)

            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.text("immediate_checklist", language: language))
                    .font(.headline)
                ForEach(scenario.checklist(in: language), id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(scenario.tint)
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func ruleRow(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.16), in: Capsule())
            Text(text)
                .font(.subheadline)
        }
    }
}

struct HouseholdPlanSection: View {
    @Bindable var plan: HouseholdPlan
    let summary: String
    let language: AppLanguage
    let scenarioName: String
    let showsGasShutoff: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.text("household_plan", language: language))
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)
                Spacer()
                Text(scenarioName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.14), in: Capsule())
            }

            Text(L10n.text("household_plan_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            planField(L10n.text("reunion_point", language: language), text: $plan.reunionPoint)
            planField(L10n.text("evacuation_destination", language: language), text: $plan.evacuationDestination)
            planField(L10n.text("shelter_zone", language: language), text: $plan.shelterZone)
            planField(alternativeAccommodationTitle, text: optionalBinding(for: \HouseholdPlan.alternativeAccommodation))
            planField(familyFriendLocationTitle, text: optionalBinding(for: \HouseholdPlan.familyFriendLocation))
            planField(secondaryHomeTitle, text: optionalBinding(for: \HouseholdPlan.secondaryHome))
            planField(safePlaceNoteTitle, text: optionalBinding(for: \HouseholdPlan.safePlaceNote), axis: .vertical)
                .lineLimit(2...4)
            planField(waterStopcockTitle, text: optionalBinding(for: \HouseholdPlan.waterStopcockNote))
            planField(mainElectricalPanelTitle, text: optionalBinding(for: \HouseholdPlan.mainElectricalPanelNote))
            if showsGasShutoff {
                planField(L10n.text("gas_shutoff_note", language: language), text: $plan.gasShutoffNote, axis: .vertical)
                    .lineLimit(2...4)
            }
            planField(L10n.text("medical_lead", language: language), text: $plan.medicalLead)
            planField(L10n.text("pet_lead", language: language), text: $plan.petLead)
            planField(L10n.text("family_password", language: language), text: $plan.familyPassword)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.text("plan_summary", language: language))
                    .font(.headline)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(InsetCardBackground())
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func optionalBinding(
        for keyPath: ReferenceWritableKeyPath<HouseholdPlan, String?>
    ) -> Binding<String> {
        Binding(
            get: { plan[keyPath: keyPath] ?? "" },
            set: { newValue in
                plan[keyPath: keyPath] = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private var alternativeAccommodationTitle: String {
        L10n.pick(language: language, english: "Alternative accommodation", norwegian: "Alternativ overnatting", thai: "ที่พักทางเลือก")
    }

    private var familyFriendLocationTitle: String {
        L10n.pick(language: language, english: "Family or friend location", norwegian: "Sted hos familie eller venner", thai: "สถานที่ของครอบครัวหรือเพื่อน")
    }

    private var secondaryHomeTitle: String {
        L10n.pick(language: language, english: "Cabin or secondary home", norwegian: "Hytte eller sekundærbolig", thai: "กระท่อมหรือบ้านสำรอง")
    }

    private var safePlaceNoteTitle: String {
        L10n.pick(language: language, english: "Personal safe-place note", norwegian: "Personlig notat om oppholdssted", thai: "บันทึกส่วนตัวเกี่ยวกับสถานที่ปลอดภัย")
    }

    private var waterStopcockTitle: String {
        L10n.pick(language: language, english: "Main water stopcock", norwegian: "Hovedstoppekran for vann", thai: "วาล์วปิดน้ำหลัก")
    }

    private var mainElectricalPanelTitle: String {
        L10n.pick(language: language, english: "Main electrical panel", norwegian: "Hovedsikringsskap", thai: "ตู้ไฟฟ้าหลัก")
    }

    private func planField(_ title: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(title).foregroundStyle(.secondary),
            axis: axis
        )
        .textFieldStyle(.plain)
        .padding(12)
        .background(InsetCardBackground())
    }
}

struct ContactsSection: View {
    @State private var showsHouseholdMembers = true
    @State private var showsOutsideContacts = false
    @State private var showsImportantNumbers = false

    let householdMembers: [FamilyContact]
    let outsideContacts: [FamilyContact]
    let importantNumbers: [ImportantNumber]
    let countryCode: String
    let language: AppLanguage
    let addHouseholdMember: () -> Void
    let addOutsideContact: () -> Void
    let addImportant: () -> Void
    let deleteFamily: (FamilyContact) -> Void
    let deleteImportant: (ImportantNumber) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(L10n.text("contacts", language: language))
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)
                Spacer()
                Text(L10n.text("offline", language: language))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.12), in: Capsule())
            }

            Text(L10n.text("contacts_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            OfficialEmergencyContactsSection(
                countryCode: countryCode,
                language: language
            )

            Text(EmergencyContactsLocalizationResources.text("official_contacts.my_contacts", language: language))
                .font(.headline)
                .accessibilityHeading(.h3)

            contactGroup(
                title: householdMembersTitle,
                count: householdMembers.count,
                isExpanded: $showsHouseholdMembers,
                addTitle: addHouseholdMemberTitle,
                addAction: addHouseholdMember
            ) {
                ForEach(householdMembers) { contact in
                    FamilyContactEditor(
                        contact: contact,
                        language: language,
                        deleteAction: { deleteFamily(contact) }
                    )
                }
            }

            contactGroup(
                title: outsideContactsTitle,
                count: outsideContacts.count,
                isExpanded: $showsOutsideContacts,
                addTitle: addOutsideContactTitle,
                addAction: addOutsideContact
            ) {
                ForEach(outsideContacts) { contact in
                    FamilyContactEditor(
                        contact: contact,
                        language: language,
                        deleteAction: { deleteFamily(contact) }
                    )
                }
            }

            contactGroup(
                title: L10n.text("important_numbers", language: language),
                count: importantNumbers.count,
                isExpanded: $showsImportantNumbers,
                addTitle: L10n.text("add_number", language: language),
                addAction: addImportant
            ) {
                ForEach(importantNumbers) { number in
                    ImportantNumberEditor(
                        number: number,
                        language: language,
                        deleteAction: { deleteImportant(number) }
                    )
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var householdMembersTitle: String {
        L10n.pick(language: language, english: "Household members", norwegian: "Husstandsmedlemmer", thai: "สมาชิกในครัวเรือน")
    }

    private var outsideContactsTitle: String {
        L10n.pick(language: language, english: "Contacts outside the household", norwegian: "Kontakter utenfor husstanden", thai: "ผู้ติดต่อนอกครัวเรือน")
    }

    private var addHouseholdMemberTitle: String {
        L10n.pick(language: language, english: "Add member", norwegian: "Legg til medlem", thai: "เพิ่มสมาชิก")
    }

    private var addOutsideContactTitle: String {
        L10n.pick(language: language, english: "Add contact", norwegian: "Legg til kontakt", thai: "เพิ่มผู้ติดต่อ")
    }

    private func contactGroup<Content: View>(
        title: String,
        count: Int,
        isExpanded: Binding<Bool>,
        addTitle: String,
        addAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                Button(action: addAction) {
                    Label(addTitle, systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                content()
            }
            .padding(.top, 10)
        } label: {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer(minLength: 8)
                Text("\(count)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct MessageTemplatesSection: View {
    @Binding var includePlanSummary: Bool
    @State private var showsTemplates = false
    @State private var messageDraft: FamilyMessageDraft?
    @State private var showsMessageUnavailable = false
    @State private var pendingMessageWithoutRecipients: String?
    @State private var showsNoRecipients = false

    let templates: [FamilyMessageTemplate]
    let shareText: (FamilyMessageTemplate) -> String
    let householdMembers: [FamilyContact]
    let hasPlanSummary: Bool
    let language: AppLanguage
    let openContacts: () -> Void
    let openPlanLocations: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DisclosureGroup(isExpanded: $showsTemplates) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(messageInstructions)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Label(recipientStatusTitle, systemImage: validRecipients.isEmpty ? "person.crop.circle.badge.exclamationmark" : "person.2.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(validRecipients.isEmpty ? .orange : .secondary)

                        Spacer(minLength: 8)

                        if validRecipients.isEmpty {
                            Button(addPhoneNumberTitle, action: openContacts)
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                    if !recipientNames.isEmpty {
                        Text(recipientNamesTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    if validRecipients.count > 1 {
                        Label(groupMessageNotice, systemImage: "person.3.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if hasPlanSummary {
                        Toggle(includePlanSummaryTitle, isOn: $includePlanSummary)
                            .font(.subheadline)
                    } else {
                        Button(action: openPlanLocations) {
                            Label(addPlanLocationsTitle, systemImage: "mappin.and.ellipse")
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                    ForEach(templates) { template in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: "paperplane.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.title)
                                        .font(.headline)
                                    Text(shareText(template))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                            }

                            Button {
                                openMessageComposer(for: template)
                            } label: {
                                Label(smsTitle, systemImage: "message.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .accessibilityLabel("\(smsTitle): \(template.title)")
                        }
                        .padding(14)
                        .background(InsetCardBackground())
                    }
                }
                .padding(.top, 12)
            } label: {
                HStack {
                    Text(sectionTitle)
                        .font(.title3.weight(.bold))
                        .accessibilityHeading(.h2)
                    Spacer(minLength: 8)
                    Text("\(templates.count)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
        .sheet(item: $messageDraft) { draft in
            FamilyMessageComposer(recipients: draft.recipients, body: draft.body)
        }
        .alert(messageUnavailableTitle, isPresented: $showsMessageUnavailable) {
            Button(messageUnavailableDismissTitle, role: .cancel) {}
        } message: {
            Text(messageUnavailableMessage)
        }
        .alert(noRecipientsTitle, isPresented: $showsNoRecipients) {
            Button(addPhoneNumberTitle) {
                pendingMessageWithoutRecipients = nil
                openContacts()
            }
            Button(continueWithoutRecipientTitle) {
                guard let body = pendingMessageWithoutRecipients else { return }
                pendingMessageWithoutRecipients = nil
                messageDraft = FamilyMessageDraft(recipients: [], body: body)
            }
            Button(cancelTitle, role: .cancel) {
                pendingMessageWithoutRecipients = nil
            }
        } message: {
            Text(noRecipientsMessage)
        }
    }

    private func openMessageComposer(for template: FamilyMessageTemplate) {
        guard MFMessageComposeViewController.canSendText() else {
            showsMessageUnavailable = true
            return
        }

        let body = shareText(template)
        guard !validRecipients.isEmpty else {
            pendingMessageWithoutRecipients = body
            showsNoRecipients = true
            return
        }
        messageDraft = FamilyMessageDraft(
            recipients: validRecipients,
            body: body
        )
    }

    private var smsTitle: String {
        L10n.pick(language: language, english: "Open Messages", norwegian: "Åpne Meldinger", thai: "เปิดแอปข้อความ")
    }

    private var validRecipients: [String] {
        FamilyMessageRecipientResolver.recipients(from: householdMembers.map(\.phoneNumber))
    }

    private var recipientNames: [String] {
        var seenNumbers: Set<String> = []
        return householdMembers.compactMap { member in
            let name = member.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let comparisonKey = member.phoneNumber.filter(\.isNumber)
            guard !name.isEmpty,
                  FamilyMessageRecipientResolver.isValid(member.phoneNumber),
                  seenNumbers.insert(comparisonKey).inserted else {
                return nil
            }
            return name
        }
    }

    private var recipientNamesTitle: String {
        let names = recipientNames.formatted(
            .list(type: .and)
                .locale(AppLanguage.locale(for: language))
        )
        return L10n.pick(
            language: language,
            english: "Recipients: \(names)",
            norwegian: "Mottakere: \(names)",
            thai: "ผู้รับ: \(names)"
        )
    }

    private var groupMessageNotice: String {
        L10n.pick(
            language: language,
            english: "Messages may create a group conversation where recipients can see each other.",
            norwegian: "Meldinger kan opprette en gruppesamtale der mottakerne kan se hverandre.",
            thai: "แอปข้อความอาจสร้างการสนทนากลุ่มซึ่งผู้รับสามารถเห็นกันและกันได้"
        )
    }

    private var includePlanSummaryTitle: String {
        L10n.pick(
            language: language,
            english: "Include meeting point and evacuation plan",
            norwegian: "Ta med møtepunkt og evakueringsplan",
            thai: "รวมจุดนัดพบและแผนอพยพ"
        )
    }

    private var addPlanLocationsTitle: String {
        L10n.pick(
            language: language,
            english: "Add meeting point or evacuation destination",
            norwegian: "Legg til møtepunkt eller evakueringssted",
            thai: "เพิ่มจุดนัดพบหรือปลายทางอพยพ"
        )
    }

    private var recipientStatusTitle: String {
        guard !validRecipients.isEmpty else {
            return L10n.pick(
                language: language,
                english: "No recipients registered",
                norwegian: "Ingen mottakere registrert",
                thai: "ยังไม่ได้ลงทะเบียนผู้รับ"
            )
        }

        let count = validRecipients.count
        return L10n.pick(
            language: language,
            english: count == 1 ? "1 registered recipient" : "\(count) registered recipients",
            norwegian: count == 1 ? "1 registrert mottaker" : "\(count) registrerte mottakere",
            thai: "ผู้รับที่ลงทะเบียน \(count) คน"
        )
    }

    private var sectionTitle: String {
        L10n.pick(
            language: language,
            english: "SMS updates to the family",
            norwegian: "SMS-oppdateringer til familien",
            thai: "ส่งอัปเดต SMS ให้ครอบครัว"
        )
    }

    private var messageInstructions: String {
        L10n.pick(
            language: language,
            english: "Choose an update to open Messages with recipients and text filled in. Review it, then tap Send in Messages.",
            norwegian: "Velg en oppdatering for å åpne Meldinger med mottakere og tekst ferdig utfylt. Kontroller innholdet og trykk deretter Send i Meldinger.",
            thai: "เลือกอัปเดตเพื่อเปิดแอปข้อความพร้อมผู้รับและข้อความที่กรอกไว้ ตรวจสอบแล้วแตะส่งในแอปข้อความ"
        )
    }

    private var messageUnavailableTitle: String {
        L10n.pick(
            language: language,
            english: "Messages unavailable",
            norwegian: "Meldinger er ikke tilgjengelig",
            thai: "ไม่สามารถใช้ข้อความได้"
        )
    }

    private var messageUnavailableMessage: String {
        L10n.pick(
            language: language,
            english: "This device is not configured to send SMS or iMessage.",
            norwegian: "Denne enheten er ikke konfigurert for å sende SMS eller iMessage.",
            thai: "อุปกรณ์นี้ไม่ได้ตั้งค่าให้ส่ง SMS หรือ iMessage"
        )
    }

    private var messageUnavailableDismissTitle: String {
        L10n.pick(language: language, english: "OK", norwegian: "OK", thai: "ตกลง")
    }

    private var noRecipientsTitle: String {
        L10n.pick(
            language: language,
            english: "No phone numbers",
            norwegian: "Ingen telefonnumre",
            thai: "ไม่มีหมายเลขโทรศัพท์"
        )
    }

    private var noRecipientsMessage: String {
        L10n.pick(
            language: language,
            english: "No household member has a phone number. Add one in Contacts, or continue and enter a recipient in Messages.",
            norwegian: "Ingen husstandsmedlemmer har telefonnummer. Legg til et nummer under Kontakter, eller fortsett og skriv inn mottaker i Meldinger.",
            thai: "สมาชิกครัวเรือนไม่มีหมายเลขโทรศัพท์ เพิ่มหมายเลขในรายชื่อติดต่อ หรือดำเนินการต่อแล้วป้อนผู้รับในแอปข้อความ"
        )
    }

    private var addPhoneNumberTitle: String {
        L10n.pick(language: language, english: "Open Contacts", norwegian: "Åpne Kontakter", thai: "เปิดรายชื่อติดต่อ")
    }

    private var continueWithoutRecipientTitle: String {
        L10n.pick(language: language, english: "Continue", norwegian: "Fortsett", thai: "ดำเนินการต่อ")
    }

    private var cancelTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }
}

private struct FamilyMessageDraft: Identifiable {
    let id = UUID()
    let recipients: [String]
    let body: String
}

private struct FamilyMessageComposer: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            controller.dismiss(animated: true)
        }
    }
}

struct RolesSection: View {
    @State private var showsRoles = false

    let roles: [HouseholdRole]
    let householdMembers: [FamilyContact]
    let language: AppLanguage
    let addRole: () -> Void
    let deleteRole: (HouseholdRole) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DisclosureGroup(isExpanded: $showsRoles) {
                VStack(alignment: .leading, spacing: 14) {
                    Button(action: addRole) {
                        Label(roleAddTitle, systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    ForEach(roles) { role in
                        HouseholdRoleEditor(
                            role: role,
                            householdMembers: householdMembers,
                            language: language,
                            deleteAction: { deleteRole(role) }
                        )
                    }
                }
                .padding(.top, 12)
            } label: {
                HStack {
                    Text(L10n.text("household_roles", language: language))
                        .font(.title3.weight(.bold))
                        .accessibilityHeading(.h2)
                    Spacer(minLength: 8)
                    Text("\(roles.count)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var roleAddTitle: String {
        L10n.pick(
            language: language,
            english: "Add role",
            norwegian: "Legg til rolle",
            thai: "เพิ่มบทบาท"
        )
    }
}

struct SuppliesSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var searchText = ""
    @State private var showOnlyNeedingReview = false
    @State private var showsMarkAllReviewedConfirmation = false
    @State private var previousReviewDates: [UUID: Date] = [:]

    let homeSupplies: [SupplyItem]
    let carSupplies: [SupplyItem]
    let completionCount: Int
    let totalCount: Int
    @Binding var showOnlyMissing: Bool
    let language: AppLanguage
    let deleteItem: (SupplyItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(L10n.text("emergency_supplies", language: language))
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)
                Spacer()
                Text(
                    L10n.format(
                        "%lld/%lld %@",
                        language: language,
                        completionCount,
                        totalCount,
                        L10n.text("ready", language: language).lowercased()
                    )
                )
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.indigo.opacity(0.12), in: Capsule())
            }

            Text(L10n.text("supplies_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(searchPlaceholder, text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityAddTraits(.isSearchField)
                    .accessibilityIdentifier("supplySearchField")

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(clearSearchTitle)
                }
            }
            .padding(12)
            .background(InsetCardBackground())

            Menu {
                Button {
                    showOnlyMissing = false
                    showOnlyNeedingReview = false
                } label: {
                    Label(showAllTitle, systemImage: !showOnlyMissing && !showOnlyNeedingReview ? "checkmark" : "shippingbox")
                }

                Button {
                    showOnlyMissing = true
                    showOnlyNeedingReview = false
                } label: {
                    Label(missingFilterTitle, systemImage: showOnlyMissing ? "checkmark" : "circle.dashed")
                }

                Button {
                    showOnlyMissing = false
                    showOnlyNeedingReview = true
                } label: {
                    Label(reviewFilterTitle, systemImage: showOnlyNeedingReview ? "checkmark" : "calendar.badge.exclamationmark")
                }
            } label: {
                HStack(spacing: 10) {
                    Label(activeFilterTitle, systemImage: "line.3.horizontal.decrease.circle")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(14)
            .background(InsetCardBackground())
            .accessibilityLabel(filterTitle)
            .accessibilityValue(activeFilterTitle)
            .accessibilityIdentifier("missingSuppliesFilter")

            if !previousReviewDates.isEmpty {
                let undoLayout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                    : AnyLayout(HStackLayout(spacing: 12))

                undoLayout {
                    Label(reviewUpdateCompletedText, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    if !dynamicTypeSize.isAccessibilitySize {
                        Spacer(minLength: 8)
                    }

                    Button(undoTitle, action: undoMarkAllReviewed)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(14)
                .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityIdentifier("undoMarkAllSuppliesReviewed")
            }

            if showOnlyNeedingReview && !suppliesNeedingReview.isEmpty {
                Button {
                    showsMarkAllReviewedConfirmation = true
                } label: {
                    Label(markAllReviewedTitle, systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("markAllSuppliesReviewed")
            }

            if !searchText.isEmpty && filteredHomeSupplies.isEmpty && filteredCarSupplies.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .accessibilityIdentifier("noSupplySearchResults")
            } else if hasActiveFilter && filteredHomeSupplies.isEmpty && filteredCarSupplies.isEmpty {
                ContentUnavailableView {
                    Label(emptyFilterTitle, systemImage: "checkmark.seal.fill")
                } description: {
                    Text(emptyFilterDescription)
                } actions: {
                    Button(showAllTitle) {
                        showOnlyMissing = false
                        showOnlyNeedingReview = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .accessibilityIdentifier("allSuppliesReadyState")
            } else {
                if !filteredHomeSupplies.isEmpty {
                    SupplyGroupSection(
                        title: L10n.text("home", language: language),
                        storageLocation: .home,
                        items: filteredHomeSupplies,
                        accent: .indigo,
                        language: language,
                        deleteAction: deleteItem
                    )
                }

                if !filteredCarSupplies.isEmpty {
                    SupplyGroupSection(
                        title: evacuationListTitle,
                        storageLocation: .car,
                        items: filteredCarSupplies,
                        accent: .mint,
                        language: language,
                        deleteAction: deleteItem
                    )
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
        .alert(markAllReviewedConfirmationTitle, isPresented: $showsMarkAllReviewedConfirmation) {
            Button(markAllReviewedConfirmButtonTitle) {
                markAllReviewed()
            }
            Button(cancelTitle, role: .cancel) {}
        } message: {
            Text(markAllReviewedConfirmationMessage)
        }
    }

    private var filteredHomeSupplies: [SupplyItem] {
        filtered(homeSupplies)
    }

    private var filteredCarSupplies: [SupplyItem] {
        filtered(carSupplies)
    }

    private var evacuationListTitle: String {
        L10n.pick(
            language: language,
            english: "Grab / evacuation",
            norwegian: "Ta-med / evakuering",
            thai: "กระเป๋าฉุกเฉิน / อพยพ"
        )
    }

    private func filtered(_ items: [SupplyItem]) -> [SupplyItem] {
        let filteredByStatus: [SupplyItem]
        if showOnlyMissing {
            filteredByStatus = items.filter { !$0.isPacked }
        } else if showOnlyNeedingReview {
            filteredByStatus = items.filter {
                let status = $0.reviewStatus()
                return status == .overdue || status == .dueSoon
            }
        } else {
            filteredByStatus = items
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return filteredByStatus }

        return filteredByStatus.filter { item in
            item.name.localizedStandardContains(query)
                || item.quantity.localizedStandardContains(query)
                || item.detail.localizedStandardContains(query)
        }
    }

    private var searchPlaceholder: String {
        L10n.pick(language: language, english: "Search supplies", norwegian: "Søk i utstyr", thai: "ค้นหาอุปกรณ์")
    }

    private var clearSearchTitle: String {
        L10n.pick(language: language, english: "Clear search", norwegian: "Tøm søket", thai: "ล้างการค้นหา")
    }

    private var missingFilterTitle: String {
        L10n.pick(
            language: language,
            english: "Show only missing supplies",
            norwegian: "Vis bare manglende utstyr",
            thai: "แสดงเฉพาะอุปกรณ์ที่ขาด"
        )
    }

    private var reviewFilterTitle: String {
        L10n.pick(language: language, english: "Needs review", norwegian: "Må kontrolleres", thai: "ต้องตรวจสอบ")
    }

    private var filterTitle: String {
        L10n.pick(language: language, english: "Filter supplies", norwegian: "Filtrer utstyr", thai: "กรองอุปกรณ์")
    }

    private var activeFilterTitle: String {
        if showOnlyMissing { return missingFilterTitle }
        if showOnlyNeedingReview { return reviewFilterTitle }
        return showAllTitle
    }

    private var hasActiveFilter: Bool {
        showOnlyMissing || showOnlyNeedingReview
    }

    private var suppliesNeedingReview: [SupplyItem] {
        filteredHomeSupplies + filteredCarSupplies
    }

    private func markAllReviewed() {
        let nextReviewDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        let reviewedSupplies = suppliesNeedingReview
        previousReviewDates = Dictionary(
            uniqueKeysWithValues: reviewedSupplies.compactMap { item in
                item.reviewDate.map { (item.id, $0) }
            }
        )
        reviewedSupplies.forEach { $0.reviewDate = nextReviewDate }
    }

    private func undoMarkAllReviewed() {
        for item in homeSupplies + carSupplies {
            if let previousDate = previousReviewDates[item.id] {
                item.reviewDate = previousDate
            }
        }
        previousReviewDates = [:]
    }

    private var markAllReviewedTitle: String {
        L10n.pick(
            language: language,
            english: "Mark all as reviewed",
            norwegian: "Marker alle som kontrollert",
            thai: "ทำเครื่องหมายว่าตรวจสอบทั้งหมดแล้ว"
        )
    }

    private var markAllReviewedConfirmationTitle: String {
        L10n.pick(
            language: language,
            english: "Have you reviewed all supplies?",
            norwegian: "Har du kontrollert alt utstyret?",
            thai: "คุณตรวจสอบอุปกรณ์ทั้งหมดแล้วหรือไม่"
        )
    }

    private var markAllReviewedConfirmationMessage: String {
        let count = suppliesNeedingReview.count
        return L10n.pick(
            language: language,
            english: "The next review date for \(count) supplies will be set to one year from today.",
            norwegian: "Neste kontrolldato for \(count) varer settes til ett år fra i dag.",
            thai: "วันตรวจสอบครั้งถัดไปสำหรับอุปกรณ์ \(count) รายการจะถูกตั้งเป็นหนึ่งปีนับจากวันนี้"
        )
    }

    private var markAllReviewedConfirmButtonTitle: String {
        L10n.pick(language: language, english: "Yes, reviewed", norwegian: "Ja, kontrollert", thai: "ใช่ ตรวจสอบแล้ว")
    }

    private var cancelTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }

    private var reviewUpdateCompletedText: String {
        let count = previousReviewDates.count
        return L10n.pick(
            language: language,
            english: "Updated \(count) supplies",
            norwegian: "Oppdaterte \(count) varer",
            thai: "อัปเดตอุปกรณ์ \(count) รายการแล้ว"
        )
    }

    private var undoTitle: String {
        L10n.pick(language: language, english: "Undo", norwegian: "Angre", thai: "เลิกทำ")
    }

    private var allReadyTitle: String {
        L10n.pick(
            language: language,
            english: "Everything is ready",
            norwegian: "Alt er klart",
            thai: "ทุกอย่างพร้อมแล้ว"
        )
    }

    private var allReadyDescription: String {
        L10n.pick(
            language: language,
            english: "There are no missing supplies in your checklist.",
            norwegian: "Det er ingen manglende varer i sjekklisten.",
            thai: "ไม่มีอุปกรณ์ที่ขาดในรายการตรวจสอบ"
        )
    }

    private var emptyFilterTitle: String {
        showOnlyNeedingReview
            ? L10n.pick(language: language, english: "Nothing needs review", norwegian: "Ingenting må kontrolleres", thai: "ไม่มีสิ่งที่ต้องตรวจสอบ")
            : allReadyTitle
    }

    private var emptyFilterDescription: String {
        showOnlyNeedingReview
            ? L10n.pick(language: language, english: "No supplies have an upcoming or overdue review date.", norwegian: "Ingen varer har en kommende eller utløpt kontrolldato.", thai: "ไม่มีอุปกรณ์ที่ใกล้หรือเลยกำหนดตรวจสอบ")
            : allReadyDescription
    }

    private var showAllTitle: String {
        L10n.pick(language: language, english: "Show all supplies", norwegian: "Vis alt utstyr", thai: "แสดงอุปกรณ์ทั้งหมด")
    }
}

struct HomePreparednessGuideSection: View {
    @Binding var householdMemberCount: Int
    @State private var showsGuideDetails = false
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "house.and.flag.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(introduction)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Stepper(value: $householdMemberCount, in: 1...12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(householdTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(householdSizeText)
                        .font(.headline)
                }
            }
            .padding(14)
            .background(InsetCardBackground())

            HStack(spacing: 10) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text(waterAmount)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            DisclosureGroup(isExpanded: $showsGuideDetails) {
                VStack(alignment: .leading, spacing: 16) {
                    PreparednessGuideCard(
                        title: waterTitle,
                        amount: waterAmount,
                        storage: waterStorage,
                        examples: waterExamples,
                        systemImage: "drop.fill",
                        tint: .blue,
                        language: language
                    )

                    PreparednessGuideCard(
                        title: foodTitle,
                        amount: foodAmount,
                        storage: foodStorage,
                        examples: foodExamples,
                        systemImage: "takeoutbag.and.cup.and.straw.fill",
                        tint: .orange,
                        language: language
                    )

                    PreparednessGuideCard(
                        title: warmthTitle,
                        amount: warmthAmount,
                        storage: warmthStorage,
                        examples: warmthExamples,
                        systemImage: "flame.fill",
                        tint: .red,
                        language: language
                    )

                    PreparednessGuideCard(
                        title: essentialsTitle,
                        amount: essentialsAmount,
                        storage: essentialsStorage,
                        examples: essentialsExamples,
                        systemImage: "cross.case.fill",
                        tint: .green,
                        language: language
                    )

                    Text(reviewAdvice)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let sourceURL = URL(string: "https://www.dsb.no/egenberedskap") {
                        Link(destination: sourceURL) {
                            Label(sourceTitle, systemImage: "arrow.up.right.square")
                                .font(.footnote.weight(.semibold))
                        }
                    }
                }
                .padding(.top, 14)
            } label: {
                Label(guideDetailsTitle, systemImage: "info.circle.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(.indigo)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var guideDetailsTitle: String {
        L10n.pick(
            language: language,
            english: "Storage guide and examples",
            norwegian: "Lagringsguide og eksempler",
            thai: "คำแนะนำการจัดเก็บและตัวอย่าง"
        )
    }

    private var title: String {
        L10n.pick(language: language, english: "What every home should have", norwegian: "Dette bør alle ha hjemme", thai: "สิ่งที่ทุกบ้านควรมี")
    }

    private var introduction: String {
        L10n.pick(
            language: language,
            english: "Norwegian authorities recommend being able to manage for one week without normal access to power, water, shops or communication.",
            norwegian: "Norske myndigheter anbefaler at du kan klare deg i én uke uten normal tilgang til strøm, vann, butikker eller kommunikasjon.",
            thai: "ทางการนอร์เวย์แนะนำให้เตรียมพร้อมดูแลตนเองเป็นเวลาหนึ่งสัปดาห์ หากไฟฟ้า น้ำ ร้านค้า หรือการสื่อสารใช้งานไม่ได้ตามปกติ"
        )
    }

    private var waterTitle: String {
        L10n.pick(language: language, english: "Water", norwegian: "Vann", thai: "น้ำ")
    }

    private var waterAmount: String {
        let litres = householdMemberCount * 20
        return L10n.pick(
            language: language,
            english: "Around \(litres) litres in total — 20 litres per person",
            norwegian: "Omtrent \(litres) liter totalt – 20 liter per person",
            thai: "รวมประมาณ \(litres) ลิตร — 20 ลิตรต่อคน"
        )
    }

    private var householdTitle: String {
        L10n.pick(language: language, english: "People in the household", norwegian: "Personer i husstanden", thai: "จำนวนคนในครัวเรือน")
    }

    private var householdSizeText: String {
        if householdMemberCount == 1 {
            return L10n.pick(language: language, english: "1 person", norwegian: "1 person", thai: "1 คน")
        }

        return L10n.pick(
            language: language,
            english: "\(householdMemberCount) people",
            norwegian: "\(householdMemberCount) personer",
            thai: "\(householdMemberCount) คน"
        )
    }

    private var waterStorage: String {
        L10n.pick(
            language: language,
            english: "Store in clean, food-safe containers in a cool, dark place, away from chemicals and frost.",
            norwegian: "Oppbevar i rene, matgodkjente beholdere på et mørkt og kjølig sted, unna kjemikalier og frost.",
            thai: "เก็บในภาชนะสะอาดที่ปลอดภัยสำหรับอาหาร ในที่มืดและเย็น ห่างจากสารเคมีและน้ำค้างแข็ง"
        )
    }

    private var waterExamples: String {
        L10n.pick(language: language, english: "Filled water containers or unopened bottled water.", norwegian: "Fylte vanndunker eller uåpnede flasker med vann.", thai: "ถังน้ำที่เติมแล้วหรือน้ำดื่มบรรจุขวดที่ยังไม่เปิด")
    }

    private var foodTitle: String {
        L10n.pick(language: language, english: "Food", norwegian: "Mat", thai: "อาหาร")
    }

    private var foodAmount: String {
        L10n.pick(language: language, english: "Enough for everyone for one week", norwegian: "Nok til alle i én uke", thai: "เพียงพอสำหรับทุกคนเป็นเวลาหนึ่งสัปดาห์")
    }

    private var foodStorage: String {
        L10n.pick(
            language: language,
            english: "Choose food that keeps at room temperature. Use and replace it regularly so the oldest food is eaten first.",
            norwegian: "Velg mat som tåler romtemperatur. Bruk og erstatt varene jevnlig, slik at den eldste maten brukes først.",
            thai: "เลือกอาหารที่เก็บได้ในอุณหภูมิห้อง ใช้และเติมของเป็นประจำ โดยใช้ของเก่าก่อน"
        )
    }

    private var foodExamples: String {
        L10n.pick(
            language: language,
            english: "Crispbread, oats, canned beans and meals, nuts, dried fruit, energy bars, rice and pasta.",
            norwegian: "Knekkebrød, havregryn, hermetiske bønner og middager, nøtter, tørket frukt, energibarer, ris og pasta.",
            thai: "ขนมปังกรอบ ข้าวโอ๊ต ถั่วและอาหารกระป๋อง ถั่วเปลือกแข็ง ผลไม้แห้ง แท่งพลังงาน ข้าว และพาสต้า"
        )
    }

    private var warmthTitle: String {
        L10n.pick(language: language, english: "Warmth, light and cooking", norwegian: "Varme, lys og matlaging", thai: "ความอบอุ่น แสงสว่าง และการทำอาหาร")
    }

    private var warmthAmount: String {
        L10n.pick(language: language, english: "A safe solution for a week without electricity", norwegian: "En trygg løsning for én uke uten strøm", thai: "วิธีที่ปลอดภัยสำหรับหนึ่งสัปดาห์ที่ไม่มีไฟฟ้า")
    }

    private var warmthStorage: String {
        L10n.pick(
            language: language,
            english: "Keep equipment dry and accessible. Store fuel safely and only use appliances where the manufacturer permits.",
            norwegian: "Hold utstyret tørt og lett tilgjengelig. Oppbevar brensel sikkert, og bruk apparater bare der produsenten tillater det.",
            thai: "เก็บอุปกรณ์ให้แห้งและหยิบใช้สะดวก เก็บเชื้อเพลิงอย่างปลอดภัย และใช้อุปกรณ์เฉพาะในสถานที่ที่ผู้ผลิตอนุญาต"
        )
    }

    private var warmthExamples: String {
        L10n.pick(
            language: language,
            english: "Warm clothes, blankets or sleeping bags, flashlights, batteries, matches, candles and a safe cooking option.",
            norwegian: "Varme klær, pledd eller soveposer, lommelykter, batterier, fyrstikker, stearinlys og en trygg kokemulighet.",
            thai: "เสื้อผ้าอุ่น ผ้าห่มหรือถุงนอน ไฟฉาย แบตเตอรี่ ไม้ขีด เทียน และอุปกรณ์ทำอาหารที่ปลอดภัย"
        )
    }

    private var essentialsTitle: String {
        L10n.pick(language: language, english: "Health and information", norwegian: "Helse og informasjon", thai: "สุขภาพและข้อมูล")
    }

    private var essentialsAmount: String {
        L10n.pick(language: language, english: "At least seven extra days of regular medicines", norwegian: "Minst sju ekstra dager med faste medisiner", thai: "ยาประจำอย่างน้อยสำรองอีกเจ็ดวัน")
    }

    private var essentialsStorage: String {
        L10n.pick(
            language: language,
            english: "Keep medicines as directed, charge power banks, and store a paper contact list with the kit.",
            norwegian: "Oppbevar medisiner som anvist, lad batteribanker og legg en kontaktliste på papir sammen med utstyret.",
            thai: "เก็บยาตามคำแนะนำ ชาร์จแบตเตอรี่สำรอง และเก็บรายชื่อผู้ติดต่อบนกระดาษไว้กับชุดอุปกรณ์"
        )
    }

    private var essentialsExamples: String {
        L10n.pick(
            language: language,
            english: "First aid kit, hygiene products, DAB radio, power bank, spare batteries, cash and several payment cards.",
            norwegian: "Førstehjelpsutstyr, hygieneartikler, DAB-radio, batteribank, reservebatterier, kontanter og flere betalingskort.",
            thai: "ชุดปฐมพยาบาล ของใช้สุขอนามัย วิทยุ DAB แบตเตอรี่สำรอง ถ่านสำรอง เงินสด และบัตรชำระเงินหลายใบ"
        )
    }

    private var reviewAdvice: String {
        L10n.pick(
            language: language,
            english: "Review the supplies at least once a year and adapt them to children, health needs, pets and your home.",
            norwegian: "Gå gjennom lageret minst én gang i året, og tilpass det til barn, helsebehov, kjæledyr og boligen din.",
            thai: "ตรวจสอบสิ่งของอย่างน้อยปีละครั้ง และปรับให้เหมาะกับเด็ก ความต้องการด้านสุขภาพ สัตว์เลี้ยง และที่อยู่อาศัยของคุณ"
        )
    }

    private var sourceTitle: String {
        L10n.pick(language: language, english: "Official advice from DSB", norwegian: "Offisielle råd fra DSB", thai: "คำแนะนำอย่างเป็นทางการจาก DSB")
    }
}

private struct PreparednessGuideCard: View {
    let title: String
    let amount: String
    let storage: String
    let examples: String
    let systemImage: String
    let tint: Color
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            PreparednessGuideDetail(
                label: L10n.pick(language: language, english: "Amount", norwegian: "Mengde", thai: "ปริมาณ"),
                text: amount
            )
            PreparednessGuideDetail(
                label: L10n.pick(language: language, english: "Storage", norwegian: "Oppbevaring", thai: "การจัดเก็บ"),
                text: storage
            )
            PreparednessGuideDetail(
                label: L10n.pick(language: language, english: "Examples", norwegian: "Eksempler", thai: "ตัวอย่าง"),
                text: examples
            )
        }
        .padding(16)
        .background(InsetCardBackground())
    }
}

private struct PreparednessGuideDetail: View {
    let label: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct DrillsSection: View {
    @State private var completionDates: [String: Date] = [:]

    let drills: [Drill]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("scenario_drills", language: language))
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            ForEach(drills) { drill in
                DrillRow(
                    drill: drill,
                    completionDate: completionDates[drill.id],
                    language: language,
                    markCompleted: { markCompleted(drill) }
                )
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
        .task {
            completionDates = DrillCompletionStore.load()
            for await _ in NotificationCenter.default.notifications(named: DrillCompletionStore.didChangeNotification) {
                completionDates = DrillCompletionStore.load()
            }
        }
    }

    private func markCompleted(_ drill: Drill) {
        completionDates[drill.id] = Date()
        DrillCompletionStore.save(completionDates)
    }
}

private struct DrillRow: View {
    let drill: Drill
    let completionDate: Date?
    let language: AppLanguage
    let markCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: statusSystemImage)
                    .font(.title3)
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.title)
                        .font(.headline)
                    Text("\(drill.frequency) • \(drill.duration)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if completionDate != nil {
                        Text(lastCompletedTitle)
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text(nextDueTitle)
                            .font(.caption.weight(isOverdue ? .semibold : .regular))
                            .foregroundStyle(isOverdue ? .orange : .secondary)
                    }
                }
                Spacer(minLength: 8)
            }

            Button(action: markCompleted) {
                Label(markCompletedTitle, systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("completeDrill.\(drill.id)")
        }
        .padding(14)
        .background(InsetCardBackground())
    }

    private var lastCompletedTitle: String {
        guard let completionDate else { return "" }
        let date = completionDate.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .year()
                .locale(AppLanguage.locale(for: language))
        )
        return L10n.pick(
            language: language,
            english: "Last completed: \(date)",
            norwegian: "Sist gjennomført: \(date)",
            thai: "ทำล่าสุด: \(date)"
        )
    }

    private var markCompletedTitle: String {
        completionDate == nil
            ? L10n.pick(language: language, english: "Mark as completed", norwegian: "Marker som gjennomført", thai: "ทำเครื่องหมายว่าเสร็จแล้ว")
            : L10n.pick(language: language, english: "Completed again today", norwegian: "Gjennomført på nytt i dag", thai: "ทำเสร็จอีกครั้งวันนี้")
    }

    private var nextDueDate: Date? {
        guard let completionDate else { return nil }
        return drill.recurrence.nextDueDate(after: completionDate)
    }

    private var isOverdue: Bool {
        guard let nextDueDate else { return false }
        return nextDueDate <= Date()
    }

    private var statusSystemImage: String {
        if completionDate == nil { return "timer" }
        return isOverdue ? "calendar.badge.exclamationmark" : "checkmark.circle.fill"
    }

    private var statusColor: Color {
        if completionDate == nil { return .purple }
        return isOverdue ? .orange : .green
    }

    private var nextDueTitle: String {
        guard let nextDueDate else { return "" }
        let date = nextDueDate.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .year()
                .locale(AppLanguage.locale(for: language))
        )
        if isOverdue {
            return L10n.pick(language: language, english: "Due since: \(date)", norwegian: "Forfalt: \(date)", thai: "ครบกำหนดตั้งแต่: \(date)")
        }
        return L10n.pick(language: language, english: "Next exercise: \(date)", norwegian: "Neste øvelse: \(date)", thai: "การฝึกครั้งถัดไป: \(date)")
    }
}

private struct FamilyContactEditor: View {
    @Bindable var contact: FamilyContact
    @State private var showsDeleteConfirmation = false
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(
                title: L10n.text("family_contact", language: language),
                deleteItemName: contact.name,
                language: language
            ) {
                showsDeleteConfirmation = true
            }
            TextField(L10n.text("name", language: language), text: $contact.name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
            TextField(L10n.text("role", language: language), text: $contact.role)
                .textFieldStyle(.roundedBorder)
            Picker(contactTypeTitle, selection: $contact.isHouseholdMember) {
                Text(householdMemberTitle).tag(true)
                Text(outsideContactTitle).tag(false)
            }
            .pickerStyle(.segmented)
            TextField(L10n.text("phone_number", language: language), text: $contact.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            if showsInvalidPhoneNumber {
                Label(invalidPhoneNumberTitle, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            TextField(L10n.text("notes", language: language), text: $contact.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack(spacing: 10) {
                if let phoneURL = phoneURL(for: contact.phoneNumber) {
                    Link(destination: phoneURL) {
                        actionChip(title: L10n.text("call", language: language), systemImage: "phone.fill", tint: .green)
                    }
                }
                if let messageURL = messageURL(for: contact.phoneNumber) {
                    Link(destination: messageURL) {
                        actionChip(title: L10n.text("text", language: language), systemImage: "message.fill", tint: .blue)
                    }
                }
            }
        }
        .padding(14)
        .background(InsetCardBackground())
        .alert(deleteTitle, isPresented: $showsDeleteConfirmation) {
            Button(deleteButtonTitle, role: .destructive, action: deleteAction)
            Button(cancelButtonTitle, role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    private var deleteTitle: String {
        L10n.pick(language: language, english: "Delete contact?", norwegian: "Slette kontakt?", thai: "ลบผู้ติดต่อหรือไม่")
    }

    private var deleteMessage: String {
        let name = contact.name.isEmpty ? L10n.text("family_contact", language: language) : contact.name
        return L10n.pick(
            language: language,
            english: "\(name) will be permanently removed from your contacts.",
            norwegian: "\(name) fjernes permanent fra kontaktene dine.",
            thai: "\(name) จะถูกลบออกจากรายชื่อติดต่ออย่างถาวร"
        )
    }

    private var deleteButtonTitle: String { L10n.pick(language: language, english: "Delete", norwegian: "Slett", thai: "ลบ") }
    private var cancelButtonTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }
    private var contactTypeTitle: String { L10n.pick(language: language, english: "Contact type", norwegian: "Kontakttype", thai: "ประเภทผู้ติดต่อ") }
    private var householdMemberTitle: String { L10n.pick(language: language, english: "Household", norwegian: "Husstand", thai: "ครัวเรือน") }
    private var outsideContactTitle: String { L10n.pick(language: language, english: "External", norwegian: "Ekstern", thai: "ภายนอก") }
    private var showsInvalidPhoneNumber: Bool {
        !contact.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !FamilyMessageRecipientResolver.isValid(contact.phoneNumber)
    }
    private var invalidPhoneNumberTitle: String {
        L10n.pick(
            language: language,
            english: "Check the phone number. It will not be included in family SMS updates.",
            norwegian: "Kontroller telefonnummeret. Det blir ikke tatt med i SMS-oppdateringer til familien.",
            thai: "ตรวจสอบหมายเลขโทรศัพท์ หมายเลขนี้จะไม่รวมอยู่ในการอัปเดต SMS สำหรับครอบครัว"
        )
    }
}

private struct ImportantNumberEditor: View {
    @Bindable var number: ImportantNumber
    @State private var showsDeleteConfirmation = false
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(
                title: L10n.text("important_number", language: language),
                deleteItemName: number.label,
                language: language
            ) {
                showsDeleteConfirmation = true
            }
            TextField(L10n.text("label", language: language), text: $number.label)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("phone_number", language: language), text: $number.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            TextField(L10n.text("notes", language: language), text: $number.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack(spacing: 10) {
                if let phoneURL = phoneURL(for: number.phoneNumber) {
                    Link(destination: phoneURL) {
                        actionChip(title: L10n.text("call", language: language), systemImage: "phone.fill", tint: .green)
                    }
                }
                if let messageURL = messageURL(for: number.phoneNumber) {
                    Link(destination: messageURL) {
                        actionChip(title: L10n.text("text", language: language), systemImage: "message.fill", tint: .blue)
                    }
                }
            }
        }
        .padding(14)
        .background(InsetCardBackground())
        .alert(deleteTitle, isPresented: $showsDeleteConfirmation) {
            Button(deleteButtonTitle, role: .destructive, action: deleteAction)
            Button(cancelButtonTitle, role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    private var deleteTitle: String {
        L10n.pick(language: language, english: "Delete number?", norwegian: "Slette nummer?", thai: "ลบหมายเลขหรือไม่")
    }

    private var deleteMessage: String {
        let label = number.label.isEmpty ? L10n.text("important_number", language: language) : number.label
        return L10n.pick(
            language: language,
            english: "\(label) will be permanently removed from your important numbers.",
            norwegian: "\(label) fjernes permanent fra viktige numre.",
            thai: "\(label) จะถูกลบออกจากหมายเลขสำคัญอย่างถาวร"
        )
    }

    private var deleteButtonTitle: String { L10n.pick(language: language, english: "Delete", norwegian: "Slett", thai: "ลบ") }
    private var cancelButtonTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }
}

private struct HouseholdRoleEditor: View {
    @Bindable var role: HouseholdRole
    @State private var showsDeleteConfirmation = false
    let householdMembers: [FamilyContact]
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(
                title: roleHeaderTitle,
                deleteItemName: role.title,
                language: language
            ) {
                showsDeleteConfirmation = true
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: role.systemImage)
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: 28)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 10) {
                    TextField(roleTitlePlaceholder, text: $role.title)
                        .textFieldStyle(.roundedBorder)
                    if householdMembers.isEmpty {
                        TextField(rolePersonPlaceholder, text: $role.person)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                    } else {
                        Picker(rolePersonPlaceholder, selection: $role.person) {
                            Text(rolePersonPlaceholder).tag("")
                            if !role.person.isEmpty,
                               !householdMembers.contains(where: { $0.name == role.person }) {
                                Text(role.person).tag(role.person)
                            }
                            ForEach(householdMembers) { member in
                                Text(member.name.isEmpty ? unnamedMemberTitle : member.name)
                                    .tag(member.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    TextField(roleTaskPlaceholder, text: $role.task, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
            }
        }
        .padding(14)
        .background(InsetCardBackground())
        .alert(deleteTitle, isPresented: $showsDeleteConfirmation) {
            Button(deleteButtonTitle, role: .destructive, action: deleteAction)
            Button(cancelButtonTitle, role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    private var deleteTitle: String {
        L10n.pick(language: language, english: "Delete role?", norwegian: "Slette rolle?", thai: "ลบบทบาทหรือไม่")
    }

    private var deleteMessage: String {
        let title = role.title.isEmpty ? roleHeaderTitle : role.title
        return L10n.pick(
            language: language,
            english: "\(title) will be permanently removed from the household plan.",
            norwegian: "\(title) fjernes permanent fra husstandsplanen.",
            thai: "\(title) จะถูกลบออกจากแผนครัวเรือนอย่างถาวร"
        )
    }

    private var deleteButtonTitle: String { L10n.pick(language: language, english: "Delete", norwegian: "Slett", thai: "ลบ") }
    private var cancelButtonTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }

    private var roleHeaderTitle: String {
        L10n.pick(
            language: language,
            english: "Household role",
            norwegian: "Husholdningsrolle",
            thai: "บทบาทในครัวเรือน"
        )
    }

    private var unnamedMemberTitle: String {
        L10n.pick(
            language: language,
            english: "Unnamed household member",
            norwegian: "Husstandsmedlem uten navn",
            thai: "สมาชิกในครัวเรือนที่ไม่มีชื่อ"
        )
    }

    private var roleTitlePlaceholder: String {
        L10n.pick(
            language: language,
            english: "Role title",
            norwegian: "Rollenavn",
            thai: "ชื่อบทบาท"
        )
    }

    private var rolePersonPlaceholder: String {
        L10n.pick(
            language: language,
            english: "Assigned person",
            norwegian: "Ansvarlig person",
            thai: "ผู้รับผิดชอบ"
        )
    }

    private var roleTaskPlaceholder: String {
        L10n.pick(
            language: language,
            english: "Primary task",
            norwegian: "Hovedoppgave",
            thai: "งานหลัก"
        )
    }
}

private struct SupplyGroupSection: View {
    let title: String
    let storageLocation: SupplyLocation
    let items: [SupplyItem]
    let accent: Color
    let language: AppLanguage
    let deleteAction: (SupplyItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(title, systemImage: storageLocation == .home ? "house.fill" : "car.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            ForEach(items) { item in
                SupplyItemEditor(
                    item: item,
                    storageLocation: storageLocation,
                    accent: accent,
                    language: language,
                    deleteAction: { deleteAction(item) }
                )
            }
        }
    }
}

private struct SupplyItemEditor: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var item: SupplyItem
    @State private var showsDetails = false
    @State private var showsDeleteConfirmation = false
    let storageLocation: SupplyLocation
    let accent: Color
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(
                title: item.name.isEmpty
                    ? (storageLocation == .home ? L10n.text("home_item", language: language) : L10n.text("car_item", language: language))
                    : item.name,
                language: language,
                deleteAction: { showsDeleteConfirmation = true }
            )

            Button {
                item.isPacked.toggle()
            } label: {
                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(spacing: 10))

                layout {
                    Label(
                        item.isPacked ? L10n.text("stocked", language: language) : L10n.text("missing", language: language),
                        systemImage: item.isPacked ? "checkmark.circle.fill" : "circle"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                    if !dynamicTypeSize.isAccessibilitySize {
                        Spacer()
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isPacked ? L10n.text("stocked", language: language) : L10n.text("missing", language: language))
            .accessibilityIdentifier("supplyPackedStatus-\(item.id.uuidString)")

            Button {
                showsDetails.toggle()
            } label: {
                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(spacing: 10))

                layout {
                    Label(detailsTitle, systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                    if !dynamicTypeSize.isAccessibilitySize {
                        Spacer()
                        Image(systemName: showsDetails ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .accessibilityIdentifier("supplyDetails-\(item.id.uuidString)")

            if showsDetails {
                VStack(alignment: .leading, spacing: 10) {
                    TextField(L10n.text("item_name", language: language), text: $item.name)
                        .textFieldStyle(.roundedBorder)

                    TextField(quantityTitle, text: $item.quantity)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("supplyQuantityField")

                    TextField(L10n.text("what_to_keep_notes", language: language), text: $item.detail, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)

                    Toggle(reviewDateToggleTitle, isOn: reviewDateEnabledBinding)
                        .accessibilityIdentifier("supplyReviewDateToggle")

                    if item.reviewDate != nil {
                        DatePicker(
                            reviewDateTitle,
                            selection: reviewDateBinding,
                            displayedComponents: .date
                        )
                    }
                }
            }

            if let reviewDate = item.reviewDate {
                let reviewStatus = item.reviewStatus()

                SupplyReviewStatusLabel(
                    status: reviewStatus,
                    reviewDate: reviewDate,
                    language: language
                )

                if reviewStatus == .overdue || reviewStatus == .dueSoon {
                    Button {
                        markReviewed()
                    } label: {
                        Label(markReviewedTitle, systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("markSupplyReviewed-\(item.id.uuidString)")
                }
            }
        }
        .padding(14)
        .background(InsetCardBackground())
        .alert(deleteConfirmationTitle, isPresented: $showsDeleteConfirmation) {
            Button(deleteButtonTitle, role: .destructive, action: deleteAction)
            Button(cancelButtonTitle, role: .cancel) {}
        } message: {
            Text(deleteConfirmationMessage)
        }
    }

    private var deleteConfirmationTitle: String {
        L10n.pick(language: language, english: "Delete supply?", norwegian: "Slette utstyr?", thai: "ลบอุปกรณ์หรือไม่")
    }

    private var deleteConfirmationMessage: String {
        L10n.pick(
            language: language,
            english: "\(item.name) will be permanently removed from your checklist.",
            norwegian: "\(item.name) fjernes permanent fra sjekklisten.",
            thai: "\(item.name) จะถูกลบออกจากรายการตรวจสอบอย่างถาวร"
        )
    }

    private var deleteButtonTitle: String {
        L10n.pick(language: language, english: "Delete", norwegian: "Slett", thai: "ลบ")
    }

    private var cancelButtonTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }

    private var reviewDateEnabledBinding: Binding<Bool> {
        Binding(
            get: { item.reviewDate != nil },
            set: { isEnabled in
                item.reviewDate = isEnabled ? defaultReviewDate : nil
            }
        )
    }

    private var reviewDateBinding: Binding<Date> {
        Binding(
            get: { item.reviewDate ?? defaultReviewDate },
            set: { item.reviewDate = $0 }
        )
    }

    private var defaultReviewDate: Date {
        Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    }

    private func markReviewed() {
        item.reviewDate = defaultReviewDate
    }

    private var markReviewedTitle: String {
        L10n.pick(
            language: language,
            english: "Reviewed today",
            norwegian: "Kontrollert i dag",
            thai: "ตรวจสอบแล้ววันนี้"
        )
    }

    private var detailsTitle: String {
        L10n.pick(
            language: language,
            english: showsDetails ? "Hide details" : "Edit details",
            norwegian: showsDetails ? "Skjul detaljer" : "Rediger detaljer",
            thai: showsDetails ? "ซ่อนรายละเอียด" : "แก้ไขรายละเอียด"
        )
    }

    private var quantityTitle: String {
        L10n.pick(language: language, english: "Quantity", norwegian: "Mengde", thai: "ปริมาณ")
    }

    private var reviewDateToggleTitle: String {
        L10n.pick(language: language, english: "Set a review date", norwegian: "Angi kontrolldato", thai: "กำหนดวันที่ตรวจสอบ")
    }

    private var reviewDateTitle: String {
        L10n.pick(language: language, english: "Review or replace", norwegian: "Kontroller eller erstatt", thai: "ตรวจสอบหรือเปลี่ยน")
    }
}

struct NewSupplySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = ""
    @State private var detail = ""
    @State private var hasReviewDate = false
    @State private var reviewDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()

    let location: SupplyLocation
    let language: AppLanguage
    let save: (String, String, String, Date?) -> Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(nameTitle, text: $name)
                    TextField(quantityTitle, text: $quantity)
                    TextField(notesTitle, text: $detail, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    Toggle(reviewToggleTitle, isOn: $hasReviewDate)
                    if hasReviewDate {
                        DatePicker(reviewDateTitle, selection: $reviewDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cancelTitle) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle) {
                        if save(name, quantity, detail, hasReviewDate ? reviewDate : nil) {
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: location == .home ? "New home item" : "New car item",
            norwegian: location == .home ? "Nytt hjemmeutstyr" : "Nytt bilutstyr",
            thai: location == .home ? "อุปกรณ์ในบ้านใหม่" : "อุปกรณ์รถใหม่"
        )
    }

    private var nameTitle: String { L10n.pick(language: language, english: "Name", norwegian: "Navn", thai: "ชื่อ") }
    private var quantityTitle: String { L10n.pick(language: language, english: "Quantity", norwegian: "Mengde", thai: "ปริมาณ") }
    private var notesTitle: String { L10n.pick(language: language, english: "Notes", norwegian: "Notater", thai: "หมายเหตุ") }
    private var reviewToggleTitle: String { L10n.pick(language: language, english: "Set a review date", norwegian: "Angi kontrolldato", thai: "กำหนดวันที่ตรวจสอบ") }
    private var reviewDateTitle: String { L10n.pick(language: language, english: "Review or replace", norwegian: "Kontroller eller erstatt", thai: "ตรวจสอบหรือเปลี่ยน") }
    private var cancelTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }
    private var saveTitle: String { L10n.pick(language: language, english: "Save", norwegian: "Lagre", thai: "บันทึก") }
}

private struct SupplyReviewStatusLabel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let status: SupplyReviewStatus
    let reviewDate: Date
    let language: AppLanguage

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))

        layout {
            Label(title, systemImage: systemImage)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer()
            }
            Text(reviewDate, format: .dateTime.day().month().year())
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var title: String {
        switch status {
        case .none, .scheduled:
            L10n.pick(language: language, english: "Review planned", norwegian: "Kontroll planlagt", thai: "วางแผนตรวจสอบแล้ว")
        case .dueSoon:
            L10n.pick(language: language, english: "Review soon", norwegian: "Kontroller snart", thai: "ตรวจสอบเร็ว ๆ นี้")
        case .overdue:
            L10n.pick(language: language, english: "Review overdue", norwegian: "Kontroll utløpt", thai: "เลยกำหนดตรวจสอบ")
        }
    }

    private var systemImage: String {
        switch status {
        case .none, .scheduled: "calendar"
        case .dueSoon: "clock.badge.exclamationmark"
        case .overdue: "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .none, .scheduled: .blue
        case .dueSoon: .orange
        case .overdue: .red
        }
    }
}

struct DashboardCardBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(DashboardPalette.cardFill(for: colorScheme))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.22), lineWidth: 1)
            }
    }
}

struct InsetCardBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(DashboardPalette.insetFill(for: colorScheme))
    }
}

private func header(
    title: String,
    deleteItemName: String? = nil,
    language: AppLanguage,
    deleteAction: @escaping () -> Void
) -> some View {
    let accessibleItemName = deleteItemName.flatMap { $0.isEmpty ? nil : $0 } ?? title

    return HStack {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        Spacer()
        Button(role: .destructive, action: deleteAction) {
            Image(systemName: "trash")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            L10n.pick(
                language: language,
                english: "Delete \(accessibleItemName)",
                norwegian: "Slett \(accessibleItemName)",
                thai: "ลบ \(accessibleItemName)"
            )
        )
    }
}

private func actionChip(title: String, systemImage: String, tint: Color) -> some View {
    Label(title, systemImage: systemImage)
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12), in: Capsule())
        .foregroundStyle(.primary)
}

private func phoneURL(for phoneNumber: String) -> URL? {
    guard let sanitized = PhoneLinkBuilder.sanitizedNumber(phoneNumber) else { return nil }
    return URL(string: "tel:\(sanitized)")
}

private func messageURL(for phoneNumber: String) -> URL? {
    guard let sanitized = PhoneLinkBuilder.sanitizedNumber(phoneNumber) else { return nil }
    return URL(string: "sms:\(sanitized)")
}

enum PhoneLinkBuilder {
    static func sanitizedNumber(_ phoneNumber: String) -> String? {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let allowedFormattingCharacters = CharacterSet(charactersIn: " +-().")
        guard trimmed.unicodeScalars.allSatisfy({
            CharacterSet.decimalDigits.contains($0) || allowedFormattingCharacters.contains($0)
        }) else {
            return nil
        }

        let hasInternationalPrefix = trimmed.first == "+"
        guard !trimmed.dropFirst().contains("+") else { return nil }

        let digits = trimmed.compactMap(\.wholeNumberValue).map(String.init).joined()
        guard digits.count >= 3 else { return nil }
        return hasInternationalPrefix ? "+\(digits)" : digits
    }
}
