import SwiftUI

struct EmergencyTypePickerSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var selection: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Menu {
                ForEach(EmergencyType.allCases) { emergencyType in
                    Button {
                        selection = emergencyType
                    } label: {
                        Text(emergencyType.localizedName(in: language))
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    if !dynamicTypeSize.isAccessibilitySize {
                        Image(systemName: selection.systemImage)
                    }

                    Text(selection.localizedName(in: language))
                        .font(.headline)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.body.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(.secondary.opacity(0.10))
            )
            .accessibilityLabel("\(title): \(selection.localizedName(in: language))")
            .accessibilityIdentifier("emergencyTypePicker")
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Scenario",
            norwegian: "Scenario",
            thai: "สถานการณ์"
        )
    }
}

private extension EmergencyType {
    var systemImage: String {
        switch self {
        case .powerOutage: "bolt.slash.fill"
        case .powerAndCommunicationsOutage: "antenna.radiowaves.left.and.right.slash"
        case .flood: "water.waves"
        case .extremeWeather: "cloud.bolt.rain.fill"
        case .landslide: "exclamationmark.triangle.fill"
        case .wildfire: "flame.fill"
        case .houseFire: "house.lodge.fill"
        case .waterOutage: "drop.triangle.fill"
        case .evacuation: "figure.walk.departure"
        case .hazardousRelease: "aqi.medium"
        case .warOrSecurityIncident: "shield.lefthalf.filled"
        }
    }
}

struct EmergencyActionsSection: View {
    let emergencyType: EmergencyType
    let household: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: "checklist")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(localized(template.summaryKey))
                .foregroundStyle(.secondary)

            ForEach(template.actions) { action in
                Label {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(localized(action.titleKey))
                            .font(.headline)
                        Text(localized(action.detailKey))
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: action.id.contains("followOfficial") ? "antenna.radiowaves.left.and.right" : "house.and.flag.fill")
                        .foregroundStyle(action.id.contains("followOfficial") ? .orange : .blue)
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "What to do",
            norwegian: "Hva du bør gjøre",
            thai: "สิ่งที่ควรทำ"
        )
    }

    private var template: EmergencyPlanTemplate {
        NorwayEmergencyTemplates.template(for: emergencyType, household: household)
    }

    private func localized(_ key: String) -> String {
        L10n.text(key, language: language)
    }
}

struct EmergencyShelterGuidanceSection: View {
    let emergencyType: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "building.2.crop.circle")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(localizedGuidance)

            Text(safetyNotice)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(12)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Where to shelter or go",
            norwegian: "Hvor du kan søke ly eller dra",
            thai: "สถานที่หลบภัยหรือไป"
        )
    }

    private var safetyNotice: String {
        guard let guidance = template.shelterGuidance.first else { return "" }
        return L10n.text(guidance.safetyNoticeKey, language: language)
    }

    private var localizedGuidance: String {
        guard let guidance = template.shelterGuidance.first else { return "" }
        return L10n.text(guidance.detailKey, language: language)
    }

    private var template: EmergencyPlanTemplate {
        NorwayEmergencyTemplates.template(for: emergencyType)
    }
}

struct PlanNextStepsSection: View {
    let language: AppLanguage
    let openSupplies: () -> Void
    let openContacts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Button(action: openSupplies) {
                Label(suppliesTitle, systemImage: "shippingbox.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            Button(action: openContacts) {
                Label(contactsTitle, systemImage: "person.2.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            Label(savedTitle, systemImage: "checkmark.icloud.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "Complete your plan", norwegian: "Fullfør planen", thai: "จัดทำแผนให้เสร็จ")
    }

    private var suppliesTitle: String {
        L10n.pick(language: language, english: "Review supplies", norwegian: "Se gjennom utstyr", thai: "ตรวจสอบอุปกรณ์")
    }

    private var contactsTitle: String {
        L10n.pick(language: language, english: "Review contacts", norwegian: "Se gjennom kontakter", thai: "ตรวจสอบรายชื่อติดต่อ")
    }

    private var savedTitle: String {
        L10n.pick(
            language: language,
            english: "Changes are saved automatically on this device.",
            norwegian: "Endringer lagres automatisk på denne enheten.",
            thai: "การเปลี่ยนแปลงจะบันทึกโดยอัตโนมัติในอุปกรณ์นี้"
        )
    }
}

extension EmergencyType {
    func localizedName(in language: AppLanguage) -> String {
        let template = NorwayEmergencyTemplates.template(for: self)
        return L10n.text(template.titleKey, language: language)
    }

    func localizedSummary(in language: AppLanguage) -> String {
        let template = NorwayEmergencyTemplates.template(for: self)
        return L10n.text(template.summaryKey, language: language)
    }

    func preparationGuidance(in language: AppLanguage) -> String {
        let template = NorwayEmergencyTemplates.template(for: self)
        let action = template.actions.first { $0.id.hasSuffix("prepareHousehold") }
        return action.map { L10n.text($0.detailKey, language: language) } ?? ""
    }

    func shelterGuidance(in language: AppLanguage) -> String {
        let template = NorwayEmergencyTemplates.template(for: self)
        return template.shelterGuidance.first.map {
            L10n.text($0.detailKey, language: language)
        } ?? ""
    }
}
