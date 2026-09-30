import SwiftUI

struct PaymentPreparednessSection: View {
    @AppStorage("paymentPreparedness.cashAvailable") private var cashAvailable = false
    @AppStorage("paymentPreparedness.smallerDenominations") private var smallerDenominations = false
    @AppStorage("paymentPreparedness.multipleCards") private var multipleCards = false
    @AppStorage("paymentPreparedness.physicalCard") private var physicalCard = false
    @AppStorage("paymentPreparedness.multiplePaymentOptions") private var multiplePaymentOptions = false

    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Label(title, systemImage: "creditcard.and.123")
                    .font(.title3.weight(.bold))
                    .accessibilityHeading(.h2)

                Spacer()

                Text("\(completedCount)/\(PaymentPreparednessItem.allCases.count)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.14), in: Capsule())
            }

            Text(introduction)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PaymentPreparednessRow(
                item: .cashAvailable,
                isComplete: $cashAvailable,
                language: language
            )
            PaymentPreparednessRow(
                item: .smallerDenominations,
                isComplete: $smallerDenominations,
                language: language
            )
            PaymentPreparednessRow(
                item: .multipleCards,
                isComplete: $multipleCards,
                language: language
            )
            PaymentPreparednessRow(
                item: .physicalCard,
                isComplete: $physicalCard,
                language: language
            )
            PaymentPreparednessRow(
                item: .multiplePaymentOptions,
                isComplete: $multiplePaymentOptions,
                language: language
            )

            Label(privacyNotice, systemImage: "lock.shield.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("paymentPreparednessSection")
    }

    private var completedCount: Int {
        [
            cashAvailable,
            smallerDenominations,
            multipleCards,
            physicalCard,
            multiplePaymentOptions
        ].filter { $0 }.count
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Payment preparedness",
            norwegian: "Betalingsberedskap",
            thai: "การเตรียมพร้อมด้านการชำระเงิน"
        )
    }

    private var introduction: String {
        L10n.pick(
            language: language,
            english: "Prepare alternatives in case ordinary electronic payment is unavailable. No fixed cash amount is recommended here.",
            norwegian: "Forbered alternativer dersom vanlig elektronisk betaling ikke er tilgjengelig. Her anbefales ikke et fast kontantbeløp.",
            thai: "เตรียมทางเลือกหากการชำระเงินอิเล็กทรอนิกส์ตามปกติใช้ไม่ได้ โดยไม่ได้แนะนำจำนวนเงินสดตายตัว"
        )
    }

    private var privacyNotice: String {
        L10n.pick(
            language: language,
            english: "This checklist never asks for or stores card numbers, PINs, BankID secrets, or banking credentials.",
            norwegian: "Sjekklisten ber aldri om eller lagrer kortnummer, PIN-koder, BankID-hemmeligheter eller bankopplysninger.",
            thai: "รายการนี้จะไม่ขอหรือจัดเก็บหมายเลขบัตร รหัส PIN ความลับ BankID หรือข้อมูลเข้าสู่ระบบธนาคาร"
        )
    }
}

private struct PaymentPreparednessRow: View {
    let item: PaymentPreparednessItem
    @Binding var isComplete: Bool
    let language: AppLanguage

    var body: some View {
        Toggle(isOn: $isComplete) {
            Text(item.title(in: language))
                .font(.subheadline.weight(.semibold))
        }
        .tint(.orange)
        .padding(14)
        .background(InsetCardBackground())
        .accessibilityIdentifier("paymentPreparedness.\(item.id)")
    }
}
