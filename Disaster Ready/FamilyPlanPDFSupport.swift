import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FamilyPlanPDFDocument: FileDocument, Sendable {
    static var readableContentTypes: [UTType] { [.pdf] }

    let data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct FamilyPlanPDFExportSheet: View {
    @Environment(\.dismiss) private var dismiss

    let emergencyType: EmergencyType
    let plan: HouseholdPlan
    let household: HouseholdProfile
    let roles: [HouseholdRole]
    let contacts: [FamilyContact]
    let language: AppLanguage

    @State private var includesPersonalPlan = false
    @State private var includesRoles = false
    @State private var includesContacts = false
    @State private var includesFamilyPassword = false
    @State private var document = FamilyPlanPDFDocument()
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            Form {
                FamilyPlanPDFPrivacySection(language: language)

                Section(optionsTitle) {
                    Toggle(personalPlanTitle, isOn: $includesPersonalPlan)
                    Toggle(rolesTitle, isOn: $includesRoles)
                        .disabled(!includesPersonalPlan)
                    Toggle(contactsTitle, isOn: $includesContacts)
                        .disabled(!includesPersonalPlan)
                    if includesPersonalPlan, !plan.familyPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Toggle(passwordTitle, isOn: $includesFamilyPassword)
                    }
                }

                Section {
                    Button(action: prepareExport) {
                        Label(exportTitle, systemImage: "doc.richtext.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: printPlan) {
                        Label(printTitle, systemImage: "printer.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cancelTitle) { dismiss() }
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .pdf,
            defaultFilename: fileName
        ) { _ in }
    }

    private func prepareExport() {
        document = FamilyPlanPDFDocument(data: makePDFData())
        isExporting = true
    }

    private func printPlan() {
        FamilyPlanPDFPrinter.print(data: makePDFData(), jobName: fileName)
    }

    private func makePDFData() -> Data {
        let content = FamilyPlanPDFContent(
            title: title,
            scenarioTitle: scenarioTitle,
            scenario: emergencyType.localizedName(in: language),
            includesPersonalPlan: includesPersonalPlan,
            meetingPointTitle: meetingPointTitle,
            meetingPoint: plan.reunionPoint,
            evacuationTitle: evacuationTitle,
            evacuationDestination: plan.evacuationDestination,
            shelterTitle: shelterTitle,
            shelter: plan.shelterZone,
            offlineDetailsTitle: offlineDetailsTitle,
            offlineDetails: includesPersonalPlan && emergencyType == .powerAndCommunicationsOutage ? [
                .init(title: buddyTitle, value: household.preparednessBuddy ?? ""),
                .init(title: informationPointTitle, value: household.municipalInformationPoint ?? ""),
                .init(title: directionsTitle, value: household.offlineDirections ?? ""),
                .init(title: needsTitle, value: household.individualNeedsNote ?? "")
            ] : [],
            rolesTitle: rolesTitle,
            roles: includesPersonalPlan && includesRoles ? roles.map { .init(title: $0.title, person: $0.person, task: $0.task) } : [],
            contactsTitle: contactsTitle,
            contacts: includesPersonalPlan && includesContacts ? contacts.map { .init(name: $0.name, role: $0.role, phoneNumber: $0.phoneNumber) } : [],
            passwordTitle: passwordTitle,
            familyPassword: includesPersonalPlan && includesFamilyPassword ? plan.familyPassword : nil,
            guidanceTitle: guidanceTitle,
            guidance: NorwayEmergencyTemplates.template(for: emergencyType, household: household).actions.map {
                "\(L10n.text($0.titleKey, language: language)): \(L10n.text($0.detailKey, language: language))"
            },
            officialNumbersTitle: officialNumbersTitle,
            officialNumbers: CountryEmergencyConfigurationCatalog.numbers(for: "NO").map { number in
                "\(EmergencyContactsLocalizationResources.text(number.titleKey, language: language)): \(number.number)"
            },
            notSet: notSetTitle,
            footer: footerTitle
        )
        return FamilyPlanPDFRenderer.render(content)
    }

    private var title: String { L10n.pick(language: language, english: "Share family plan", norwegian: "Del familieplan", thai: "แชร์แผนครอบครัว") }
    private var optionsTitle: String { L10n.pick(language: language, english: "Include in PDF", norwegian: "Ta med i PDF", thai: "รวมใน PDF") }
    private var personalPlanTitle: String { L10n.pick(language: language, english: "Personal places and notes (sensitive)", norwegian: "Personlige steder og notater (sensitivt)", thai: "สถานที่และบันทึกส่วนบุคคล (ข้อมูลละเอียดอ่อน)") }
    private var rolesTitle: String { L10n.pick(language: language, english: "Household roles", norwegian: "Husstandsroller", thai: "บทบาทในครัวเรือน") }
    private var contactsTitle: String { L10n.pick(language: language, english: "Family contacts and phone numbers", norwegian: "Familiekontakter og telefonnumre", thai: "รายชื่อติดต่อและหมายเลขโทรศัพท์") }
    private var passwordTitle: String { L10n.pick(language: language, english: "Family password (sensitive)", norwegian: "Familiepassord (sensitivt)", thai: "รหัสผ่านครอบครัว (ข้อมูลละเอียดอ่อน)") }
    private var exportTitle: String { L10n.pick(language: language, english: "Create PDF", norwegian: "Opprett PDF", thai: "สร้าง PDF") }
    private var printTitle: String { L10n.pick(language: language, english: "Print plan", norwegian: "Skriv ut planen", thai: "พิมพ์แผน") }
    private var cancelTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }
    private var scenarioTitle: String { L10n.pick(language: language, english: "Scenario", norwegian: "Scenario", thai: "สถานการณ์") }
    private var meetingPointTitle: String { L10n.pick(language: language, english: "Meeting point", norwegian: "Møtested", thai: "จุดนัดพบ") }
    private var evacuationTitle: String { L10n.pick(language: language, english: "Evacuation destination", norwegian: "Evakueringssted", thai: "จุดอพยพ") }
    private var shelterTitle: String { L10n.pick(language: language, english: "Safe place", norwegian: "Trygt oppholdssted", thai: "สถานที่ปลอดภัย") }
    private var offlineDetailsTitle: String { L10n.pick(language: language, english: "Offline contact and directions card", norwegian: "Kontakt- og veivisningskort uten nett", thai: "บัตรข้อมูลติดต่อและเส้นทางออฟไลน์") }
    private var buddyTitle: String { L10n.pick(language: language, english: "Preparedness buddy", norwegian: "Beredskapsvenn", thai: "เพื่อนเตรียมพร้อม") }
    private var informationPointTitle: String { L10n.pick(language: language, english: "Municipal information point (not verified)", norwegian: "Kommunalt informasjonspunkt (ikke bekreftet)", thai: "จุดข้อมูลเทศบาล (ยังไม่ยืนยัน)") }
    private var directionsTitle: String { L10n.pick(language: language, english: "Directions without maps", norwegian: "Veibeskrivelse uten kart", thai: "เส้นทางโดยไม่ใช้แผนที่") }
    private var needsTitle: String { L10n.pick(language: language, english: "Individual needs", norwegian: "Individuelle behov", thai: "ความต้องการเฉพาะ") }
    private var officialNumbersTitle: String { L10n.pick(language: language, english: "Norwegian emergency numbers", norwegian: "Norske nødnumre", thai: "หมายเลขฉุกเฉินของนอร์เวย์") }
    private var guidanceTitle: String { L10n.pick(language: language, english: "Relevant emergency guidance", norwegian: "Relevante hendelsesråd", thai: "คำแนะนำฉุกเฉินที่เกี่ยวข้อง") }
    private var notSetTitle: String { L10n.pick(language: language, english: "Not set", norwegian: "Ikke angitt", thai: "ยังไม่ได้ตั้งค่า") }
    private var footerTitle: String { L10n.pick(language: language, english: "Generated by Disaster Ready. Store the plan somewhere the household can access offline.", norwegian: "Opprettet med Disaster Ready. Oppbevar planen et sted husstanden har tilgang til uten internett.", thai: "สร้างโดย Disaster Ready ควรเก็บแผนไว้ในที่ที่ครัวเรือนเข้าถึงได้โดยไม่ใช้อินเทอร์เน็ต") }
    private var fileName: String { L10n.pick(language: language, english: "Family Emergency Plan", norwegian: "Familiens beredskapsplan", thai: "แผนฉุกเฉินครอบครัว") }
}

@MainActor
private enum FamilyPlanPDFPrinter {
    static func print(data: Data, jobName: String) {
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil)
        info.jobName = jobName
        info.outputType = .general
        controller.printInfo = info
        controller.printingItem = data
        controller.present(animated: true)
    }
}

private struct FamilyPlanPDFPrivacySection: View {
    let language: AppLanguage

    var body: some View {
        Section {
            Label(detail, systemImage: "hand.raised.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var detail: String {
        L10n.pick(
            language: language,
            english: "Personal places, contacts and notes are excluded by default. If you include them, the PDF is not encrypted; store it securely and share it only with people you trust.",
            norwegian: "Personlige steder, kontakter og notater er utelatt som standard. Hvis du tar dem med, er PDF-en ikke kryptert; oppbevar den sikkert og del den bare med personer du stoler på.",
            thai: "สถานที่ รายชื่อติดต่อ และบันทึกส่วนบุคคลจะไม่รวมโดยค่าเริ่มต้น หากเลือกให้รวม PDF จะไม่เข้ารหัส โปรดจัดเก็บอย่างปลอดภัยและแชร์เฉพาะกับผู้ที่ไว้ใจ"
        )
    }
}

struct FamilyPlanPDFContent: Sendable {
    struct OfflineDetail: Sendable {
        let title: String
        let value: String
    }
    struct Role: Sendable {
        let title: String
        let person: String
        let task: String
    }

    struct Contact: Sendable {
        let name: String
        let role: String
        let phoneNumber: String
    }

    let title: String
    let scenarioTitle: String
    let scenario: String
    let includesPersonalPlan: Bool
    let meetingPointTitle: String
    let meetingPoint: String
    let evacuationTitle: String
    let evacuationDestination: String
    let shelterTitle: String
    let shelter: String
    let offlineDetailsTitle: String
    let offlineDetails: [OfflineDetail]
    let rolesTitle: String
    let roles: [Role]
    let contactsTitle: String
    let contacts: [Contact]
    let passwordTitle: String
    let familyPassword: String?
    let guidanceTitle: String
    let guidance: [String]
    let officialNumbersTitle: String
    let officialNumbers: [String]
    let notSet: String
    let footer: String
}

enum FamilyPlanPDFRenderer {
    static func render(_ content: FamilyPlanPDFContent) -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        return renderer.pdfData { context in
            var cursorY: CGFloat = 48

            func startPage() {
                context.beginPage()
                cursorY = 48
            }

            func ensureSpace(_ height: CGFloat) {
                if cursorY + height > pageBounds.height - 56 {
                    startPage()
                }
            }

            func draw(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 8) {
                let width = pageBounds.width - 96
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                let bounds = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                ensureSpace(ceil(bounds.height) + spacing)
                (text as NSString).draw(
                    with: CGRect(x: 48, y: cursorY, width: width, height: ceil(bounds.height)),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                cursorY += ceil(bounds.height) + spacing
            }

            func value(_ title: String, _ rawValue: String) {
                draw(title, font: .boldSystemFont(ofSize: 12), color: .secondaryLabel, spacing: 3)
                let displayValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? content.notSet : rawValue
                draw(displayValue, font: .systemFont(ofSize: 15), spacing: 12)
            }

            func section(_ title: String) {
                ensureSpace(42)
                cursorY += 8
                draw(title, font: .boldSystemFont(ofSize: 18), color: .systemBlue, spacing: 10)
            }

            startPage()
            draw(content.title, font: .boldSystemFont(ofSize: 28), spacing: 18)
            value(content.scenarioTitle, content.scenario)
            if content.includesPersonalPlan {
                value(content.meetingPointTitle, content.meetingPoint)
                value(content.evacuationTitle, content.evacuationDestination)
                value(content.shelterTitle, content.shelter)
            }

            section(content.guidanceTitle)
            for guidance in content.guidance {
                draw(guidance, font: .systemFont(ofSize: 13), spacing: 9)
            }

            if !content.offlineDetails.isEmpty {
                section(content.offlineDetailsTitle)
                for detail in content.offlineDetails {
                    value(detail.title, detail.value)
                }
            }

            if !content.roles.isEmpty {
                section(content.rolesTitle)
                for role in content.roles {
                    draw("\(role.title): \(role.person)", font: .boldSystemFont(ofSize: 14), spacing: 3)
                    draw(role.task, font: .systemFont(ofSize: 13), color: .secondaryLabel, spacing: 10)
                }
            }

            if !content.contacts.isEmpty {
                section(content.contactsTitle)
                for contact in content.contacts {
                    draw("\(contact.name) — \(contact.phoneNumber)", font: .boldSystemFont(ofSize: 14), spacing: 3)
                    if !contact.role.isEmpty {
                        draw(contact.role, font: .systemFont(ofSize: 13), color: .secondaryLabel, spacing: 8)
                    }
                }
            }

            if let password = content.familyPassword, !password.isEmpty {
                section(content.passwordTitle)
                draw(password, font: .boldSystemFont(ofSize: 16), spacing: 12)
            }

            section(content.officialNumbersTitle)
            for number in content.officialNumbers {
                draw(number, font: .boldSystemFont(ofSize: 15), spacing: 7)
            }

            cursorY += 14
            draw(content.footer, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 0)
        }
    }
}

enum SimpleTextPDFRenderer {
    static func render(title: String, lines: [String], footer: String) -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        return renderer.pdfData { context in
            var cursorY: CGFloat = 48

            func startPage() {
                context.beginPage()
                cursorY = 48
            }

            func draw(_ text: String, font: UIFont, spacing: CGFloat) {
                let width = pageBounds.width - 96
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.label]
                let size = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                if cursorY + ceil(size.height) + spacing > pageBounds.height - 56 {
                    startPage()
                }
                (text as NSString).draw(
                    with: CGRect(x: 48, y: cursorY, width: width, height: ceil(size.height)),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                cursorY += ceil(size.height) + spacing
            }

            startPage()
            draw(title, font: .boldSystemFont(ofSize: 28), spacing: 20)
            for line in lines {
                draw(line, font: .systemFont(ofSize: 15), spacing: 9)
            }
            cursorY += 12
            draw(footer, font: .systemFont(ofSize: 10), spacing: 0)
        }
    }
}
