//
//  ReleasePrepSections.swift
//  Disaster Ready
//

import SwiftUI

struct ReleaseReadinessSection: View {
    let isOfflineFirst: Bool
    let supportsLocalization: Bool
    let hasOnboarding: Bool
    let hasLocalPlanStorage: Bool
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.bold))

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            readinessRow(label: offlineLabel, isReady: isOfflineFirst)
            readinessRow(label: localizationLabel, isReady: supportsLocalization)
            readinessRow(label: onboardingLabel, isReady: hasOnboarding)
            readinessRow(label: localPlanLabel, isReady: hasLocalPlanStorage)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func readinessRow(label: String, isReady: Bool) -> some View {
        HStack {
            Image(systemName: isReady ? "checkmark.seal.fill" : "clock.badge.exclamationmark.fill")
                .foregroundStyle(isReady ? .green : .orange)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(isReady ? readyText : pendingText)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((isReady ? Color.green : Color.orange).opacity(0.12), in: Capsule())
                .foregroundStyle(isReady ? .green : .orange)
        }
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "App Store Readiness",
            norwegian: "App Store-beredskap",
            thai: "ความพร้อมสำหรับ App Store"
        )
    }

    private var subtitle: String {
        L10n.pick(
            language: language,
            english: "This release is being shaped as a local-first product that can be polished for App Store launch next.",
            norwegian: "Denne utgaven formes som et lokal-først-produkt som kan finpusses for App Store-lansering som neste steg.",
            thai: "รุ่นนี้กำลังถูกออกแบบให้เป็นผลิตภัณฑ์แบบ local-first ซึ่งสามารถขัดเกลาเพื่อเปิดตัวบน App Store ได้เป็นขั้นถัดไป"
        )
    }

    private var offlineLabel: String {
        L10n.pick(
            language: language,
            english: "Offline-first storage and planning are active.",
            norwegian: "Offline-først lagring og planlegging er aktiv.",
            thai: "มีการจัดเก็บและการวางแผนแบบออฟไลน์เป็นหลัก"
        )
    }

    private var localizationLabel: String {
        L10n.pick(
            language: language,
            english: "English, Norwegian, and Thai are available.",
            norwegian: "Engelsk, norsk og thai er tilgjengelig.",
            thai: "รองรับภาษาอังกฤษ นอร์เวย์ และไทย"
        )
    }

    private var onboardingLabel: String {
        L10n.pick(
            language: language,
            english: "First-launch onboarding is in place.",
            norwegian: "Onboarding ved første oppstart er på plass.",
            thai: "มีการแนะนำการใช้งานครั้งแรกแล้ว"
        )
    }

    private var localPlanLabel: String {
        L10n.pick(
            language: language,
            english: "Household plans are stored on-device.",
            norwegian: "Husstandsplaner lagres på enheten.",
            thai: "แผนครัวเรือนถูกเก็บไว้ในอุปกรณ์"
        )
    }

    private var readyText: String {
        L10n.pick(language: language, english: "Ready", norwegian: "Klar", thai: "พร้อม")
    }

    private var pendingText: String {
        L10n.pick(language: language, english: "Pending", norwegian: "Venter", thai: "รอดำเนินการ")
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedLanguage: AppLanguage
    @Binding var includePlanSummaryInMessages: Bool
    @Binding var showOnlyMissingSupplies: Bool
    @Binding var offlineFirstMode: Bool
    let reopenOnboarding: () -> Void
    let exportBackup: () -> Void
    let importBackup: () -> Void
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

                    Toggle(includePlanSummaryTitle, isOn: $includePlanSummaryInMessages)
                    Toggle(showMissingOnlyTitle, isOn: $showOnlyMissingSupplies)
                    Toggle(offlineFirstModeTitle, isOn: $offlineFirstMode)
                }

                Section(onboardingTitle) {
                    Button(reopenOnboardingTitle) {
                        dismiss()
                        reopenOnboarding()
                    }
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

                    Text(backupBody)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section(releaseNotesTitle) {
                    Text(releaseNotesBody)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(settingsTitle)
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

    private var includePlanSummaryTitle: String {
        L10n.pick(language: language, english: "Include plan summary in family updates", norwegian: "Ta med plansammendrag i familieoppdateringer", thai: "รวมสรุปแผนในอัปเดตครอบครัว")
    }

    private var showMissingOnlyTitle: String {
        L10n.pick(language: language, english: "Show only missing supplies", norwegian: "Vis bare manglende utstyr", thai: "แสดงเฉพาะเสบียงที่ขาด")
    }

    private var offlineFirstModeTitle: String {
        L10n.pick(language: language, english: "Keep local-only offline mode as primary", norwegian: "Behold lokal offline-modus som primær", thai: "ใช้โหมดออฟไลน์แบบในเครื่องเป็นหลัก")
    }

    private var onboardingTitle: String {
        L10n.pick(language: language, english: "Onboarding", norwegian: "Onboarding", thai: "การเริ่มต้นใช้งาน")
    }

    private var reopenOnboardingTitle: String {
        L10n.pick(language: language, english: "Show onboarding again", norwegian: "Vis onboarding igjen", thai: "แสดงการแนะนำอีกครั้ง")
    }

    private var releaseNotesTitle: String {
        L10n.pick(language: language, english: "Release Notes", norwegian: "Utgivelsesnotater", thai: "บันทึกการเปิดตัว")
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

    private var backupBody: String {
        L10n.pick(
            language: language,
            english: "Export your local contacts, plans, and supplies to a JSON file, or restore them later without needing internet.",
            norwegian: "Eksporter lokale kontakter, planer og utstyr til en JSON-fil, eller gjenopprett dem senere uten behov for internett.",
            thai: "ส่งออกรายชื่อติดต่อ แผน และเสบียงในเครื่องเป็นไฟล์ JSON หรือกู้คืนภายหลังได้โดยไม่ต้องใช้อินเทอร์เน็ต"
        )
    }

    private var releaseNotesBody: String {
        L10n.pick(
            language: language,
            english: "This version is designed to work fully offline on one device. Future iCloud sharing should remain optional, not required.",
            norwegian: "Denne versjonen er laget for å fungere fullt offline på én enhet. Fremtidig iCloud-deling bør være valgfri, ikke påkrevd.",
            thai: "เวอร์ชันนี้ออกแบบให้ทำงานแบบออฟไลน์เต็มรูปแบบบนอุปกรณ์เดียว การแชร์ผ่าน iCloud ในอนาคตควรเป็นทางเลือก ไม่ใช่ข้อบังคับ"
        )
    }

    private var doneTitle: String {
        L10n.pick(language: language, english: "Done", norwegian: "Ferdig", thai: "เสร็จ")
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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(onboardingTitle)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
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
            english: "Save phone numbers, assign leads, and share scenario-specific updates in one tap.",
            norwegian: "Lagre telefonnumre, fordel ansvar og del scenario-spesifikke oppdateringer med ett trykk.",
            thai: "บันทึกหมายเลขโทรศัพท์ กำหนดผู้รับผิดชอบ และแชร์อัปเดตตามสถานการณ์ได้ในแตะเดียว"
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
