import Foundation

enum SourceLocalizationResources {
    static let values: [LocalizedStringResource] = [
        LocalizedStringResource("source.section.title", defaultValue: "Official sources", comment: "Heading above official source attribution cards"),
        LocalizedStringResource("source.section.description", defaultValue: "Bundled preparedness guidance is checked against these official sources. Source details remain available offline.", comment: "Explains offline source metadata"),
        LocalizedStringResource("source.label", defaultValue: "Source", comment: "Label before an official authority name"),
        LocalizedStringResource("source.reviewed.label", defaultValue: "Source reviewed:", comment: "Date when Disaster Ready last reviewed its bundled guidance, not a live update"),
        LocalizedStringResource("source.view_advice", defaultValue: "View official advice", comment: "Link that opens an official website"),
        LocalizedStringResource("source.link.accessibility", defaultValue: "Open official advice from %@", comment: "VoiceOver label; placeholder is the authority name"),
        LocalizedStringResource("source.review_semantics", defaultValue: "Disaster Ready reviewed this guidance against the listed official source on the date above. This is not a live-update time. During an emergency, follow current instructions from public authorities.", comment: "Safety explanation distinguishing a source review date from live information")
    ]
}
