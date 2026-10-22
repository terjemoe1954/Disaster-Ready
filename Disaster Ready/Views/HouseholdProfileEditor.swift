import SwiftUI

struct HouseholdProfileEditor: View {
    @Binding var profile: HouseholdProfile
    let language: AppLanguage

    var body: some View {
        Form {
            HouseholdProfileLocationSection(
                countryCode: $profile.countryCode,
                municipality: municipalityBinding,
                householdSize: $profile.householdSize,
                language: language
            )
            HouseholdProfileMembersSection(
                hasChildren: $profile.hasChildren,
                hasPets: $profile.hasPets,
                hasSpecialAssistanceNeeds: $profile.hasSpecialAssistanceNeeds,
                language: language
            )
            HouseholdProfileHomeSection(
                hasElectricHeating: $profile.hasElectricHeating,
                hasWoodStove: $profile.hasWoodStove,
                hasGasInstallation: $profile.hasGasInstallation,
                hasAlternativeHeating: $profile.hasAlternativeHeating,
                knowsWaterStopcock: $profile.knowsWaterStopcock,
                knowsMainElectricalPanel: $profile.knowsMainElectricalPanel,
                language: language
            )
            HouseholdProfileTransportSection(
                hasCar: $profile.hasCar,
                hasEV: $profile.hasEV,
                language: language
            )
            HouseholdProfileOfflinePlanSection(
                preparednessBuddy: optionalBinding(for: \HouseholdProfile.preparednessBuddy),
                municipalInformationPoint: optionalBinding(for: \HouseholdProfile.municipalInformationPoint),
                offlineDirections: optionalBinding(for: \HouseholdProfile.offlineDirections),
                individualNeedsNote: optionalBinding(for: \HouseholdProfile.individualNeedsNote),
                language: language
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var municipalityBinding: Binding<String> {
        Binding(
            get: { profile.municipality ?? "" },
            set: { newValue in
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                profile.municipality = trimmedValue.isEmpty ? nil : newValue
            }
        )
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Household Profile",
            norwegian: "Husholdningsprofil",
            thai: "โปรไฟล์ครัวเรือน"
        )
    }

    private func optionalBinding(for keyPath: WritableKeyPath<HouseholdProfile, String?>) -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath] ?? "" },
            set: { value in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                profile[keyPath: keyPath] = trimmed.isEmpty ? nil : value
            }
        )
    }
}

private struct HouseholdProfileOfflinePlanSection: View {
    @Binding var preparednessBuddy: String
    @Binding var municipalInformationPoint: String
    @Binding var offlineDirections: String
    @Binding var individualNeedsNote: String
    let language: AppLanguage

    var body: some View {
        Section {
            TextField(buddyTitle, text: $preparednessBuddy, axis: .vertical)
            TextField(informationPointTitle, text: $municipalInformationPoint, axis: .vertical)
            TextField(directionsTitle, text: $offlineDirections, axis: .vertical)
            TextField(needsTitle, text: $individualNeedsNote, axis: .vertical)
        } header: {
            Text(title)
        } footer: {
            Text(footer)
        }
    }

    private var title: String { L10n.pick(language: language, english: "Offline emergency plan", norwegian: "Nødplan uten nett", thai: "แผนฉุกเฉินแบบออฟไลน์") }
    private var buddyTitle: String { L10n.pick(language: language, english: "Preparedness buddy or contact", norwegian: "Beredskapsvenn eller kontaktperson", thai: "เพื่อนเตรียมพร้อมหรือผู้ติดต่อ") }
    private var informationPointTitle: String { L10n.pick(language: language, english: "Municipal information point", norwegian: "Kommunalt informasjonspunkt", thai: "จุดข้อมูลของเทศบาล") }
    private var directionsTitle: String { L10n.pick(language: language, english: "Short directions without maps", norwegian: "Kort veibeskrivelse uten kart", thai: "เส้นทางสั้น ๆ โดยไม่ใช้แผนที่") }
    private var needsTitle: String { L10n.pick(language: language, english: "Individual needs and power-dependent equipment", norwegian: "Individuelle behov og strømavhengige hjelpemidler", thai: "ความต้องการเฉพาะและอุปกรณ์ที่ใช้ไฟฟ้า") }
    private var footer: String { L10n.pick(language: language, english: "Stored only with your local household profile. Verify addresses and arrangements yourself; the app does not confirm staffing or availability.", norwegian: "Lagres bare i den lokale husstandsprofilen. Kontroller adresser og avtaler selv; appen bekrefter ikke bemanning eller tilgjengelighet.", thai: "จัดเก็บไว้ในโปรไฟล์ครัวเรือนในเครื่องเท่านั้น โปรดตรวจสอบที่อยู่และข้อตกลงด้วยตนเอง แอปไม่ยืนยันบุคลากรหรือการให้บริการ") }
}

