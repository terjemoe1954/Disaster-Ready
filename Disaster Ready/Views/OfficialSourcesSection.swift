import SwiftUI

struct OfficialSourcesSection: View {
    let sources: [GuidanceSource]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(sectionTitle, systemImage: "building.columns.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(L10n.text("source.section.description", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(sources) { source in
                SourceAttributionCard(source: source, language: language)
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("officialSourcesSection")
    }

    private var sectionTitle: String { L10n.text("source.section.title", language: language) }
}

struct SourceAttributionCard: View {
    let source: GuidanceSource
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(source.title)
                .font(.headline)

            LabeledContent(L10n.text("source.label", language: language), value: source.authority)
                .font(.caption)

            HStack(spacing: 4) {
                Text(L10n.text("source.reviewed.label", language: language))
                Text(source.lastReviewed, format: .dateTime.day().month().year())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .environment(\.locale, AppLanguage.locale(for: language))

            Link(destination: source.url) {
                Label(L10n.text("source.view_advice", language: language), systemImage: "arrow.up.right.square")
                    .font(.subheadline.weight(.semibold))
            }
            .frame(minHeight: 44)
            .accessibilityLabel(L10n.format("source.link.accessibility", language: language, source.authority))
            .accessibilityIdentifier("officialSource.\(source.id)")

            Text(L10n.text("source.review_semantics", language: language))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
    }

}

struct TemplateSourceAttributionSection: View {
    let sourceIDs: [String]
    let language: AppLanguage

    private var sources: [GuidanceSource] {
        GuidanceSourceRegistry.resolvedSources(for: sourceIDs)
    }

    var body: some View {
        if !sources.isEmpty {
            OfficialSourcesSection(sources: sources, language: language)
                .accessibilityIdentifier("templateSourceAttribution")
        }
    }
}
