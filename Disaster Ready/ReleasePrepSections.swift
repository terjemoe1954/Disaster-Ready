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
            return "Fill in reunion point, evacuation destination, shelter zone, and family password. Keep these fields short so they can be reviewed quickly during an incident."
        case .norwegian:
            return "Fyll inn møtested, evakueringsmål, tilfluktssone og familiepassord. Hold feltene korte slik at de kan gjennomgås raskt under en hendelse."
        case .thai:
            return "กรอกจุดนัดพบ จุดหมายอพยพ พื้นที่หลบภัย และรหัสผ่านครอบครัว โดยควรเขียนให้สั้นเพื่อให้ตรวจทานได้เร็วเมื่อเกิดเหตุ"
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
            return "Track items stored at home and in the car. Mark stocked items and use the missing-only filter in Settings when you need a quick restocking view."
        case .norwegian:
            return "Følg med på utstyr som er lagret hjemme og i bilen. Marker det som finnes, og bruk filteret for kun manglende utstyr i Innstillinger når du trenger en rask restockingsoversikt."
        case .thai:
            return "ติดตามสิ่งของที่เก็บไว้ที่บ้านและในรถ ทำเครื่องหมายของที่มีแล้ว และใช้ตัวกรองแสดงเฉพาะของที่ขาดในหน้าการตั้งค่าเมื่อต้องการตรวจเติมอย่างรวดเร็ว"
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

                    onboardingCard(
                        icon: "wifi.slash",
                        title: offlineTitle,
                        body: offlineBody
                    )

                    onboardingCard(
                        icon: "person.3.fill",
                        title: familyTitle,
                        body: familyBody
                    )

                    onboardingCard(
                        icon: "checklist.checked",
                        title: suppliesTitle,
                        body: suppliesBody
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

    private func onboardingCard(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var onboardingTitle: String {
        L10n.pick(language: language, english: "Prepare before the network fails.", norwegian: "Forbered deg før nettet svikter.", thai: "เตรียมพร้อมก่อนที่เครือข่ายจะล้มเหลว")
    }

    private var onboardingSubtitle: String {
        L10n.pick(
            language: language,
            english: "Build local household plans, keep emergency contacts nearby, and decide early when to stay or go.",
            norwegian: "Bygg lokale husstandsplaner, hold nødkontakter nær, og avgjør tidlig når dere skal bli eller dra.",
            thai: "สร้างแผนครัวเรือนในเครื่อง เก็บผู้ติดต่อฉุกเฉินไว้ใกล้มือ และตัดสินใจล่วงหน้าว่าควรอยู่หรือไป"
        )
    }

    private var offlineTitle: String {
        L10n.pick(language: language, english: "Offline-first", norwegian: "Offline først", thai: "ออฟไลน์เป็นหลัก")
    }

    private var offlineBody: String {
        L10n.pick(
            language: language,
            english: "The app keeps contacts, supply lists, and plans on-device so it remains useful without internet.",
            norwegian: "Appen lagrer kontakter, utstyrslister og planer på enheten slik at den fortsatt er nyttig uten internett.",
            thai: "แอปเก็บรายชื่อติดต่อ รายการเสบียง และแผนไว้ในอุปกรณ์ จึงยังใช้งานได้แม้ไม่มีอินเทอร์เน็ต"
        )
    }

    private var familyTitle: String {
        L10n.pick(language: language, english: "Family coordination", norwegian: "Familiekoordinering", thai: "การประสานงานครอบครัว")
    }

    private var familyBody: String {
        L10n.pick(
            language: language,
            english: "Save phone numbers, assign leads, and prepare scenario-specific SMS updates for review in Messages.",
            norwegian: "Lagre telefonnumre, fordel ansvar og klargjør scenario-spesifikke SMS-oppdateringer som kontrolleres i Meldinger.",
            thai: "บันทึกหมายเลขโทรศัพท์ กำหนดผู้รับผิดชอบ และเตรียมอัปเดต SMS ตามสถานการณ์เพื่อตรวจสอบในแอปข้อความ"
        )
    }

    private var suppliesTitle: String {
        L10n.pick(language: language, english: "Supply tracking", norwegian: "Sporing av utstyr", thai: "ติดตามเสบียง")
    }

    private var suppliesBody: String {
        L10n.pick(
            language: language,
            english: "Track what is stocked at home and in the car, and quickly focus on missing items.",
            norwegian: "Følg med på hva som finnes hjemme og i bilen, og fokuser raskt på det som mangler.",
            thai: "ติดตามสิ่งของที่มีในบ้านและรถ และโฟกัสกับของที่ยังขาดได้อย่างรวดเร็ว"
        )
    }

    private var startTitle: String {
        L10n.pick(language: language, english: "Start Planning", norwegian: "Start planlegging", thai: "เริ่มวางแผน")
    }
}
