//
//  ReleasePrepSections.swift
//  Disaster Ready
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showingResetConfirmation = false

    @Binding var selectedLanguage: AppLanguage
    @Binding var selectedAppearance: String
    @Binding var showOnlyMissingSupplies: Bool
    @Binding var supplyReviewRemindersEnabled: Bool
    @Binding var householdProfile: HouseholdProfile
    let sendTestReminder: () -> Void
    let showOnboarding: () -> Void
    let exportBackup: () -> Void
    let importBackup: () -> Void
    let resetLocalData: () -> Void
    let language: AppLanguage

    var body: some View {
        NavigationStack {
            Form {
                Section(settingsTitle) {
                    Picker(languageTitle, selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { languageOption in
                            Text(languageOption.displayName).tag(languageOption)
                        }
                    }
                }

                Section(appearanceTitle) {
                    Picker(appearancePickerTitle, selection: $selectedAppearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.title(in: language)).tag(appearance.rawValue)
                        }
                    }
                }

                Section(householdProfileTitle) {
                    NavigationLink {
                        HouseholdProfileEditor(
                            profile: $householdProfile,
                            language: language
                        )
                    } label: {
                        LabeledContent(
                            householdProfileEditTitle,
                            value: householdProfileSummary
                        )
                    }
                    .accessibilityIdentifier("householdProfileLink")
                }

                Section(preferencesTitle) {
                    Toggle(showMissingOnlyTitle, isOn: $showOnlyMissingSupplies)
                    Toggle(supplyReviewRemindersTitle, isOn: $supplyReviewRemindersEnabled)

                    if supplyReviewRemindersEnabled {
                        Button(action: sendTestReminder) {
                            Label(testReminderTitle, systemImage: "bell.badge.fill")
                        }
                        .accessibilityIdentifier("sendTestSupplyReminder")
                    }
                }

                Section(helpTitle) {
                    NavigationLink {
                        UserManualView(language: selectedLanguage)
                    } label: {
                        Label(userManualTitle, systemImage: "book.pages")
                    }

                    Button {
                        dismiss()
                        showOnboarding()
                    } label: {
                        Label(showOnboardingTitle, systemImage: "sparkles.rectangle.stack")
                    }
                    .accessibilityIdentifier("showOnboardingAgain")
                }

                Section(backupTitle) {
                    Button(exportBackupTitle) {
                        dismiss()
                        exportBackup()
                    }

                    Button(importBackupTitle) {
                        dismiss()
                        importBackup()
                    }

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label(resetDataTitle, systemImage: "arrow.counterclockwise")
                    }
                    .accessibilityIdentifier("resetLocalData")

                    Text(backupBody)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section(aboutTitle) {
                    LabeledContent(appTitle, value: versionText)

                    NavigationLink {
                        PrivacyDetailsView(language: language)
                    } label: {
                        Label(privacyTitle, systemImage: "hand.raised.fill")
                    }

                    Text(privacyBody)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(L10n.text("settings.safety_disclaimer", language: language))
                        .font(.subheadline.weight(.semibold))
                        .accessibilityIdentifier("safetyDisclaimer")
                }

            }
            .navigationTitle(settingsTitle)
            .alert(resetConfirmationTitle, isPresented: $showingResetConfirmation) {
                Button(resetDataTitle, role: .destructive) {
                    dismiss()
                    resetLocalData()
                }
                Button(cancelTitle, role: .cancel) {}
            } message: {
                Text(resetConfirmationMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(doneTitle) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var settingsTitle: String {
        L10n.pick(language: language, english: "Settings", norwegian: "Innstillinger", thai: "การตั้งค่า")
    }

    private var languageTitle: String {
        L10n.pick(language: language, english: "Language", norwegian: "Språk", thai: "ภาษา")
    }

    private var appearanceTitle: String {
        L10n.pick(language: language, english: "Appearance", norwegian: "Utseende", thai: "ลักษณะการแสดงผล")
    }

    private var appearancePickerTitle: String {
        L10n.pick(language: language, english: "Theme", norwegian: "Tema", thai: "ธีม")
    }

    private var householdProfileTitle: String {
        L10n.pick(
            language: language,
            english: "My household",
            norwegian: "Min husstand",
            thai: "ครัวเรือนของฉัน"
        )
    }

    private var householdProfileEditTitle: String {
        L10n.pick(
            language: language,
            english: "Edit household profile",
            norwegian: "Rediger husholdningsprofil",
            thai: "แก้ไขโปรไฟล์ครัวเรือน"
        )
    }

    private var householdProfileSummary: String {
        let count = householdProfile.householdSize
        let formattedCount = count.formatted(
            .number.locale(AppLanguage.locale(for: language))
        )

        return L10n.pick(
            language: language,
            english: "\(householdProfile.countryCode), \(formattedCount) \(count == 1 ? "person" : "people")",
            norwegian: "\(householdProfile.countryCode), \(formattedCount) \(count == 1 ? "person" : "personer")",
            thai: "\(householdProfile.countryCode), \(formattedCount) คน"
        )
    }

    private var preferencesTitle: String {
        L10n.pick(language: language, english: "Preferences", norwegian: "Valg", thai: "การตั้งค่าเพิ่มเติม")
    }

    private var showMissingOnlyTitle: String {
        L10n.pick(language: language, english: "Show only missing supplies", norwegian: "Vis bare manglende utstyr", thai: "แสดงเฉพาะเสบียงที่ขาด")
    }

    private var supplyReviewRemindersTitle: String {
        L10n.pick(
            language: language,
            english: "Remind me to review plans and supplies",
            norwegian: "Minn meg på å gjennomgå planer og utstyr",
            thai: "เตือนให้ตรวจสอบแผนและอุปกรณ์"
        )
    }

    private var testReminderTitle: String {
        L10n.pick(
            language: language,
            english: "Send test reminder",
            norwegian: "Send testpåminnelse",
            thai: "ส่งการแจ้งเตือนทดสอบ"
        )
    }

    private var helpTitle: String {
        L10n.pick(language: language, english: "Help", norwegian: "Hjelp", thai: "วิธีใช้")
    }

    private var aboutTitle: String {
        L10n.pick(language: language, english: "About", norwegian: "Om appen", thai: "เกี่ยวกับแอป")
    }

    private var appTitle: String {
        L10n.pick(language: language, english: "Disaster Ready version", norwegian: "Disaster Ready-versjon", thai: "เวอร์ชัน Disaster Ready")
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version ?? "—"
    }

    private var privacyBody: String {
        L10n.pick(
            language: language,
            english: "Your plans, contacts, roles, supplies, and exercise history stay on this device unless you choose to export a backup.",
            norwegian: "Planer, kontakter, roller, utstyr og øvelseshistorikk blir på denne enheten med mindre du velger å eksportere en sikkerhetskopi.",
            thai: "แผน รายชื่อติดต่อ บทบาท อุปกรณ์ และประวัติการฝึกของคุณจะอยู่ในอุปกรณ์นี้ เว้นแต่คุณเลือกส่งออกข้อมูลสำรอง"
        )
    }

    private var privacyTitle: String {
        L10n.pick(language: language, english: "Privacy", norwegian: "Personvern", thai: "ความเป็นส่วนตัว")
    }

    private var backupTitle: String {
        L10n.pick(language: language, english: "Local Backup", norwegian: "Lokal sikkerhetskopi", thai: "ข้อมูลสำรองในเครื่อง")
    }

    private var exportBackupTitle: String {
        L10n.pick(language: language, english: "Export backup", norwegian: "Eksporter sikkerhetskopi", thai: "ส่งออกข้อมูลสำรอง")
    }

    private var importBackupTitle: String {
        L10n.pick(language: language, english: "Import backup", norwegian: "Importer sikkerhetskopi", thai: "นำเข้าข้อมูลสำรอง")
    }

    private var resetDataTitle: String {
        L10n.pick(
            language: language,
            english: "Restore default data",
            norwegian: "Gjenopprett standarddata",
            thai: "กู้คืนข้อมูลเริ่มต้น"
        )
    }

    private var resetConfirmationTitle: String {
        L10n.pick(
            language: language,
            english: "Replace your local data?",
            norwegian: "Erstatt lokale data?",
            thai: "แทนที่ข้อมูลในเครื่องหรือไม่"
        )
    }

    private var resetConfirmationMessage: String {
        L10n.pick(
            language: language,
            english: "Household profile, payment preparedness, contacts, plans, roles, supplies, exercise history, and any active household status will be reset. Export a backup first if you may need the supported backup data later.",
            norwegian: "Husstandsprofil, betalingsberedskap, kontakter, planer, roller, utstyr, øvelseshistorikk og eventuell aktiv husstandsstatus nullstilles. Eksporter en sikkerhetskopi først hvis du kan få bruk for dataene som støttes i sikkerhetskopien.",
            thai: "โปรไฟล์ครัวเรือน ความพร้อมด้านการชำระเงิน รายชื่อติดต่อ แผน บทบาท อุปกรณ์ ประวัติการฝึก และสถานะครัวเรือนที่กำลังใช้งานจะถูกรีเซ็ต โปรดส่งออกข้อมูลสำรองก่อนหากอาจต้องใช้ข้อมูลที่รองรับในภายหลัง"
        )
    }

    private var cancelTitle: String {
        L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก")
    }

    private var backupBody: String {
        L10n.pick(
            language: language,
            english: "Export contacts, plans, roles, supplies, household profile, payment preparedness, and exercise history to a JSON file, or restore them later without internet. Active incident status is not included. The file is not encrypted, so store and share it securely.",
            norwegian: "Eksporter kontakter, planer, roller, utstyr, husstandsprofil, betalingsberedskap og øvelseshistorikk til en JSON-fil, eller gjenopprett dem senere uten internett. Aktiv hendelsesstatus tas ikke med. Filen er ikke kryptert og må oppbevares og deles sikkert.",
            thai: "ส่งออกรายชื่อติดต่อ แผน บทบาท อุปกรณ์ โปรไฟล์ครัวเรือน ความพร้อมด้านการชำระเงิน และประวัติการฝึกเป็นไฟล์ JSON หรือกู้คืนภายหลังโดยไม่ใช้อินเทอร์เน็ต โดยไม่รวมสถานะเหตุการณ์ที่กำลังดำเนินอยู่ ไฟล์นี้ไม่ได้เข้ารหัส โปรดจัดเก็บและแชร์อย่างปลอดภัย"
        )
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จ")
    }

    private var userManualTitle: String {
        L10n.pick(
            language: language,
            english: "User Manual",
            norwegian: "Brukermanual",
            thai: "คู่มือผู้ใช้"
        )
    }

    private var showOnboardingTitle: String {
        L10n.pick(
            language: language,
            english: "Show introduction again",
            norwegian: "Vis introduksjonen igjen",
            thai: "แสดงคำแนะนำอีกครั้ง"
        )
    }
}

private struct PrivacyDetailsView: View {
    let language: AppLanguage

    var body: some View {
        List {
            Section {
                Label(introduction, systemImage: "hand.raised.fill")
            }

            Section(localStorageTitle) {
                privacyRow(icon: "internaldrive.fill", text: localStorageBody)
                privacyRow(icon: "square.and.arrow.up", text: backupBody)
            }

            Section(optionalAccessTitle) {
                privacyRow(icon: "bell.fill", text: notificationsBody)
                privacyRow(icon: "safari.fill", text: externalLinksBody)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyRow(icon: String, text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(.tint)
        }
    }

    private var title: String {
        L10n.pick(language: language, english: "Privacy", norwegian: "Personvern", thai: "ความเป็นส่วนตัว")
    }

    private var introduction: String {
        L10n.pick(
            language: language,
            english: "Disaster Ready does not track you or send your personal data to us.",
            norwegian: "Disaster Ready sporer deg ikke og sender ikke personopplysningene dine til oss.",
            thai: "Disaster Ready ไม่ติดตามคุณและไม่ส่งข้อมูลส่วนบุคคลของคุณมาให้เรา"
        )
    }

    private var localStorageTitle: String {
        L10n.pick(language: language, english: "Data on this device", norwegian: "Data på denne enheten", thai: "ข้อมูลในอุปกรณ์นี้")
    }

    private var localStorageBody: String {
        L10n.pick(
            language: language,
            english: "Plans, contacts, roles, supplies, exercise history, active household status, and preferences are stored locally on this device.",
            norwegian: "Planer, kontakter, roller, utstyr, øvelseshistorikk, aktiv husstandsstatus og innstillinger lagres lokalt på denne enheten.",
            thai: "แผน รายชื่อติดต่อ บทบาท อุปกรณ์ ประวัติการฝึก สถานะครัวเรือนที่กำลังใช้งาน และการตั้งค่าจะจัดเก็บไว้ในอุปกรณ์นี้"
        )
    }

    private var backupBody: String {
        L10n.pick(
            language: language,
            english: "A JSON backup with supported local data, including exercise history, is created and shared only when you choose Export backup. Active incident status is excluded. The exported file is not encrypted; anyone with access to it may read its contents.",
            norwegian: "En JSON-sikkerhetskopi med støttede lokale data, inkludert øvelseshistorikk, opprettes og deles bare når du velger Eksporter sikkerhetskopi. Aktiv hendelsesstatus tas ikke med. Den eksporterte filen er ikke kryptert, og alle med tilgang kan lese innholdet.",
            thai: "ระบบจะสร้างและแชร์ข้อมูลสำรอง JSON ที่มีข้อมูลในเครื่องที่รองรับ รวมถึงประวัติการฝึก เมื่อคุณเลือกส่งออกข้อมูลสำรองเท่านั้น โดยไม่รวมสถานะเหตุการณ์ที่กำลังดำเนินอยู่ ไฟล์ที่ส่งออกไม่ได้เข้ารหัส ผู้ที่เข้าถึงไฟล์ได้อาจอ่านเนื้อหาได้"
        )
    }

    private var optionalAccessTitle: String {
        L10n.pick(language: language, english: "Optional access", norwegian: "Valgfri tilgang", thai: "การเข้าถึงที่เลือกได้")
    }

    private var notificationsBody: String {
        L10n.pick(
            language: language,
            english: "Plan and supply reminders use notification permission only when you enable them. Reminder content is created on this device.",
            norwegian: "Plan- og utstyrspåminnelser bruker varslingstillatelse bare når du aktiverer dem. Innholdet opprettes på denne enheten.",
            thai: "การเตือนแผนและอุปกรณ์จะใช้สิทธิ์การแจ้งเตือนเมื่อคุณเปิดใช้เท่านั้น และเนื้อหาการเตือนจะสร้างขึ้นในอุปกรณ์นี้"
        )
    }

    private var externalLinksBody: String {
        L10n.pick(
            language: language,
            english: "Source links open external websites. Those websites may apply their own privacy practices.",
            norwegian: "Kildelenker åpner eksterne nettsteder. Disse nettstedene kan ha egne personvernregler.",
            thai: "ลิงก์แหล่งข้อมูลจะเปิดเว็บไซต์ภายนอก ซึ่งอาจมีแนวทางความเป็นส่วนตัวของตนเอง"
        )
    }
}

struct UserManualView: View {
    let language: AppLanguage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(manualTitle)
                    .font(.title.weight(.bold))
                    .fontDesign(.rounded)

                Text(manualIntro)
                    .font(.body)
                    .foregroundStyle(.secondary)

                manualSection(
                    title: emergencyTitle,
                    body: emergencyBody,
                    systemImage: "exclamationmark.triangle.fill"
                )

                manualSection(
                    title: planTitle,
                    body: planBody,
                    systemImage: "house.fill"
                )

                manualSection(
                    title: contactsTitle,
                    body: contactsBody,
                    systemImage: "person.2.fill"
                )

                manualSection(
                    title: rolesTitle,
                    body: rolesBody,
                    systemImage: "person.crop.circle.badge.checkmark"
                )

                manualSection(
                    title: suppliesTitle,
                    body: suppliesBody,
                    systemImage: "checklist.checked"
                )

                manualSection(
                    title: backupTitle,
                    body: backupBody,
                    systemImage: "externaldrive.fill.badge.icloud"
                )
            }
            .padding(20)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func manualSection(title: String, body: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
    }

    private var navigationTitle: String {
        switch language {
        case .english:
            return "User Manual"
        case .norwegian:
            return "Brukermanual"
        case .thai:
            return "คู่มือผู้ใช้"
        }
    }

    private var manualTitle: String {
        switch language {
        case .english:
            return "Disaster Ready User Manual"
        case .norwegian:
            return "Brukermanual for Disaster Ready"
        case .thai:
            return "คู่มือผู้ใช้ Disaster Ready"
        }
    }

    private var manualIntro: String {
        switch language {
        case .english:
            return "Use Disaster Ready to keep your household plan, contacts, roles, and supply lists available on one device even when internet access is unreliable."
        case .norwegian:
            return "Bruk Disaster Ready til å ha husstandsplan, kontakter, roller og utstyrslister tilgjengelig på én enhet selv når internettilgangen er ustabil."
        case .thai:
            return "ใช้ Disaster Ready เพื่อเก็บแผนครัวเรือน รายชื่อติดต่อ บทบาท และรายการเสบียงไว้บนอุปกรณ์เครื่องเดียว แม้ในช่วงที่อินเทอร์เน็ตไม่เสถียร"
        }
    }

    private var emergencyTitle: String {
        L10n.pick(language: language, english: "Emergency guidance without internet", norwegian: "Hendelsesråd uten internett", thai: "คำแนะนำฉุกเฉินแบบออฟไลน์")
    }

    private var emergencyBody: String {
        L10n.pick(
            language: language,
            english: "Choose the situation yourself and start with the first action. Bundled guidance and your saved plan remain available without internet. The app does not know the live state of power, mobile networks, satellites, radio, or your location; follow current authority instructions whenever available.",
            norwegian: "Velg situasjonen selv og start med første handling. Lagrede råd og nødplanen din er tilgjengelige uten internett. Appen kjenner ikke sanntidstilstanden for strøm, mobilnett, satellitter, radio eller posisjonen din; følg alltid aktuelle råd fra myndighetene når de er tilgjengelige.",
            thai: "เลือกสถานการณ์ด้วยตนเองและเริ่มจากการดำเนินการแรก คำแนะนำที่บันทึกไว้และแผนฉุกเฉินใช้งานได้โดยไม่ต้องมีอินเทอร์เน็ต แอปไม่ทราบสถานะปัจจุบันของไฟฟ้า เครือข่ายมือถือ ดาวเทียม วิทยุ หรือตำแหน่งของคุณ โปรดปฏิบัติตามคำแนะนำล่าสุดของหน่วยงานเมื่อมีข้อมูล"
        )
    }

    private var planTitle: String {
        switch language {
        case .english:
            return "Household plan"
        case .norwegian:
            return "Husstandsplan"
        case .thai:
            return "แผนครัวเรือน"
        }
    }

    private var planBody: String {
        switch language {
        case .english:
            return "Keep meeting places, contacts, local information points, directions, and personal needs together. You can create an offline PDF; personal places, contacts, roles, and passwords are excluded until you explicitly include them."
        case .norwegian:
            return "Samle møteplasser, kontakter, lokale informasjonspunkter, veibeskrivelser og personlige behov. Du kan lage PDF uten nett; personlige steder, kontakter, roller og passord utelates til du uttrykkelig velger å ta dem med."
        case .thai:
            return "รวมจุดนัดพบ รายชื่อติดต่อ จุดข้อมูลในพื้นที่ เส้นทาง และความต้องการส่วนบุคคลไว้ด้วยกัน คุณสร้าง PDF แบบออฟไลน์ได้ โดยสถานที่ รายชื่อติดต่อ บทบาท และรหัสผ่านส่วนบุคคลจะไม่รวมจนกว่าคุณจะเลือกอย่างชัดเจน"
        }
    }

    private var contactsTitle: String {
        switch language {
        case .english:
            return "Contacts"
        case .norwegian:
            return "Kontakter"
        case .thai:
            return "รายชื่อติดต่อ"
        }
    }

    private var contactsBody: String {
        switch language {
        case .english:
            return "Add family contacts and important numbers with notes. Use the call and text shortcuts to reach people directly from the app."
        case .norwegian:
            return "Legg til familiekontakter og viktige numre med notater. Bruk snarveiene for anrop og melding for å kontakte folk direkte fra appen."
        case .thai:
            return "เพิ่มรายชื่อติดต่อครอบครัวและหมายเลขสำคัญพร้อมบันทึก แล้วใช้ปุ่มลัดโทรและส่งข้อความเพื่อติดต่อได้ทันทีจากแอป"
        }
    }

    private var rolesTitle: String {
        switch language {
        case .english:
            return "Household roles"
        case .norwegian:
            return "Husholdningsroller"
        case .thai:
            return "บทบาทในครัวเรือน"
        }
    }

    private var rolesBody: String {
        switch language {
        case .english:
            return "Assign each preparedness role to a person and define the main task. Update roles whenever responsibilities change so nobody has to guess in a crisis."
        case .norwegian:
            return "Tildel hver beredskapsrolle til en person og beskriv hovedoppgaven. Oppdater rollene når ansvaret endres, så ingen trenger å gjette i en krise."
        case .thai:
            return "กำหนดแต่ละบทบาทด้านความพร้อมให้กับบุคคลและระบุหน้าที่หลัก อัปเดตบทบาททุกครั้งที่ความรับผิดชอบเปลี่ยน เพื่อไม่ให้ใครต้องเดาเมื่อเกิดวิกฤต"
        }
    }

    private var suppliesTitle: String {
        switch language {
        case .english:
            return "Supply tracking"
        case .norwegian:
            return "Sporing av utstyr"
        case .thai:
            return "ติดตามเสบียง"
        }
    }

    private var suppliesBody: String {
        switch language {
        case .english:
            return "The one-week overview shows recorded items before missing recommendations and up to three next tasks. Select only the missing items you want in the shopping list, then share, save a PDF, or print it. Your full inventory, custom items, quantities, and review dates remain below."
        case .norwegian:
            return "Ukesoversikten viser registrerte varer før anbefalte mangler og inntil tre neste oppgaver. Velg bare manglene du vil ha i handlelisten, og del, lagre PDF eller skriv den ut. Fullt inventar, egne varer, mengder og kontrollfrister finnes fortsatt nedenfor."
        case .thai:
            return "ภาพรวมหนึ่งสัปดาห์แสดงรายการที่บันทึกไว้ก่อนสิ่งที่แนะนำแต่ยังขาด พร้อมงานถัดไปไม่เกินสามรายการ เลือกเฉพาะสิ่งที่ขาดซึ่งต้องการใส่ในรายการซื้อของ แล้วแชร์ บันทึก PDF หรือพิมพ์ได้ รายการอุปกรณ์ทั้งหมด ของที่เพิ่มเอง ปริมาณ และวันตรวจสอบยังอยู่ด้านล่าง"
        }
    }

    private var backupTitle: String {
        switch language {
        case .english:
            return "Local backup"
        case .norwegian:
            return "Lokal sikkerhetskopi"
        case .thai:
            return "ข้อมูลสำรองในเครื่อง"
        }
    }

    private var backupBody: String {
        switch language {
        case .english:
            return "Use Settings to export a JSON backup of your household profile, contacts, plans, roles, supplies, payment preparedness, and exercise history. Import it on the same or another device without internet. Active incident status is not included. The file is not encrypted, so store and share it securely."
        case .norwegian:
            return "Bruk Innstillinger for å eksportere en JSON-sikkerhetskopi av husstandsprofil, kontakter, planer, roller, utstyr, betalingsberedskap og øvelseshistorikk. Importer den på samme eller en annen enhet uten internett. Aktiv hendelsesstatus tas ikke med. Filen er ikke kryptert og må oppbevares og deles sikkert."
        case .thai:
            return "ใช้หน้าการตั้งค่าเพื่อส่งออกข้อมูลสำรอง JSON ของโปรไฟล์ครัวเรือน รายชื่อติดต่อ แผน บทบาท อุปกรณ์ ความพร้อมด้านการชำระเงิน และประวัติการฝึก จากนั้นนำเข้าในอุปกรณ์เดิมหรือเครื่องอื่นได้โดยไม่ใช้อินเทอร์เน็ต โดยไม่รวมสถานะเหตุการณ์ที่กำลังดำเนินอยู่ ไฟล์นี้ไม่ได้เข้ารหัส โปรดจัดเก็บและแชร์อย่างปลอดภัย"
        }
    }
}

struct OnboardingView: View {
    let language: AppLanguage
    let finish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.24, blue: 0.28),
                    Color(red: 0.30, green: 0.25, blue: 0.16),
                    Color(red: 0.84, green: 0.86, blue: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Color.black.opacity(0.60)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(onboardingTitle)
                        .font(.largeTitle.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text(onboardingSubtitle)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))

                    OnboardingSummaryCard(
                        icon: "sos.circle.fill",
                        title: helpTitle,
                        detail: helpBody,
                        tint: .red
                    )

                    OnboardingSummaryCard(
                        icon: "house.fill",
                        title: homeTitle,
                        detail: homeBody,
                        tint: .blue
                    )

                    OnboardingSummaryCard(
                        icon: "backpack.fill",
                        title: leaveTitle,
                        detail: leaveBody,
                        tint: .orange
                    )

                    Button(action: finish) {
                        Text(startTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .foregroundStyle(Color.black)
                    }
                    .accessibilityIdentifier("onboardingStartButton")
                }
                .padding(24)
            }
        }
    }

    private var onboardingTitle: String {
        L10n.pick(language: language, english: "Be ready. Act quickly.", norwegian: "Vær klar. Handle raskt.", thai: "เตรียมพร้อม ลงมืออย่างรวดเร็ว")
    }

    private var onboardingSubtitle: String {
        L10n.pick(
            language: language,
            english: "The front page gives you three clear choices. Plans and essential information remain available without internet.",
            norwegian: "Forsiden gir deg tre tydelige valg. Planer og viktig informasjon er tilgjengelig uten internett.",
            thai: "สร้างแผนครัวเรือนในเครื่อง เก็บผู้ติดต่อฉุกเฉินไว้ใกล้มือ และตัดสินใจล่วงหน้าว่าควรอยู่หรือไป"
        )
    }

    private var helpTitle: String {
        L10n.pick(language: language, english: "1. Help now", norwegian: "1. Hjelp nå", thai: "1. ความช่วยเหลือตอนนี้")
    }

    private var helpBody: String {
        L10n.pick(
            language: language,
            english: "Open the first actions, meeting place, and emergency contacts.",
            norwegian: "Åpne første handlinger, møteplass og nødkontakter.",
            thai: "แอปเก็บรายชื่อติดต่อ รายการเสบียง และแผนไว้ในอุปกรณ์ จึงยังใช้งานได้แม้ไม่มีอินเทอร์เน็ต"
        )
    }

    private var homeTitle: String {
        L10n.pick(language: language, english: "2. Prepare at home", norwegian: "2. Forbered hjemme", thai: "2. เตรียมพร้อมที่บ้าน")
    }

    private var homeBody: String {
        L10n.pick(
            language: language,
            english: "Keep the one-week reserve at home and review only what is missing.",
            norwegian: "Behold ukeslageret hjemme og se bare gjennom det som mangler.",
            thai: "บันทึกหมายเลขโทรศัพท์ กำหนดผู้รับผิดชอบ และเตรียมอัปเดต SMS ตามสถานการณ์เพื่อตรวจสอบในแอปข้อความ"
        )
    }

    private var leaveTitle: String {
        L10n.pick(language: language, english: "3. Evacuate lightly", norwegian: "3. Evakuer lett", thai: "3. อพยพอย่างคล่องตัว")
    }

    private var leaveBody: String {
        L10n.pick(
            language: language,
            english: "Take only medicines, communication, documents, and other light essentials the household can carry.",
            norwegian: "Ta bare med medisiner, kommunikasjon, dokumenter og andre lette nødvendigheter som husstanden kan bære.",
            thai: "ติดตามสิ่งของที่มีในบ้านและรถ และโฟกัสกับของที่ยังขาดได้อย่างรวดเร็ว"
        )
    }

    private var startTitle: String {
        L10n.pick(language: language, english: "Open the app", norwegian: "Åpne appen", thai: "เปิดแอป")
    }
}

private struct OnboardingSummaryCard: View {
    let icon: String
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.90))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
