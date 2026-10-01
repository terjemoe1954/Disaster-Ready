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
                detail: countText(homeCount),
                systemImage: "house.fill",
                action: addHome
            )

            RecommendationActionRow(
                title: evacuationTitle,
                detail: countText(evacuationCount),
                systemImage: "backpack.fill",
                action: addEvacuation
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "Smart supply lists", norwegian: "Smarte utstyrslister", thai: "รายการอุปกรณ์อัจฉริยะ")
    }

    private var subtitle: String {
        L10n.pick(
            language: language,
            english: "Recommendations combine the base list with the selected emergency and household profile.",
            norwegian: "Anbefalingene kombinerer basislisten med valgt hendelse og husholdningsprofil.",
            thai: "คำแนะนำรวมรายการพื้นฐานเข้ากับเหตุฉุกเฉินที่เลือกและโปรไฟล์ครัวเรือน"
        )
    }

    private var homeTitle: String {
        L10n.pick(language: language, english: "Add home preparedness", norwegian: "Legg til hjemmeberedskap", thai: "เพิ่มอุปกรณ์เตรียมพร้อมที่บ้าน")
    }

    private var evacuationTitle: String {
        L10n.pick(language: language, english: "Add grab / evacuation list", norwegian: "Legg til grip-/evakueringsliste", thai: "เพิ่มรายการหยิบฉวย/อพยพ")
    }

    private func countText(_ count: Int) -> String {
        L10n.pick(
            language: language,
            english: "\(count) recommended items",
            norwegian: "\(count) anbefalte varer",
            thai: "รายการแนะนำ \(count) รายการ"
        )
    }
}

private struct RecommendationActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.indigo)
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
                    .foregroundStyle(.indigo)
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
