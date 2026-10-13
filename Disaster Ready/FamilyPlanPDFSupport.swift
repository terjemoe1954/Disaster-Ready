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
    let roles: [HouseholdRole]
    let contacts: [FamilyContact]
    let language: AppLanguage

    @State private var includesRoles = true
    @State private var includesContacts = true
    @State private var includesFamilyPassword = false
    @State private var document = FamilyPlanPDFDocument()
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            Form {
                FamilyPlanPDFPrivacySection(language: language)

                Section(optionsTitle) {
                    Toggle(rolesTitle, isOn: $includesRoles)
                    Toggle(contactsTitle, isOn: $includesContacts)
                    Toggle(passwordTitle, isOn: $includesFamilyPassword)
                }

                Section {
                    Button(action: prepareExport) {
                        Label(exportTitle, systemImage: "doc.richtext.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
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
        let content = FamilyPlanPDFContent(
            title: title,
            scenarioTitle: scenarioTitle,
            scenario: emergencyType.localizedName(in: language),
            meetingPointTitle: meetingPointTitle,
            meetingPoint: plan.reunionPoint,
            evacuationTitle: evacuationTitle,
            evacuationDestination: plan.evacuationDestination,
            shelterTitle: shelterTitle,
            shelter: plan.shelterZone,
            rolesTitle: rolesTitle,
            roles: includesRoles ? roles.map { .init(title: $0.title, person: $0.person, task: $0.task) } : [],
            contactsTitle: contactsTitle,
            contacts: includesContacts ? contacts.map { .init(name: $0.name, role: $0.role, phoneNumber: $0.phoneNumber) } : [],
            passwordTitle: passwordTitle,
            familyPassword: includesFamilyPassword ? plan.familyPassword : nil,
            officialNumbersTitle: officialNumbersTitle,
            officialNumbers: CountryEmergencyConfigurationCatalog.numbers(for: "NO").map { number in
                "\(EmergencyContactsLocalizationResources.text(number.titleKey, language: language)): \(number.number)"
            },
            notSet: notSetTitle,
            footer: footerTitle
        )
        document = FamilyPlanPDFDocument(data: FamilyPlanPDFRenderer.render(content))
        isExporting = true
    }

    private var title: String { L10n.pick(language: language, english: "Share family plan", norwegian: "Del familieplan", thai: "แชร์แผนครอบครัว") }
    private var optionsTitle: String { L10n.pick(language: language, english: "Include in PDF", norwegian: "Ta med i PDF", thai: "รวมใน PDF") }
    private var rolesTitle: String { L10n.pick(language: language, english: "Household roles", norwegian: "Husstandsroller", thai: "บทบาทในครัวเรือน") }
    private var contactsTitle: String { L10n.pick(language: language, english: "Family contacts and phone numbers", norwegian: "Familiekontakter og telefonnumre", thai: "รายชื่อติดต่อและหมายเลขโทรศัพท์") }
    private var passwordTitle: String { L10n.pick(language: language, english: "Family password (sensitive)", norwegian: "Familiepassord (sensitivt)", thai: "รหัสผ่านครอบครัว (ข้อมูลละเอียดอ่อน)") }
    private var exportTitle: String { L10n.pick(language: language, english: "Create PDF", norwegian: "Opprett PDF", thai: "สร้าง PDF") }
    private var cancelTitle: String { L10n.pick(language: language, english: "Cancel", norwegian: "Avbryt", thai: "ยกเลิก") }
    private var scenarioTitle: String { L10n.pick(language: language, english: "Scenario", norwegian: "Scenario", thai: "สถานการณ์") }
    private var meetingPointTitle: String { L10n.pick(language: language, english: "Meeting point", norwegian: "Møtested", thai: "จุดนัดพบ") }
    private var evacuationTitle: String { L10n.pick(language: language, english: "Evacuation destination", norwegian: "Evakueringssted", thai: "จุดอพยพ") }
    private var shelterTitle: String { L10n.pick(language: language, english: "Safe place", norwegian: "Trygt oppholdssted", thai: "สถานที่ปลอดภัย") }
    private var officialNumbersTitle: String { L10n.pick(language: language, english: "Norwegian emergency numbers", norwegian: "Norske nødnumre", thai: "หมายเลขฉุกเฉินของนอร์เวย์") }
    private var notSetTitle: String { L10n.pick(language: language, english: "Not set", norwegian: "Ikke angitt", thai: "ยังไม่ได้ตั้งค่า") }
    private var footerTitle: String { L10n.pick(language: language, english: "Generated by Disaster Ready. Store the plan somewhere the household can access offline.", norwegian: "Opprettet med Disaster Ready. Oppbevar planen et sted husstanden har tilgang til uten internett.", thai: "สร้างโดย Disaster Ready ควรเก็บแผนไว้ในที่ที่ครัวเรือนเข้าถึงได้โดยไม่ใช้อินเทอร์เน็ต") }
    private var fileName: String { L10n.pick(language: language, english: "Family Emergency Plan", norwegian: "Familiens beredskapsplan", thai: "แผนฉุกเฉินครอบครัว") }
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
            english: "The PDF may contain personal information. Only share it with people you trust.",
            norwegian: "PDF-en kan inneholde personopplysninger. Del den bare med personer du stoler på.",
            thai: "PDF อาจมีข้อมูลส่วนบุคคล โปรดแชร์เฉพาะกับบุคคลที่คุณไว้วางใจ"
        )
    }
}

private struct FamilyPlanPDFContent: Sendable {
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
    let meetingPointTitle: String
    let meetingPoint: String
    let evacuationTitle: String
    let evacuationDestination: String
    let shelterTitle: String
    let shelter: String
    let rolesTitle: String
    let roles: [Role]
    let contactsTitle: String
    let contacts: [Contact]
    let passwordTitle: String
    let familyPassword: String?
    let officialNumbersTitle: String
    let officialNumbers: [String]
    let notSet: String
    let footer: String
}

private enum FamilyPlanPDFRenderer {
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
            value(content.meetingPointTitle, content.meetingPoint)
            value(content.evacuationTitle, content.evacuationDestination)
            value(content.shelterTitle, content.shelter)

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
