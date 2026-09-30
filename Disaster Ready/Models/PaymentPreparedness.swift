import Foundation

enum PaymentPreparednessItem: String, CaseIterable, Identifiable {
    case cashAvailable
    case smallerDenominations
    case multipleCards
    case physicalCard
    case multiplePaymentOptions

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .cashAvailable:
            return L10n.pick(
                language: language,
                english: "Keep some cash available",
                norwegian: "Ha noen kontanter tilgjengelig",
                thai: "เตรียมเงินสดไว้บางส่วน"
            )
        case .smallerDenominations:
            return L10n.pick(
                language: language,
                english: "Include useful smaller denominations",
                norwegian: "Ha nyttige mindre valører",
                thai: "เตรียมธนบัตรมูลค่าน้อยที่ใช้สะดวก"
            )
        case .multipleCards:
            return L10n.pick(
                language: language,
                english: "Have more than one payment card where practical",
                norwegian: "Ha mer enn ett betalingskort der det er praktisk",
                thai: "มีบัตรชำระเงินมากกว่าหนึ่งใบหากทำได้"
            )
        case .physicalCard:
            return L10n.pick(
                language: language,
                english: "Keep a physical card suitable for Norwegian payment systems",
                norwegian: "Ha et fysisk kort som fungerer i norsk betalingsinfrastruktur",
                thai: "เก็บบัตรจริงที่ใช้กับระบบชำระเงินของนอร์เวย์ได้"
            )
        case .multiplePaymentOptions:
            return L10n.pick(
                language: language,
                english: "Consider more than one payment option or bank",
                norwegian: "Vurder mer enn én betalingsmåte eller bank",
                thai: "พิจารณาวิธีชำระเงินหรือธนาคารมากกว่าหนึ่งทาง"
            )
        }
    }
}
