import SwiftUI

struct OfficialEmergencyContactsSection: View {
    let countryCode: String
    let language: AppLanguage

    private var numbers: [OfficialEmergencyNumber] {
        CountryEmergencyConfigurationCatalog.numbers(for: countryCode)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(EmergencyContactsLocalizationResources.text("official_contacts.title", language: language))
                    .font(.headline)
                    .accessibilityHeading(.h3)
                Text(EmergencyContactsLocalizationResources.text("official_contacts.subtitle", language: language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if numbers.isEmpty {
                Label(
                    EmergencyContactsLocalizationResources.text("official_contacts.unsupported", language: language),
                    systemImage: "globe"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("officialContactsUnsupportedState")
            } else {
                OfficialNumberGroup(
                    title: EmergencyContactsLocalizationResources.text("official_contacts.emergency_heading", language: language),
                    numbers: numbers.filter { $0.classification == .emergency },
                    language: language
                )
                OfficialNumberGroup(
                    title: EmergencyContactsLocalizationResources.text("official_contacts.other_heading", language: language),
                    numbers: numbers.filter { $0.classification == .nonEmergencyMedicalAdvice },
                    language: language
                )
            }
        }
        .padding(14)
        .background(InsetCardBackground())
        .accessibilityIdentifier("officialEmergencyContactsSection")
    }
}

private struct OfficialNumberGroup: View {
    let title: String
    let numbers: [OfficialEmergencyNumber]
    let language: AppLanguage

    var body: some View {
        if !numbers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityHeading(.h4)
                ForEach(numbers) { number in
                    OfficialEmergencyNumberRow(number: number, language: language)
                }
            }
        }
    }
}

struct OfficialEmergencyNumberRow: View {
    @Environment(\.openURL) private var openURL
    @State private var confirmsCall = false

    let number: OfficialEmergencyNumber
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    identity
                    Spacer(minLength: 8)
                    callButton
                }
                VStack(alignment: .leading, spacing: 10) {
                    identity
                    callButton
                }
            }

            if let source = GuidanceSourceRegistry.source(for: number.sourceID) {
                Link(destination: source.url) {
                    Label(EmergencyContactsLocalizationResources.text("official_contacts.source", language: language), systemImage: "arrow.up.right.square")
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .confirmationDialog(
            EmergencyContactsLocalizationResources.format("official_contacts.confirm_title", language: language, number.number),
            isPresented: $confirmsCall,
            titleVisibility: .visible
        ) {
            Button(EmergencyContactsLocalizationResources.text("official_contacts.confirm_call", language: language)) {
                guard let url = EmergencyCallHandoff.url(for: number) else { return }
                openURL(url)
            }
            Button(EmergencyContactsLocalizationResources.text("official_contacts.cancel", language: language), role: .cancel) {}
        } message: {
            Text(EmergencyContactsLocalizationResources.text("official_contacts.confirm_message", language: language))
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(EmergencyContactsLocalizationResources.text(number.titleKey, language: language))
                .font(.headline)
            Text(number.number)
                .font(.title2.monospacedDigit().weight(.bold))
            Text(EmergencyContactsLocalizationResources.text(number.descriptionKey, language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var callButton: some View {
        Button {
            confirmsCall = true
        } label: {
            Label(
                EmergencyContactsLocalizationResources.format("official_contacts.call", language: language, number.number),
                systemImage: "phone.fill"
            )
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityLabel(
            EmergencyContactsLocalizationResources.format(
                "official_contacts.accessibility_call",
                language: language,
                EmergencyContactsLocalizationResources.text(number.titleKey, language: language),
                number.number
            )
        )
        .accessibilityIdentifier("callOfficialNumber.\(number.id)")
    }
}
