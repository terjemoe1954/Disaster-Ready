import SwiftUI

struct PrimaryNavigationSection: View {
    let language: AppLanguage
    let showsWelcomeGuide: Bool
    let openHelpNow: () -> Void
    let openPreparedness: () -> Void
    let openEmergencyPlan: () -> Void
    let openWelcomeGuide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PrimaryNavigationHeader(language: language)

            PrimaryNavigationCard(
                title: L10n.pick(
                    language: language,
                    english: "Help now",
                    norwegian: "Hjelp nå",
                    thai: "ฉันต้องการความช่วยเหลือตอนนี้"
                ),
                detail: L10n.pick(
                    language: language,
                    english: "First actions, meeting place, and emergency contacts.",
                    norwegian: "Første handlinger, møteplass og nødkontakter.",
                    thai: "เปิดการดำเนินการแรก จุดนัดพบที่บันทึกไว้ และผู้ติดต่อฉุกเฉิน"
                ),
                systemImage: "sos.circle.fill",
                tint: .red,
                accessibilityIdentifier: "primaryHelpNowButton",
                action: openHelpNow
            )

            PrimaryNavigationCard(
                title: L10n.pick(
                    language: language,
                    english: "Prepare at home",
                    norwegian: "Forbered hjemme",
                    thai: "การเตรียมพร้อมของฉัน"
                ),
                detail: L10n.pick(
                    language: language,
                    english: "One-week home supplies, reminders, and practical guidance.",
                    norwegian: "Hjemmelager for én uke, påminnelser og praktiske råd.",
                    thai: "ดูสิ่งของ การเตรียมพร้อมด้านการชำระเงิน การเตือน และคำแนะนำที่ใช้ได้จริง"
                ),
                systemImage: "shippingbox.fill",
                tint: .blue,
                accessibilityIdentifier: "primaryPreparednessButton",
                action: openPreparedness
            )

            PrimaryNavigationCard(
                title: L10n.pick(
                    language: language,
                    english: "Plan to leave",
                    norwegian: "Planlegg å dra",
                    thai: "แผนฉุกเฉินของฉัน"
                ),
                detail: L10n.pick(
                    language: language,
                    english: "Meeting places, contacts, and a light evacuation list.",
                    norwegian: "Møteplasser, kontakter og en lett evakueringsliste.",
                    thai: "เปิดเหตุการณ์ จุดนัดพบ ผู้ติดต่อ หน้าที่ และแผนที่พิมพ์ได้"
                ),
                systemImage: "checklist.checked",
                tint: .indigo,
                accessibilityIdentifier: "primaryEmergencyPlanButton",
                action: openEmergencyPlan
            )

            if showsWelcomeGuide {
                WelcomeGuideCard(language: language, action: openWelcomeGuide)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct PrimaryNavigationHeader: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(
                L10n.pick(
                    language: language,
                    english: "What do you need?",
                    norwegian: "Hva trenger du?",
                    thai: "คุณต้องการอะไร"
                )
            )
            .font(.title2.bold())
            .accessibilityAddTraits(.isHeader)

            Text(
                L10n.pick(
                    language: language,
                    english: "Choose one place to start. You can change direction at any time.",
                    norwegian: "Velg ett sted å starte. Du kan bytte retning når som helst.",
                    thai: "เลือกหนึ่งจุดเพื่อเริ่มต้น คุณเปลี่ยนเส้นทางได้ตลอดเวลา"
                )
            )
            .font(.subheadline)
            .foregroundStyle(Color.primary)
        }
    }
}

private struct PrimaryNavigationCard: View {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(tint)
                    .frame(width: 36)
                    .frame(minHeight: 44)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct WelcomeGuideCard: View {
    let language: AppLanguage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        L10n.pick(
                            language: language,
                            english: "New here?",
                            norwegian: "Ny her?",
                            thai: "เพิ่งเริ่มใช้งานใช่ไหม"
                        )
                    )
                    .font(.headline)
                    Text(
                        L10n.pick(
                            language: language,
                            english: "Open the optional introduction. You can use the app first.",
                            norwegian: "Åpne den valgfrie introduksjonen. Du kan bruke appen først.",
                            thai: "เปิดคำแนะนำแบบไม่บังคับ คุณสามารถใช้แอปก่อนได้"
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "hand.wave.fill")
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(14)
            .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("optionalWelcomeGuideButton")
    }
}
