import Foundation

enum PaymentPreparednessLocalizationResources {
    static let values: [LocalizedStringResource] = [
        LocalizedStringResource("payment.title", defaultValue: "Payment preparedness", comment: "Norwegian payment preparedness card title"),
        LocalizedStringResource("payment.introduction", defaultValue: "Prepare alternatives in case ordinary electronic payment is unavailable. No fixed cash amount is recommended here. This is preparedness guidance, not financial advice, and checklist completion does not guarantee financial security or safety.", comment: "Friendly preparedness guidance, not financial advice or a safety guarantee"),
        LocalizedStringResource("payment.privacy_notice", defaultValue: "Only checklist completion is stored. Never enter or store amounts, account or card numbers, PINs, BankID information, passwords, balances, or banking credentials.", comment: "Financial privacy notice"),
        LocalizedStringResource("payment.progress", defaultValue: "%lld of %lld completed", comment: "Payment checklist completion count"),
        LocalizedStringResource("payment.complete", defaultValue: "Completed", comment: "Accessibility value for completed task"),
        LocalizedStringResource("payment.incomplete", defaultValue: "Not completed", comment: "Accessibility value for incomplete task"),
        LocalizedStringResource("payment.item.cashAvailable", defaultValue: "I have some cash available", comment: "No amount requested"),
        LocalizedStringResource("payment.item.smallerDenominations", defaultValue: "I have cash in useful smaller denominations", comment: "No amount requested"),
        LocalizedStringResource("payment.item.multipleCards", defaultValue: "I have more than one payment card where practical", comment: "No card details requested"),
        LocalizedStringResource("payment.item.physicalCard", defaultValue: "I have a physical card suitable for Norwegian payment infrastructure", comment: "No card details requested"),
        LocalizedStringResource("payment.item.multiplePaymentOptions", defaultValue: "I have considered alternative payment options", comment: "Friendly preparedness wording"),
        LocalizedStringResource("payment.myplan.title", defaultValue: "Payment preparedness status", comment: "Compact status shown in relevant emergency plans"),
        LocalizedStringResource("payment.myplan.detail", defaultValue: "Review the full checklist under Supplies. Completion does not change your recorded supplies.", comment: "Separates checklist from SupplyItem data")
    ]
}
