import SwiftUI

struct SmartSupplyRecommendationsSection: View {
    let homeCount: Int
    let evacuationCount: Int
    let language: AppLanguage
    let addHome: () -> Void
    let addEvacuation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            RecommendationActionRow(
                title: homeTitle,
                detail: countText(homeCount),
                systemImage: "house.fill",
                action: addHome
            )

            RecommendationActionRow(
                title: evacuationTitle,
                detail: countText(evacuationCount),
                systemImage: "backpack.fill",
                action: addEvacuation
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "Smart supply lists", norwegian: "Smarte utstyrslister", thai: "รายการอุปกรณ์อัจฉริยะ")
    }

    private var subtitle: String {
        L10n.pick(
            language: language,
            english: "Recommendations combine the base list with the selected emergency and household profile.",
            norwegian: "Anbefalingene kombinerer basislisten med valgt hendelse og husholdningsprofil.",
            thai: "คำแนะนำรวมรายการพื้นฐานเข้ากับเหตุฉุกเฉินที่เลือกและโปรไฟล์ครัวเรือน"
        )
    }

    private var homeTitle: String {
        L10n.pick(language: language, english: "Add home preparedness", norwegian: "Legg til hjemmeberedskap", thai: "เพิ่มอุปกรณ์เตรียมพร้อมที่บ้าน")
    }

    private var evacuationTitle: String {
        L10n.pick(language: language, english: "Add grab / evacuation list", norwegian: "Legg til grip-/evakueringsliste", thai: "เพิ่มรายการหยิบฉวย/อพยพ")
    }

    private func countText(_ count: Int) -> String {
        L10n.pick(
            language: language,
            english: "\(count) recommended items",
            norwegian: "\(count) anbefalte varer",
            thai: "รายการแนะนำ \(count) รายการ"
        )
    }
}

private struct RecommendationActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.indigo)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.indigo)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(InsetCardBackground())
    }
}

extension TemplateSupplyItem {
    func localizedName(in language: AppLanguage) -> String {
        switch id {
        case "water":
            return L10n.pick(language: language, english: "Drinking water", norwegian: "Drikkevann", thai: "น้ำดื่ม")
        case "shelfStableFood":
            return L10n.pick(language: language, english: "Shelf-stable food", norwegian: "Holdbar mat", thai: "อาหารเก็บได้นาน")
        case "cookingMethod":
            return L10n.pick(language: language, english: "Alternative cooking method", norwegian: "Alternativ kokemulighet", thai: "วิธีทำอาหารทางเลือก")
        case "warmth", "warmClothing":
            return L10n.pick(language: language, english: "Warm clothing and blankets", norwegian: "Varme klær og tepper", thai: "เสื้อผ้าอุ่นและผ้าห่ม")
        case "lighting", "batteryLighting":
            return L10n.pick(language: language, english: "Battery lighting", norwegian: "Batteribelysning", thai: "ไฟส่องสว่างใช้แบตเตอรี่")
        case "radio":
            return L10n.pick(language: language, english: "Battery or crank radio", norwegian: "Batteri- eller sveiveradio", thai: "วิทยุแบตเตอรี่หรือมือหมุน")
        case "batteries":
            return L10n.pick(language: language, english: "Batteries", norwegian: "Batterier", thai: "แบตเตอรี่")
        case "powerBank":
            return L10n.pick(language: language, english: "Power banks", norwegian: "Batteribanker", thai: "พาวเวอร์แบงก์")
        case "medicines":
            return L10n.pick(language: language, english: "Necessary medicines", norwegian: "Nødvendige legemidler", thai: "ยาที่จำเป็น")
        case "firstAid":
            return L10n.pick(language: language, english: "First aid supplies", norwegian: "Førstehjelpsutstyr", thai: "อุปกรณ์ปฐมพยาบาล")
        case "hygiene", "hygieneSupplies":
            return L10n.pick(language: language, english: "Hygiene supplies", norwegian: "Hygieneartikler", thai: "อุปกรณ์สุขอนามัย")
        case "paymentPreparedness", "paymentOptions":
            return L10n.pick(language: language, english: "Payment preparedness", norwegian: "Betalingsberedskap", thai: "การเตรียมพร้อมด้านการชำระเงิน")
        case "petHomeSupplies":
            return L10n.pick(language: language, english: "Pet food, water, and supplies", norwegian: "Mat, vann og utstyr til kjæledyr", thai: "อาหาร น้ำ และอุปกรณ์สัตว์เลี้ยง")
        case "childHomeSupplies":
            return L10n.pick(language: language, english: "Essential child supplies", norwegian: "Nødvendig utstyr til barn", thai: "อุปกรณ์จำเป็นสำหรับเด็ก")
        case "woodStoveFuel":
            return L10n.pick(language: language, english: "Dry firewood and matches", norwegian: "Tørr ved og fyrstikker", thai: "ฟืนแห้งและไม้ขีด")
        case "gasInstallationSupplies":
            return L10n.pick(language: language, english: "Gas installation preparedness", norwegian: "Beredskap for gassinstallasjon", thai: "การเตรียมพร้อมสำหรับระบบก๊าซ")
        case "identification":
            return L10n.pick(language: language, english: "Identification", norwegian: "Identifikasjon", thai: "เอกสารประจำตัว")
        case "assistiveDevices":
            return L10n.pick(language: language, english: "Assistive devices", norwegian: "Hjelpemidler", thai: "อุปกรณ์ช่วยเหลือ")
        case "phoneAndCharger":
            return L10n.pick(language: language, english: "Phone, charger, and power bank", norwegian: "Telefon, lader og batteribank", thai: "โทรศัพท์ ที่ชาร์จ และพาวเวอร์แบงก์")
        case "foodAndDrink":
            return L10n.pick(language: language, english: "Food and drink", norwegian: "Mat og drikke", thai: "อาหารและเครื่องดื่ม")
        case "documentCopies":
            return L10n.pick(language: language, english: "Critical document copies", norwegian: "Kopier av viktige dokumenter", thai: "สำเนาเอกสารสำคัญ")
        case "childEvacuationSupplies":
            return L10n.pick(language: language, english: "Essential child evacuation supplies", norwegian: "Nødvendig evakueringsutstyr til barn", thai: "อุปกรณ์อพยพที่จำเป็นสำหรับเด็ก")
        case "petEvacuationSupplies":
            return L10n.pick(language: language, english: "Essential pet evacuation supplies", norwegian: "Nødvendig evakueringsutstyr til kjæledyr", thai: "อุปกรณ์อพยพที่จำเป็นสำหรับสัตว์เลี้ยง")
        case "assistanceInformation":
            return L10n.pick(language: language, english: "Assistance needs information", norwegian: "Informasjon om hjelpebehov", thai: "ข้อมูลความต้องการความช่วยเหลือ")
        case "evChargingPlan":
            return L10n.pick(language: language, english: "EV charging and route plan", norwegian: "Plan for elbillading og rute", thai: "แผนชาร์จรถไฟฟ้าและเส้นทาง")
        default:
            return nameKey
        }
    }
}
