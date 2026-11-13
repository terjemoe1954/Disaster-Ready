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
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: 88)
                    .accessibilityHidden(true)
            }
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
            ForEach([true, false], id: \.self) { essential in
                SupplyPrioritySection(
                    items: summary.items.filter { $0.isEssential == essential },
                    essential: essential,
                    selectedIDs: $selectedShoppingItemIDs,
                    language: language
                )
            }
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

private struct ShoppingSelectionRow: View {
    let item: SupplyCoverageItem
    @Binding var isSelected: Bool
    let language: AppLanguage

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.green : Color.primary)
                    .frame(width: 26)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.recommendation.localizedName(in: language))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Text(missingDetail)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    Text(selectionActionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primary)
                }

                Spacer(minLength: 8)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.recommendation.localizedName(in: language))
        .accessibilityValue(selectionActionTitle)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("shoppingSelection.\(item.id)")
    }

    private var missingDetail: String { L10n.pick(language: language, english: "Missing \(item.missingCount) checklist item", norwegian: "Mangler \(item.missingCount) sjekklistepunkt", thai: "ขาด \(item.missingCount) รายการ") }

    private var selectionActionTitle: String {
        if isSelected {
            return L10n.pick(language: language, english: "Added to shopping list", norwegian: "Lagt til i handlelisten", thai: "เพิ่มในรายการซื้อแล้ว")
        }
        return L10n.pick(language: language, english: "Add to shopping list", norwegian: "Legg til i handlelisten", thai: "เพิ่มในรายการซื้อ")
    }
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

private struct SupplyPrioritySection: View {
    let items: [SupplyCoverageItem]
    let essential: Bool
    @Binding var selectedIDs: Set<String>
    let language: AppLanguage

    private var tint: Color { essential ? .orange : .blue }
    private var title: String {
        essential
            ? L10n.pick(language: language, english: "MUST HAVE · Prioritize first", norwegian: "MÅ HA · Prioriter først", thai: "ต้องมี · จัดหาก่อน")
            : L10n.pick(language: language, english: "SHOULD HAVE · Build gradually", norwegian: "BØR HA · Bygg videre", thai: "ควรมี · ค่อย ๆ เพิ่ม")
    }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: essential ? "exclamationmark.shield.fill" : "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(tint)
                Text(L10n.pick(language: language,
                    english: "Recorded \(items.filter(\.isRecorded).count) of \(items.count) checklist items",
                    norwegian: "Registrert \(items.filter(\.isRecorded).count) av \(items.count) sjekklistepunkter",
                    thai: "บันทึกแล้ว \(items.filter(\.isRecorded).count) จาก \(items.count) รายการ"))
                    .font(.subheadline)
                ProgressView(value: Double(items.filter(\.isRecorded).count), total: Double(items.count))
                    .tint(tint)
                Text(L10n.pick(language: language,
                    english: "Priorities adapt to your household and selected event. Check quantities and expiry dates in your inventory.",
                    norwegian: "Prioriteringen tilpasses husstanden og valgt hendelse. Kontroller mengder og holdbarhet i utstyrslisten.",
                    thai: "ลำดับความสำคัญปรับตามครัวเรือนและเหตุการณ์ ตรวจสอบปริมาณและวันหมดอายุในรายการอุปกรณ์"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(items) { item in
                    if item.isRecorded {
                        Label(item.recommendation.localizedName(in: language), systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        ShoppingSelectionRow(item: item, isSelected: Binding(
                            get: { selectedIDs.contains(item.id) },
                            set: { if $0 { selectedIDs.insert(item.id) } else { selectedIDs.remove(item.id) } }
                        ), language: language)
                    }
                }
            }
            .padding(14)
            .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
