import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SuppliesDashboardData {
    let recommendations: [SupplyRecommendation]
    let evacuationRecommendationCount: Int
    let homeSupplies: [SupplyItem]
    let carSupplies: [SupplyItem]
    let householdSize: Int
    let countryCode: String
    let completionCount: Int
    let totalCount: Int
    let inventoryScrollRequest: Int
    let paymentScrollRequest: Int
    let language: AppLanguage
}

struct SuppliesDashboardTab: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let data: SuppliesDashboardData
    @Binding var paymentPreparedness: PaymentPreparednessChecklist
    @Binding var householdMemberCount: Int
    @Binding var showOnlyMissing: Bool
    let addHome: () -> Void
    let addEvacuation: () -> Void
    let deleteItem: (SupplyItem) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SuppliesDashboardSections(
                        recommendations: data.recommendations,
                        evacuationRecommendationCount: data.evacuationRecommendationCount,
                        homeSupplies: data.homeSupplies,
                        carSupplies: data.carSupplies,
                        householdSize: data.householdSize,
                        countryCode: data.countryCode,
                        paymentPreparedness: $paymentPreparedness,
                        householdMemberCount: $householdMemberCount,
                        completionCount: data.completionCount,
                        totalCount: data.totalCount,
                        showOnlyMissing: $showOnlyMissing,
                        language: data.language,
                        addHome: addHome,
                        addEvacuation: addEvacuation,
                        deleteItem: deleteItem
                    )
                }
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
                .padding(20)
                .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 220 : 160)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .accessibilityIdentifier("suppliesScrollView")
            .onChange(of: data.inventoryScrollRequest) {
                withAnimation { proxy.scrollTo(SuppliesScrollTarget.inventory, anchor: .top) }
            }
            .onChange(of: data.paymentScrollRequest) {
                withAnimation { proxy.scrollTo(SuppliesScrollTarget.payment, anchor: .top) }
            }
        }
    }
}

struct SuppliesDashboardSections: View {
    let recommendations: [SupplyRecommendation]
    let evacuationRecommendationCount: Int
    let homeSupplies: [SupplyItem]
    let carSupplies: [SupplyItem]
    let householdSize: Int
    let countryCode: String
    @Binding var paymentPreparedness: PaymentPreparednessChecklist
    @Binding var householdMemberCount: Int
    let completionCount: Int
    let totalCount: Int
    @Binding var showOnlyMissing: Bool
    let language: AppLanguage
    let addHome: () -> Void
    let addEvacuation: () -> Void
    let deleteItem: (SupplyItem) -> Void

    var body: some View {
        PreparednessSupplyOverviewSection(
            recommendations: recommendations,
            savedSupplies: homeSupplies,
            householdSize: householdSize,
            language: language
        )
        SmartSupplyRecommendationsSection(
            homeCount: recommendations.count,
            evacuationCount: evacuationRecommendationCount,
            language: language,
            addHome: addHome,
            addEvacuation: addEvacuation
        )
        if countryCode == "NO" {
            PaymentPreparednessSection(checklist: $paymentPreparedness, language: language)
                .id(SuppliesScrollTarget.payment)
        }
        HomePreparednessGuideSection(householdMemberCount: $householdMemberCount, language: language)
        SuppliesSection(
            homeSupplies: homeSupplies,
            carSupplies: carSupplies,
            completionCount: completionCount,
            totalCount: totalCount,
            showOnlyMissing: $showOnlyMissing,
            language: language,
            deleteItem: deleteItem
        )
        .id(SuppliesScrollTarget.inventory)
    }
}

struct PreparednessSupplyOverviewSection: View {
    @State private var selectedShoppingItemIDs = ShoppingListSelectionStore.load()
    @State private var showsAllGroups = false

    let recommendations: [SupplyRecommendation]
    let savedSupplies: [SupplyItem]
    let householdSize: Int
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PreparednessSupplyOverviewHeader(
                householdSize: householdSize,
                language: language
            )
            SupplyCoverageCounts(summary: summary, language: language)
            PriorityMissingSupplies(
                items: Array(summary.missingItems.prefix(3)),
                selectedIDs: $selectedShoppingItemIDs,
                language: language
            )
            PreparednessSupplyGroups(
                summary: summary,
                isExpanded: $showsAllGroups,
                selectedIDs: $selectedShoppingItemIDs,
                language: language
            )
            ShoppingListActions(
                selectedItems: selectedMissingItems,
                language: language
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("preparednessSupplyOverview")
        .onChange(of: selectedShoppingItemIDs) { _, selection in
            ShoppingListSelectionStore.save(selection)
        }
    }

    private var summary: SupplyCoverageSummary {
        SupplyCoverageCalculator.summary(
            recommendations: recommendations,
            savedSupplies: savedSupplies,
            language: language
        )
    }

    private var selectedMissingItems: [SupplyCoverageItem] {
        summary.missingItems.filter { selectedShoppingItemIDs.contains($0.id) }
    }
}

