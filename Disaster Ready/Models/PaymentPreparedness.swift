import Foundation

enum PaymentPreparednessItem: String, CaseIterable, Codable, Identifiable {
    case cashAvailable
    case smallerDenominations
    case multipleCards
    case physicalCard
    case multiplePaymentOptions

    var id: String { rawValue }
    var titleKey: String { "payment.item.\(rawValue)" }
}

struct PaymentPreparednessChecklist: Codable, Equatable {
    var countryCode: String
    private(set) var completedItemIDs: Set<String>

    init(countryCode: String = "NO", completedItemIDs: Set<String> = []) {
        self.countryCode = countryCode.uppercased()
        self.completedItemIDs = completedItemIDs.intersection(Set(PaymentPreparednessItem.allCases.map(\.id)))
    }

    var completedCount: Int { completedItemIDs.count }

    func isComplete(_ item: PaymentPreparednessItem) -> Bool {
        completedItemIDs.contains(item.id)
    }

    mutating func setComplete(_ isComplete: Bool, for item: PaymentPreparednessItem) {
        if isComplete {
            completedItemIDs.insert(item.id)
        } else {
            completedItemIDs.remove(item.id)
        }
    }
}

enum PaymentPreparednessCatalog {
    // Stable reference only. Authority metadata belongs to the later source-registry milestone.
    static let norwaySourceID = "no.payment-preparedness-guidance"

    static func checklist(for countryCode: String) -> [PaymentPreparednessItem] {
        countryCode.uppercased() == "NO" ? PaymentPreparednessItem.allCases : []
    }

    static func isRelevant(to emergency: EmergencyType) -> Bool {
        [.powerOutage, .evacuation, .extremeWeather, .warOrSecurityIncident].contains(emergency)
    }
}