private struct HouseholdProfileLocationSection: View {
    @Binding var countryCode: String
    @Binding var municipality: String
    @Binding var householdSize: Int
    let language: AppLanguage

    var body: some View {
        Section {
            TextField(countryTitle, text: $countryCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .onChange(of: countryCode) { _, newValue in
                    countryCode = String(newValue.uppercased().prefix(2))
                }
                .accessibilityIdentifier("householdCountryCode")

            TextField(municipalityTitle, text: $municipality)
                .accessibilityIdentifier("householdMunicipality")

            Stepper(value: $householdSize, in: 1...12) {
                LabeledContent(
                    householdSizeTitle,
                    value: householdSize.formatted(
                        .number.locale(AppLanguage.locale(for: language))
                    )
                )
            }
            .accessibilityIdentifier("householdSize")
        } header: {
            Text(locationTitle)
        } footer: {
            Text(locationFooter)
        }
    }

    private var locationTitle: String {
        L10n.pick(language: language, english: "Location and size", norwegian: "Sted og størrelse", thai: "ที่ตั้งและขนาด")
    }

    private var countryTitle: String {
        L10n.pick(language: language, english: "Country code", norwegian: "Landkode", thai: "รหัสประเทศ")
    }

    private var municipalityTitle: String {
        L10n.pick(language: language, english: "Municipality (optional)", norwegian: "Kommune (valgfritt)", thai: "เทศบาล (ไม่บังคับ)")
    }

    private var householdSizeTitle: String {
        L10n.pick(language: language, english: "People in household", norwegian: "Personer i husstanden", thai: "จำนวนคนในครัวเรือน")
    }

    private var locationFooter: String {
        L10n.pick(
            language: language,
            english: "The country code adapts preparedness guidance. Municipality is optional.",
            norwegian: "Landkoden tilpasser beredskapsrådene. Kommune er valgfritt.",
            thai: "รหัสประเทศใช้ปรับคำแนะนำการเตรียมพร้อม ส่วนเทศบาลเป็นข้อมูลที่ไม่บังคับ"
        )
    }
}

private struct HouseholdProfileMembersSection: View {
    @Binding var hasChildren: Bool
    @Binding var hasPets: Bool
    @Binding var hasSpecialAssistanceNeeds: Bool
    let language: AppLanguage

    var body: some View {
        Section(membersTitle) {
            Toggle(childrenTitle, isOn: $hasChildren)
            Toggle(petsTitle, isOn: $hasPets)
            Toggle(assistanceTitle, isOn: $hasSpecialAssistanceNeeds)
        }
    }

    private var membersTitle: String {
        L10n.pick(language: language, english: "Household needs", norwegian: "Behov i husstanden", thai: "ความต้องการของครัวเรือน")
    }

    private var childrenTitle: String {
        L10n.pick(language: language, english: "Children", norwegian: "Barn", thai: "มีเด็ก")
    }

    private var petsTitle: String {
        L10n.pick(language: language, english: "Pets", norwegian: "Kjæledyr", thai: "มีสัตว์เลี้ยง")
    }