private struct PreparednessSupplyOverviewHeader: View {
    let householdSize: Int
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: "house.and.flag.fill")
                .font(.title3.bold())
                .accessibilityHeading(.h2)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(source)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var title: String { L10n.pick(language: language, english: "One week of preparedness", norwegian: "Én uke med egenberedskap", thai: "การเตรียมพร้อมหนึ่งสัปดาห์") }
    private var detail: String {
        if householdSize == 1 {
            return L10n.pick(language: language, english: "Overview for 1 person. Counts show checklist items, not a promise of safety.", norwegian: "Oversikt for 1 person. Tallene viser sjekklistepunkter, ikke et løfte om trygghet.", thai: "ภาพรวมสำหรับ 1 คน ตัวเลขแสดงรายการตรวจสอบ ไม่ใช่การรับรองความปลอดภัย")
        }
        return L10n.pick(language: language, english: "Overview for \(householdSize) people. Counts show checklist items, not a promise of safety.", norwegian: "Oversikt for \(householdSize) personer. Tallene viser sjekklistepunkter, ikke et løfte om trygghet.", thai: "ภาพรวมสำหรับ \(householdSize) คน ตัวเลขแสดงรายการตรวจสอบ ไม่ใช่การรับรองความปลอดภัย")
    }
    private var source: String { L10n.pick(language: language, english: "Norway · Source: DSB self-preparedness guidance", norwegian: "Norge · Kilde: DSBs råd om egenberedskap", thai: "นอร์เวย์ · แหล่งข้อมูล: คำแนะนำการเตรียมพร้อมของ DSB") }
}

private struct SupplyCoverageCounts: View {
    let summary: SupplyCoverageSummary
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 8) {
            countCard(title: recordedTitle, value: summary.recordedCount, color: .green)
            countCard(title: recommendedTitle, value: summary.recommendedCount, color: .blue)
            countCard(title: missingTitle, value: summary.missingCount, color: .orange)
        }
        .accessibilityElement(children: .contain)
    }

    private func countCard(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value, format: .number)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
    }

    private var recommendedTitle: String { L10n.pick(language: language, english: "Recommended", norwegian: "Anbefalt", thai: "แนะนำ") }
    private var recordedTitle: String { L10n.pick(language: language, english: "Recorded", norwegian: "Registrert", thai: "บันทึกแล้ว") }
    private var missingTitle: String { L10n.pick(language: language, english: "Missing", norwegian: "Mangler", thai: "ขาด") }
}

private struct PriorityMissingSupplies: View {
    let items: [SupplyCoverageItem]
    @Binding var selectedIDs: Set<String>
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            if items.isEmpty {
                Text(emptyDetail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    ShoppingSelectionRow(
                        item: item,
                        isSelected: selectionBinding(for: item.id),
                        language: language
                    )
                }
            }
        }
    }

    private func selectionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { selectedIDs.contains(id) },
            set: { selected in
                if selected { selectedIDs.insert(id) } else { selectedIDs.remove(id) }
            }
        )
    }

    private var title: String { L10n.pick(language: language, english: "Next tasks", norwegian: "Neste oppgaver", thai: "งานถัดไป") }
    private var emptyDetail: String { L10n.pick(language: language, english: "No recommended checklist items are currently missing. Review quantities and expiry dates in the full inventory below.", norwegian: "Ingen anbefalte sjekklistepunkter mangler nå. Kontroller mengder og holdbarhet i den fulle oversikten nedenfor.", thai: "ขณะนี้ไม่มีรายการแนะนำที่ขาด โปรดตรวจสอบปริมาณและวันหมดอายุในรายการเต็มด้านล่าง") }
}

private struct PreparednessSupplyGroups: View {
    let summary: SupplyCoverageSummary
    @Binding var isExpanded: Bool
    @Binding var selectedIDs: Set<String>
    let language: AppLanguage

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(PreparednessSupplyGroup.allCases) { group in
                    let items = summary.items(in: group)
                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(groupTitle(group))
                                .font(.headline)
                            Text(groupCounts(items))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(items.filter { $0.recordedCount > 0 }) { item in
                                Label(item.recommendation.localizedName(in: language), systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                                    .accessibilityLabel(recordedAccessibilityLabel(for: item))
                            }
                            ForEach(items.filter { $0.missingCount > 0 }) { item in
                                ShoppingSelectionRow(
                                    item: item,
                                    isSelected: selectionBinding(for: item.id),
                                    language: language
                                )
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
        } label: {
            Text(L10n.pick(language: language, english: "All five groups", norwegian: "Alle fem grupper", thai: "ทั้งห้ากลุ่ม"))
                .font(.headline)
        }
    }

    private func selectionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { selectedIDs.contains(id) },
            set: { selected in
                if selected { selectedIDs.insert(id) } else { selectedIDs.remove(id) }
            }
        )
    }

    private func recordedAccessibilityLabel(for item: SupplyCoverageItem) -> String {
        L10n.pick(
            language: language,
            english: "Recorded: \(item.recommendation.localizedName(in: language))",
            norwegian: "Registrert: \(item.recommendation.localizedName(in: language))",
            thai: "บันทึกแล้ว: \(item.recommendation.localizedName(in: language))"
        )
    }

    private func groupCounts(_ items: [SupplyCoverageItem]) -> String {
        let recorded = items.reduce(0) { $0 + $1.recordedCount }
        let missing = max(0, items.count - recorded)
        return L10n.pick(language: language, english: "Recommended \(items.count) · recorded \(recorded) · missing \(missing)", norwegian: "Anbefalt \(items.count) · registrert \(recorded) · mangler \(missing)", thai: "แนะนำ \(items.count) · บันทึก \(recorded) · ขาด \(missing)")
    }

    private func groupTitle(_ group: PreparednessSupplyGroup) -> String {
        switch group {
        case .water: L10n.pick(language: language, english: "Water", norwegian: "Vann", thai: "น้ำ")
        case .food: L10n.pick(language: language, english: "Food", norwegian: "Mat", thai: "อาหาร")
        case .warmthAndLight: L10n.pick(language: language, english: "Warmth and light", norwegian: "Varme og lys", thai: "ความอบอุ่นและแสงสว่าง")
        case .healthAndHygiene: L10n.pick(language: language, english: "Health and hygiene", norwegian: "Helse og hygiene", thai: "สุขภาพและสุขอนามัย")
        case .informationAndContact: L10n.pick(language: language, english: "Information and contact", norwegian: "Informasjon og kontakt", thai: "ข้อมูลและการติดต่อ")
        }
    }
}

