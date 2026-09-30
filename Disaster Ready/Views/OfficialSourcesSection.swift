import SwiftUI

struct OfficialSourcesSection: View {
    let sources: [GuidanceSource]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(sectionTitle, systemImage: "building.columns.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(sectionDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(sources) { source in
                OfficialSourceRow(source: source, language: language)
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("officialSourcesSection")
    }

    private var sectionTitle: String {
        L10n.pick(
            language: language,
            english: "Official information",
            norwegian: "Offisiell informasjon",
            thai: "ข้อมูลทางการ"
        )
    }

    private var sectionDescription: String {
        L10n.pick(
            language: language,
            english: "Official instructions always override the app's preparedness templates.",
            norwegian: "Offisielle instrukser gjelder alltid foran appens beredskapsmaler.",
            thai: "คำแนะนำอย่างเป็นทางการมีความสำคัญเหนือแบบเตรียมพร้อมของแอปเสมอ"
        )
    }
}

private struct OfficialSourceRow: View {
    let source: GuidanceSource
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(source.title)
                .font(.headline)

            LabeledContent(sourceLabel, value: source.authority)
                .font(.caption)

            HStack(spacing: 4) {
                Text(reviewedLabel)
                Text(source.lastReviewed, format: .dateTime.day().month().year())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .environment(\.locale, AppLanguage.locale(for: language))

            Link(destination: source.url) {
                Label(viewAdviceTitle, systemImage: "arrow.up.right.square")
                    .font(.subheadline.weight(.semibold))
            }
            .accessibilityIdentifier("officialSource.\(source.id)")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
    }

    private var sourceLabel: String {
        L10n.pick(language: language, english: "Source", norwegian: "Kilde", thai: "แหล่งข้อมูล")
    }

    private var reviewedLabel: String {
        L10n.pick(language: language, english: "Reviewed:", norwegian: "Gjennomgått:", thai: "ตรวจสอบเมื่อ:")
    }

    private var viewAdviceTitle: String {
        L10n.pick(
            language: language,
            english: "View official advice",
            norwegian: "Se offisielle råd",
            thai: "ดูคำแนะนำอย่างเป็นทางการ"
        )
    }
}