    private var assistanceTitle: String {
        L10n.pick(
            language: language,
            english: "Special assistance needs",
            norwegian: "Behov for særskilt hjelp",
            thai: "ต้องการความช่วยเหลือเป็นพิเศษ"
        )
    }
}

private struct HouseholdProfileHomeSection: View {
    @Binding var hasElectricHeating: Bool
    @Binding var hasWoodStove: Bool
    @Binding var hasGasInstallation: Bool
    @Binding var hasAlternativeHeating: Bool
    @Binding var knowsWaterStopcock: Bool
    @Binding var knowsMainElectricalPanel: Bool
    let language: AppLanguage

    var body: some View {
        Section {
            Toggle(electricHeatingTitle, isOn: $hasElectricHeating)
            Toggle(woodStoveTitle, isOn: $hasWoodStove)
            Toggle(gasInstallationTitle, isOn: $hasGasInstallation)
                .accessibilityIdentifier("hasGasInstallation")
            Toggle(alternativeHeatingTitle, isOn: $hasAlternativeHeating)
            Toggle(waterStopcockTitle, isOn: $knowsWaterStopcock)
            Toggle(electricalPanelTitle, isOn: $knowsMainElectricalPanel)
        } header: {
            Text(homeTitle)
        } footer: {
            Text(gasFooter)
        }
    }

    private var homeTitle: String {
        L10n.pick(language: language, english: "Home and heating", norwegian: "Bolig og oppvarming", thai: "บ้านและระบบทำความร้อน")
    }

    private var electricHeatingTitle: String {
        L10n.pick(language: language, english: "Electric heating", norwegian: "Elektrisk oppvarming", thai: "เครื่องทำความร้อนไฟฟ้า")
    }

    private var woodStoveTitle: String {
        L10n.pick(language: language, english: "Wood stove", norwegian: "Vedovn", thai: "เตาฟืน")
    }

    private var gasInstallationTitle: String {
        L10n.pick(language: language, english: "Gas installation", norwegian: "Gassinstallasjon", thai: "ระบบก๊าซ")
    }

    private var alternativeHeatingTitle: String {
        L10n.pick(language: language, english: "Other alternative heating", norwegian: "Annen alternativ oppvarming", thai: "เครื่องทำความร้อนทางเลือกอื่น")
    }

    private var waterStopcockTitle: String {
        L10n.pick(
            language: language,
            english: "Know the main water stopcock location",
            norwegian: "Kjenner plasseringen av hovedstoppekranen",
            thai: "ทราบตำแหน่งวาล์วปิดน้ำหลัก"
        )
    }

    private var electricalPanelTitle: String {
        L10n.pick(
            language: language,
            english: "Know the main electrical panel location",
            norwegian: "Kjenner plasseringen av hovedsikringsskapet",
            thai: "ทราบตำแหน่งตู้ไฟฟ้าหลัก"
        )
    }

    private var gasFooter: String {
        L10n.pick(
            language: language,
            english: "Enable gas only if the home actually has a gas installation.",
            norwegian: "Aktiver gass bare hvis boligen faktisk har en gassinstallasjon.",
            thai: "เปิดใช้ก๊าซเฉพาะเมื่อบ้านมีระบบก๊าซจริง"
        )
    }
}

private struct HouseholdProfileTransportSection: View {
    @Binding var hasCar: Bool
    @Binding var hasEV: Bool
    let language: AppLanguage

    var body: some View {
        Section(transportTitle) {
            Toggle(carTitle, isOn: $hasCar)
            Toggle(evTitle, isOn: $hasEV)
                .disabled(!hasCar)
        }
        .onChange(of: hasCar) { _, newValue in
            if !newValue {
                hasEV = false
            }
        }
    }

    private var transportTitle: String {
        L10n.pick(language: language, english: "Transport", norwegian: "Transport", thai: "การเดินทาง")
    }

    private var carTitle: String {
        L10n.pick(language: language, english: "Car", norwegian: "Bil", thai: "มีรถยนต์")
    }

    private var evTitle: String {
        L10n.pick(language: language, english: "Electric vehicle", norwegian: "Elbil", thai: "รถยนต์ไฟฟ้า")
    }
}
