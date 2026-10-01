import Foundation

enum PaymentPreparednessStore {
    static let storageKey = "paymentPreparedness.checklist.v1"

    private static let legacyKeys: [(PaymentPreparednessItem, String)] = [
        (.cashAvailable, "paymentPreparedness.cashAvailable"),
        (.smallerDenominations, "paymentPreparedness.smallerDenominations"),
        (.multipleCards, "paymentPreparedness.multipleCards"),
        (.physicalCard, "paymentPreparedness.physicalCard"),
        (.multiplePaymentOptions, "paymentPreparedness.multiplePaymentOptions")
    ]

    static func load(
        countryCode: String,
        defaults: UserDefaults = .standard
    ) -> PaymentPreparednessChecklist {
        if let data = defaults.data(forKey: storageKey),
           let checklist = try? JSONDecoder().decode(PaymentPreparednessChecklist.self, from: data) {
            return checklist
        }

        var checklist = PaymentPreparednessChecklist(countryCode: countryCode)
        for (item, key) in legacyKeys where defaults.bool(forKey: key) {
            checklist.setComplete(true, for: item)
        }
        save(checklist, defaults: defaults)
        return checklist
    }

    static func save(
        _ checklist: PaymentPreparednessChecklist,
        defaults: UserDefaults = .standard
    ) {
        guard let data = try? JSONEncoder().encode(checklist) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
