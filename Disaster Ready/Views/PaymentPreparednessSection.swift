import SwiftUI

struct PaymentPreparednessSection: View {
    @Binding var checklist: PaymentPreparednessChecklist
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Text(L10n.text("payment.introduction", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(PaymentPreparednessCatalog.checklist(for: checklist.countryCode)) { item in
                PaymentPreparednessRow(
                    item: item,
                    isComplete: completionBinding(for: item),
                    language: language
                )
            }

            Label(L10n.text("payment.privacy_notice", language: language), systemImage: "lock.shield.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .accessibilityElement(children: .combine)
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("paymentPreparednessSection")
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Label(L10n.text("payment.title", language: language), systemImage: "creditcard.and.123")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Spacer()

            Text(progressText)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.14), in: Capsule())
                .accessibilityLabel(progressText)
                .accessibilityIdentifier("paymentPreparednessProgress")
        }
    }

    private var progressText: String {
        L10n.format(
            "payment.progress",
            language: language,
            checklist.completedCount,
            PaymentPreparednessItem.allCases.count
        )
    }

    private func completionBinding(for item: PaymentPreparednessItem) -> Binding<Bool> {
        Binding(
            get: { checklist.isComplete(item) },
            set: { checklist.setComplete($0, for: item) }
        )
    }
}

struct PaymentPreparednessStatusCard: View {
    let checklist: PaymentPreparednessChecklist
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10n.text("payment.myplan.title", language: language), systemImage: "creditcard.fill")
                .font(.headline)
            Text(L10n.format(
                "payment.progress",
                language: language,
                checklist.completedCount,
                PaymentPreparednessItem.allCases.count
            ))
                .font(.subheadline.weight(.semibold))
            Text(L10n.text("payment.myplan.detail", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("myPlanPaymentPreparednessStatus")
    }
}

private struct PaymentPreparednessRow: View {
    let item: PaymentPreparednessItem
    @Binding var isComplete: Bool
    let language: AppLanguage

    var body: some View {
        Toggle(isOn: $isComplete) {
            Text(L10n.text(item.titleKey, language: language))
                .font(.subheadline.weight(.semibold))
        }
        .tint(.orange)
        .controlSize(.large)
        .padding(14)
        .background(InsetCardBackground())
        .accessibilityLabel(L10n.text(item.titleKey, language: language))
        .accessibilityValue(L10n.text(isComplete ? "payment.complete" : "payment.incomplete", language: language))
        .accessibilityIdentifier("paymentPreparedness.\(item.id)")
    }
}
