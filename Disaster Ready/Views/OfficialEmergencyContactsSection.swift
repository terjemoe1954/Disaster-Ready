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
                    .foregroundStyle(Color.primary)
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
            if countryCode.uppercased() == "NO" {
                NorwegianVolunteerContacts(language: language)
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
                Button {
                    openURL(source.url)
                } label: {
                    Label(EmergencyContactsLocalizationResources.text("official_contacts.source", language: language), systemImage: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(Color.primary)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
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
                .foregroundStyle(Color.primary)
            Text(number.number)
                .font(.title2.monospacedDigit().weight(.bold))
                .foregroundStyle(Color.primary)
            Text(EmergencyContactsLocalizationResources.text(number.descriptionKey, language: language))
                .font(.footnote)
                .foregroundStyle(Color.primary)
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
        .tint(.black)
        .foregroundStyle(.white)
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

private struct NorwegianVolunteerContacts: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            Label(L10n.pick(language: language, english: "Volunteer aid organizations", norwegian: "Frivillige hjelpeorganisasjoner", thai: "องค์กรช่วยเหลืออาสาสมัคร"), systemImage: "person.2.fill")
                .font(.headline)
            Text(L10n.pick(language: language,
                english: "Switchboards for planning and general enquiries, not emergency dispatch. In Norway, call 113 for immediate danger to life or health, or 112 for urgent police or rescue assistance. Local teams are not guaranteed to be available.",
                norwegian: "Sentralbord for planlegging og generelle spørsmål, ikke nødtelefoner. Ring 113 ved akutt fare for liv og helse, eller 112 ved akutt behov for politi eller redningshjelp. Lokallag har ikke garantert tilgjengelighet.",
                thai: "หมายเลขสำนักงานสำหรับการวางแผนและสอบถามทั่วไป ไม่ใช่หมายเลขฉุกเฉิน ในนอร์เวย์ โทร 113 เมื่อมีอันตรายเร่งด่วนต่อชีวิตหรือสุขภาพ หรือ 112 สำหรับตำรวจหรือการกู้ภัยฉุกเฉิน ทีมท้องถิ่นอาจไม่พร้อมให้บริการเสมอ"))
                .font(.footnote)
            contact(name: "Røde Kors", phone: "22 05 40 00", dial: "+4722054000", url: "https://www.rodekors.no/kontakt/")
            contact(name: "Norsk Folkehjelp", phone: "22 03 77 00", dial: "+4722037700", url: "https://folkehjelp.no/kontakt-oss")
            Text(L10n.pick(language: language, english: "Save your local team's contact in your own contacts. Numbers verified 13 November 2026.", norwegian: "Lagre kontakt til ditt lokallag blant egne kontakter. Numrene er kontrollert 13. november 2026.", thai: "บันทึกข้อมูลติดต่อทีมท้องถิ่นในรายชื่อติดต่อของคุณ ตรวจสอบหมายเลขเมื่อ 13 พฤศจิกายน 2026"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("norwegianVolunteerContacts")
    }

    private func contact(name: String, phone: String, dial: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.subheadline.bold())
            Link(destination: URL(string: "tel:\(dial)")!) {
                Label(phone, systemImage: "phone.fill")
                    .frame(minHeight: 44)
            }
            Link(L10n.pick(language: language, english: "Contact information and local teams", norwegian: "Kontaktinformasjon og lokallag", thai: "ข้อมูลติดต่อและทีมท้องถิ่น"), destination: URL(string: url)!)
                .font(.subheadline)
        }
    }
}
