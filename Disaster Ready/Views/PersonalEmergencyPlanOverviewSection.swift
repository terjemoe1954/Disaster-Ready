import SwiftUI

struct PersonalEmergencyPlanOverviewSection: View {
    let plan: HouseholdPlan
    let household: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "person.text.rectangle.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PersonalPlanValuesSection(plan: plan, household: household, language: language)
            PersonalPlanSourceSection(language: language)
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("personalEmergencyPlanOverview")
    }

    private var title: String {
        L10n.pick(language: language, english: "Your emergency plan", norwegian: "Din nødplan", thai: "แผนฉุกเฉินของคุณ")
    }

    private var detail: String {
        L10n.pick(language: language, english: "Available on this device without internet. Your entries are shown separately from bundled public guidance.", norwegian: "Tilgjengelig på denne enheten uten internett. Dine opplysninger vises separat fra lagret offentlig veiledning.", thai: "ใช้งานได้บนอุปกรณ์นี้โดยไม่ใช้อินเทอร์เน็ต ข้อมูลของคุณแยกจากคำแนะนำสาธารณะที่บันทึกไว้")
    }
}

private struct PersonalPlanValuesSection: View {
    let plan: HouseholdPlan
    let household: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlanValueRow(title: meetingTitle, value: plan.reunionPoint, language: language)
            PlanValueRow(title: evacuationTitle, value: plan.evacuationDestination, language: language)
            PlanValueRow(title: safePlaceTitle, value: plan.shelterZone, language: language)
            PlanValueRow(title: buddyTitle, value: household.preparednessBuddy, language: language)
            PlanValueRow(title: informationPointTitle, value: household.municipalInformationPoint, isUnverifiedPlace: true, language: language)
            PlanValueRow(title: directionsTitle, value: household.offlineDirections, language: language)
            PlanValueRow(title: needsTitle, value: household.individualNeedsNote, language: language)
        }
    }

    private var meetingTitle: String { L10n.pick(language: language, english: "Meeting place", norwegian: "Møteplass", thai: "จุดนัดพบ") }
    private var evacuationTitle: String { L10n.pick(language: language, english: "Evacuation destination", norwegian: "Evakueringssted", thai: "จุดอพยพ") }
    private var safePlaceTitle: String { L10n.pick(language: language, english: "Safe place", norwegian: "Trygt oppholdssted", thai: "สถานที่ปลอดภัย") }
    private var buddyTitle: String { L10n.pick(language: language, english: "Preparedness buddy", norwegian: "Beredskapsvenn", thai: "เพื่อนเตรียมพร้อม") }
    private var informationPointTitle: String { L10n.pick(language: language, english: "Municipal information point", norwegian: "Kommunalt informasjonspunkt", thai: "จุดข้อมูลเทศบาล") }
    private var directionsTitle: String { L10n.pick(language: language, english: "Directions without maps", norwegian: "Veibeskrivelse uten kart", thai: "เส้นทางโดยไม่ใช้แผนที่") }
    private var needsTitle: String { L10n.pick(language: language, english: "Personal needs", norwegian: "Personlige behov", thai: "ความต้องการส่วนบุคคล") }
}

private struct PlanValueRow: View {
    let title: String
    let value: String?
    var isUnverifiedPlace = false
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text(classification)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isUnverifiedPlace ? .orange : .blue)
            }
            Text(displayValue)
                .font(.subheadline)
                .foregroundStyle(isEmpty ? .secondary : .primary)
        }
        .padding(10)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }

    private var isEmpty: Bool { value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false }
    private var displayValue: String { isEmpty ? L10n.pick(language: language, english: "Not set", norwegian: "Ikke angitt", thai: "ยังไม่ได้ตั้งค่า") : (value ?? "") }
    private var classification: String {
        if isUnverifiedPlace {
            return L10n.pick(language: language, english: "Your note · unverified", norwegian: "Ditt notat · ubekreftet", thai: "บันทึกของคุณ · ยังไม่ยืนยัน")
        }
        return L10n.pick(language: language, english: "Your entry", norwegian: "Din opplysning", thai: "ข้อมูลของคุณ")
    }
}

private struct PersonalPlanSourceSection: View {
    let language: AppLanguage

    var body: some View {
        if let source = GuidanceSourceRegistry.source(for: "dsb-self-preparedness") {
            VStack(alignment: .leading, spacing: 4) {
                Label(publicGuidanceTitle, systemImage: "building.columns.fill")
                    .font(.caption.weight(.semibold))
                Text(source.authority)
                    .font(.caption)
                HStack(spacing: 4) {
                    Text(reviewedTitle)
                    Text(source.lastReviewed, format: .dateTime.day().month(.abbreviated).year())
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .environment(\.locale, AppLanguage.locale(for: language))
                Text(offlineTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var publicGuidanceTitle: String { L10n.pick(language: language, english: "Bundled public guidance", norwegian: "Lagret offentlig veiledning", thai: "คำแนะนำสาธารณะที่บันทึกไว้") }
    private var reviewedTitle: String { L10n.pick(language: language, english: "Checked:", norwegian: "Kontrollert:", thai: "ตรวจสอบ:") }
    private var offlineTitle: String { L10n.pick(language: language, english: "Source details are stored on this device.", norwegian: "Kildedetaljene er lagret på denne enheten.", thai: "รายละเอียดแหล่งข้อมูลบันทึกอยู่ในอุปกรณ์นี้") }
}
