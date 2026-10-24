import SwiftUI

struct SmartSupplyRecommendationsSection: View {
    let homeCount: Int
    let evacuationCount: Int
    let language: AppLanguage
    let addHome: () -> Void
    let addEvacuation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            RecommendationActionRow(
                title: homeTitle,
                detail: homeDetail,
                systemImage: "house.fill",
                tint: .blue,
                action: addHome
            )

            RecommendationActionRow(
                title: evacuationTitle,
                detail: evacuationDetail,
                systemImage: "backpack.fill",
                tint: .orange,
                action: addEvacuation
            )

            Label(lightEvacuationNotice, systemImage: "figure.walk")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .combine)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "Stay home or leave?", norwegian: "Bli hjemme eller dra?", thai: "อยู่บ้านหรือออกเดินทาง")
    }

    private var subtitle: String {
        L10n.pick(
            language: language,
            english: "Keep the large reserve at home. Add only a small, carryable list for evacuation.",
            norwegian: "Behold det store lageret hjemme. Legg bare til en liten liste som kan bæres ved evakuering.",
            thai: "คำแนะนำรวมรายการพื้นฐานเข้ากับเหตุฉุกเฉินที่เลือกและโปรไฟล์ครัวเรือน"
        )
    }

    private var homeTitle: String {
        L10n.pick(language: language, english: "Stay home", norwegian: "Bli hjemme", thai: "อยู่บ้าน")
    }

    private var evacuationTitle: String {
        L10n.pick(language: language, english: "Evacuate lightly", norwegian: "Evakuer lett", thai: "อพยพอย่างคล่องตัว")
    }

    private var homeDetail: String {
        L10n.pick(
            language: language,
            english: "Add \(homeCount) suggestions and open your inventory.",
            norwegian: "Legg til \(homeCount) forslag og åpne utstyrsoversikten.",
            thai: "เพิ่มคำแนะนำ \(homeCount) รายการและเปิดรายการอุปกรณ์ของคุณ"
        )
    }

    private var evacuationDetail: String {
        L10n.pick(
            language: language,
            english: "Add \(evacuationCount) light essentials and open your inventory.",
            norwegian: "Legg til \(evacuationCount) lette nødvendigheter og åpne utstyrsoversikten.",
            thai: "เพิ่มของจำเป็นน้ำหนักเบา \(evacuationCount) รายการและเปิดรายการอุปกรณ์ของคุณ"
        )
    }

    private var lightEvacuationNotice: String {
        L10n.pick(
            language: language,
            english: "Bring only what the household can carry safely. Leave bulk water, cooking equipment, and the full home reserve behind unless authorities instruct otherwise.",
            norwegian: "Ta bare med det husstanden kan bære trygt. La store vannmengder, kokeutstyr og hele hjemmelageret bli igjen hvis ikke myndighetene sier noe annet.",
            thai: "นำไปเฉพาะสิ่งที่ทุกคนในครัวเรือนถือได้อย่างปลอดภัย ทิ้งน้ำปริมาณมาก อุปกรณ์ทำอาหาร และเสบียงทั้งหมดไว้ที่บ้าน เว้นแต่เจ้าหน้าที่จะแนะนำเป็นอย่างอื่น"
        )
    }
}

private struct RecommendationActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(tint)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(InsetCardBackground())
    }
}

extension TemplateSupplyItem {
    func localizedName(in language: AppLanguage) -> String {
        L10n.text(nameKey, language: language)
    }
}

extension SupplyRecommendation {
    func localizedName(in language: AppLanguage) -> String {
        L10n.text(nameKey, language: language)
    }
}