private struct ShoppingSelectionRow: View {
    let item: SupplyCoverageItem
    @Binding var isSelected: Bool
    let language: AppLanguage

    var body: some View {
        Toggle(isOn: $isSelected) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.recommendation.localizedName(in: language))
                    .font(.subheadline.weight(.semibold))
                Text(missingDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.button)
        .accessibilityIdentifier("shoppingSelection.\(item.id)")
    }

    private var missingDetail: String { L10n.pick(language: language, english: "Missing \(item.missingCount) checklist item", norwegian: "Mangler \(item.missingCount) sjekklistepunkt", thai: "ขาด \(item.missingCount) รายการ") }
}

private struct ShoppingListActions: View {
    let selectedItems: [SupplyCoverageItem]
    let language: AppLanguage

    @State private var document = FamilyPlanPDFDocument()
    @State private var isExportingPDF = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
            ViewThatFits {
                HStack { actionButtons }
                VStack { actionButtons }
            }
        }
        .fileExporter(
            isPresented: $isExportingPDF,
            document: document,
            contentType: .pdf,
            defaultFilename: title
        ) { _ in }
    }

    @ViewBuilder private var actionButtons: some View {
        ShareLink(item: shoppingListText) {
            Label(shareTitle, systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.bordered)
        .disabled(selectedItems.isEmpty)
        Button(action: createPDF) {
            Label(pdfTitle, systemImage: "doc.richtext")
        }
        .buttonStyle(.bordered)
        .disabled(selectedItems.isEmpty)
        Button {
            ShoppingListPrinter.print(text: shoppingListText, jobName: title)
        } label: {
            Label(printTitle, systemImage: "printer.fill")
        }
        .buttonStyle(.bordered)
        .disabled(selectedItems.isEmpty)
    }

    private var shoppingListText: String {
        ([title] + selectedItems.map { "• \($0.recommendation.localizedName(in: language))" }).joined(separator: "\n")
    }

    private func createPDF() {
        let lines = selectedItems.map { "• \($0.recommendation.localizedName(in: language))" }
        document = FamilyPlanPDFDocument(
            data: SimpleTextPDFRenderer.render(title: title, lines: lines, footer: pdfFooter)
        )
        isExportingPDF = true
    }
    private var title: String { L10n.pick(language: language, english: "My shopping list", norwegian: "Min handleliste", thai: "รายการซื้อของฉัน") }
    private var detail: String { L10n.pick(language: language, english: "Only missing items you select are included. Your selections are saved on this device.", norwegian: "Bare mangler du velger tas med. Valgene lagres på denne enheten.", thai: "รวมเฉพาะรายการที่ขาดและคุณเลือก ตัวเลือกจะบันทึกในอุปกรณ์นี้") }
    private var shareTitle: String { L10n.pick(language: language, english: "Share", norwegian: "Del", thai: "แชร์") }
    private var pdfTitle: String { L10n.pick(language: language, english: "Save PDF", norwegian: "Lagre PDF", thai: "บันทึก PDF") }
    private var printTitle: String { L10n.pick(language: language, english: "Print", norwegian: "Skriv ut", thai: "พิมพ์") }
    private var pdfFooter: String { L10n.pick(language: language, english: "Created offline by Disaster Ready. This list contains only the missing items you selected.", norwegian: "Opprettet uten nett av Disaster Ready. Listen inneholder bare manglene du valgte.", thai: "สร้างแบบออฟไลน์โดย Disaster Ready รายการนี้มีเฉพาะสิ่งที่ขาดและคุณเลือก") }
}

@MainActor
private enum ShoppingListPrinter {
    static func print(text: String, jobName: String) {
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil)
        info.jobName = jobName
        info.outputType = .general
        controller.printInfo = info
        controller.printFormatter = UISimpleTextPrintFormatter(text: text)
        controller.present(animated: true)
    }
}
