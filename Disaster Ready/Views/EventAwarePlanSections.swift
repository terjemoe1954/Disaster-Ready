import SwiftUI

struct EmergencyTypePickerSection: View {
    @Binding var selection: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Picker(title, selection: $selection) {
                ForEach(EmergencyType.allCases) { emergencyType in
                    Text(emergencyType.localizedName(in: language))
                        .tag(emergencyType)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("emergencyTypePicker")
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Select emergency",
            norwegian: "Velg hendelse",
            thai: "เลือกเหตุฉุกเฉิน"
        )
    }
}

struct EmergencyActionsSection: View {
    let emergencyType: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: "checklist")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(emergencyType.localizedSummary(in: language))
                .foregroundStyle(.secondary)

            Label {
                Text(followOfficialInstructions)
            } icon: {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.orange)
            }

            Label {
                Text(emergencyType.preparationGuidance(in: language))
            } icon: {
                Image(systemName: "house.and.flag.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "What to do",
            norwegian: "Hva du bør gjøre",
            thai: "สิ่งที่ควรทำ"
        )
    }

    private var followOfficialInstructions: String {
        L10n.pick(
            language: language,
            english: "Monitor official information and follow current instructions from local authorities.",
            norwegian: "Følg med på offisiell informasjon og gjeldende instrukser fra lokale myndigheter.",
            thai: "ติดตามข้อมูลทางการและปฏิบัติตามคำแนะนำปัจจุบันจากหน่วยงานท้องถิ่น"
        )
    }
}

struct EmergencyShelterGuidanceSection: View {
    let emergencyType: EmergencyType
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "building.2.crop.circle")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(emergencyType.shelterGuidance(in: language))

            Text(safetyNotice)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(12)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(
            language: language,
            english: "Where to shelter or go",
            norwegian: "Hvor du kan søke ly eller dra",
            thai: "สถานที่หลบภัยหรือไป"
        )
    }

    private var safetyNotice: String {
        L10n.pick(
            language: language,
            english: "Suggested type of location for preparedness planning. Follow current instructions from local authorities during an actual emergency.",
            norwegian: "Forslag til type sted for beredskapsplanlegging. Følg gjeldende instrukser fra lokale myndigheter under en faktisk hendelse.",
            thai: "ประเภทสถานที่ที่แนะนำสำหรับการวางแผนเตรียมพร้อม ในเหตุฉุกเฉินจริงให้ปฏิบัติตามคำแนะนำปัจจุบันจากหน่วยงานท้องถิ่น"
        )
    }
}

struct PlanNextStepsSection: View {
    let language: AppLanguage
    let openSupplies: () -> Void
    let openContacts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Button(action: openSupplies) {
                Label(suppliesTitle, systemImage: "shippingbox.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            Button(action: openContacts) {
                Label(contactsTitle, systemImage: "person.2.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            Label(savedTitle, systemImage: "checkmark.icloud.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private var title: String {
        L10n.pick(language: language, english: "Complete your plan", norwegian: "Fullfør planen", thai: "จัดทำแผนให้เสร็จ")
    }

    private var suppliesTitle: String {
        L10n.pick(language: language, english: "Review supplies", norwegian: "Se gjennom utstyr", thai: "ตรวจสอบอุปกรณ์")
    }

    private var contactsTitle: String {
        L10n.pick(language: language, english: "Review contacts", norwegian: "Se gjennom kontakter", thai: "ตรวจสอบรายชื่อติดต่อ")
    }

    private var savedTitle: String {
        L10n.pick(
            language: language,
            english: "Changes are saved automatically on this device.",
            norwegian: "Endringer lagres automatisk på denne enheten.",
            thai: "การเปลี่ยนแปลงจะบันทึกโดยอัตโนมัติในอุปกรณ์นี้"
        )
    }
}

extension EmergencyType {
    func localizedName(in language: AppLanguage) -> String {
        switch self {
        case .powerOutage:
            return L10n.pick(language: language, english: "Power outage", norwegian: "Strømbrudd", thai: "ไฟฟ้าดับ")
        case .flood:
            return L10n.pick(language: language, english: "Flood", norwegian: "Flom", thai: "น้ำท่วม")
        case .extremeWeather:
            return L10n.pick(language: language, english: "Extreme weather", norwegian: "Ekstremvær", thai: "สภาพอากาศรุนแรง")
        case .landslide:
            return L10n.pick(language: language, english: "Landslide", norwegian: "Skred", thai: "ดินถล่ม")
        case .wildfire:
            return L10n.pick(language: language, english: "Wildfire", norwegian: "Skogbrann", thai: "ไฟป่า")
        case .houseFire:
            return L10n.pick(language: language, english: "House fire", norwegian: "Boligbrann", thai: "ไฟไหม้บ้าน")
        case .waterOutage:
            return L10n.pick(language: language, english: "Water outage", norwegian: "Vannbrudd", thai: "น้ำประปาขัดข้อง")
        case .evacuation:
            return L10n.pick(language: language, english: "Evacuation", norwegian: "Evakuering", thai: "การอพยพ")
        case .hazardousRelease:
            return L10n.pick(language: language, english: "Hazardous release", norwegian: "Farlig utslipp", thai: "การรั่วไหลของสารอันตราย")
        case .warOrSecurityIncident:
            return L10n.pick(language: language, english: "War or security incident", norwegian: "Krig eller sikkerhetshendelse", thai: "สงครามหรือเหตุการณ์ด้านความมั่นคง")
        }
    }

    func localizedSummary(in language: AppLanguage) -> String {
        L10n.pick(
            language: language,
            english: "Prepare your household for \(localizedName(in: language).lowercased()) before an emergency occurs.",
            norwegian: "Forbered husstanden på \(localizedName(in: language).lowercased()) før en hendelse oppstår.",
            thai: "เตรียมครัวเรือนสำหรับ\(localizedName(in: language))ก่อนเกิดเหตุฉุกเฉิน"
        )
    }

    func preparationGuidance(in language: AppLanguage) -> String {
        switch self {
        case .powerOutage:
            return L10n.pick(language: language, english: "Plan for light, communication, food preparation, and warmth without electricity.", norwegian: "Planlegg lys, kommunikasjon, matlaging og varme uten strøm.", thai: "วางแผนเรื่องแสงสว่าง การสื่อสาร การทำอาหาร และความอบอุ่นเมื่อไม่มีไฟฟ้า")
        case .flood:
            return L10n.pick(language: language, english: "Know the local flood risk and plan how to leave before routes become unsafe.", norwegian: "Kjenn lokal flomfare og planlegg hvordan dere kan dra før veiene blir utrygge.", thai: "ทราบความเสี่ยงน้ำท่วมในพื้นที่และวางแผนออกจากพื้นที่ก่อนเส้นทางไม่ปลอดภัย")
        case .extremeWeather:
            return L10n.pick(language: language, english: "Secure loose items and prepare for disrupted transport, power, and communication.", norwegian: "Sikre løse gjenstander og forbered bortfall av transport, strøm og kommunikasjon.", thai: "ยึดสิ่งของที่อาจปลิวและเตรียมพร้อมต่อการหยุดชะงักของการเดินทาง ไฟฟ้า และการสื่อสาร")
        case .landslide:
            return L10n.pick(language: language, english: "Know nearby risk areas and plan an early route to stable ground.", norwegian: "Kjenn nærliggende fareområder og planlegg en tidlig rute til stabil grunn.", thai: "ทราบพื้นที่เสี่ยงใกล้เคียงและวางแผนเส้นทางล่วงหน้าไปยังพื้นที่มั่นคง")
        case .wildfire:
            return L10n.pick(language: language, english: "Plan more than one route away from vegetation and smoke exposure.", norwegian: "Planlegg mer enn én rute bort fra vegetasjon og røykeksponering.", thai: "วางแผนมากกว่าหนึ่งเส้นทางออกจากพื้นที่พืชพรรณและควัน")
        case .houseFire:
            return L10n.pick(language: language, english: "Practice escape routes and agree on an outdoor meeting point at a safe distance.", norwegian: "Øv på rømningsveier og avtal et utendørs møtested på trygg avstand.", thai: "ฝึกเส้นทางหนีไฟและกำหนดจุดนัดพบกลางแจ้งที่อยู่ห่างอย่างปลอดภัย")
        case .waterOutage:
            return L10n.pick(language: language, english: "Store drinking water and plan for cooking, hygiene, and sanitation.", norwegian: "Lagre drikkevann og planlegg matlaging, hygiene og sanitærbehov.", thai: "เก็บน้ำดื่มและวางแผนการทำอาหาร สุขอนามัย และการสุขาภิบาล")
        case .evacuation:
            return L10n.pick(language: language, english: "Plan where to go, how to travel, and what essential items to bring.", norwegian: "Planlegg hvor dere kan dra, hvordan dere kommer dit og hva dere må ta med.", thai: "วางแผนว่าจะไปที่ใด เดินทางอย่างไร และต้องนำสิ่งจำเป็นใดไป")
        case .hazardousRelease:
            return L10n.pick(language: language, english: "Know how to close doors and ventilation while awaiting official instructions.", norwegian: "Vit hvordan dører og ventilasjon kan stenges mens dere venter på offisielle instrukser.", thai: "ทราบวิธีปิดประตูและระบบระบายอากาศระหว่างรอคำแนะนำทางการ")
        case .warOrSecurityIncident:
            return L10n.pick(language: language, english: "Prepare to receive official warnings and identify protective places in the building.", norwegian: "Forbered mottak av offisielle varsler og finn beskyttende steder i bygget.", thai: "เตรียมรับคำเตือนทางการและระบุจุดที่ให้การป้องกันภายในอาคาร")
        }
    }

    func shelterGuidance(in language: AppLanguage) -> String {
        switch self {
        case .flood, .landslide, .wildfire:
            return L10n.pick(language: language, english: "Plan a location outside the affected or risk area and more than one route there.", norwegian: "Planlegg et sted utenfor det berørte området eller fareområdet, og mer enn én rute dit.", thai: "วางแผนสถานที่นอกพื้นที่ได้รับผลกระทบหรือพื้นที่เสี่ยง พร้อมเส้นทางไปมากกว่าหนึ่งเส้นทาง")
        case .extremeWeather:
            return L10n.pick(language: language, english: "Identify a robust indoor location appropriate to the official warning.", norwegian: "Finn et robust innendørs oppholdssted som passer til det offisielle varselet.", thai: "ระบุสถานที่ภายในอาคารที่แข็งแรงและเหมาะกับคำเตือนทางการ")
        case .houseFire:
            return L10n.pick(language: language, english: "Choose a predetermined outdoor meeting point at a safe distance from the home.", norwegian: "Velg et avtalt utendørs møtested på trygg avstand fra boligen.", thai: "เลือกจุดนัดพบกลางแจ้งที่กำหนดไว้ล่วงหน้าและอยู่ห่างจากบ้านอย่างปลอดภัย")
        case .evacuation:
            return L10n.pick(language: language, english: "Plan for family, friends, or a secondary home. Use an evacuation centre only when authorities establish one.", norwegian: "Planlegg familie, venner eller sekundærbolig. Bruk et evakueringssenter bare når myndighetene oppretter ett.", thai: "วางแผนไปยังครอบครัว เพื่อน หรือบ้านสำรอง ใช้ศูนย์อพยพเฉพาะเมื่อหน่วยงานจัดตั้งขึ้น")
        case .warOrSecurityIncident:
            return L10n.pick(language: language, english: "Follow official instructions about sheltering in place, evacuation, or civil-defence shelters.", norwegian: "Følg offisielle instrukser om å søke dekning der du er, evakuering eller tilfluktsrom.", thai: "ปฏิบัติตามคำแนะนำทางการเรื่องการหลบภัยในที่พัก การอพยพ หรือหลุมหลบภัยพลเรือน")
        case .powerOutage, .waterOutage:
            return L10n.pick(language: language, english: "Plan whether to remain at home or stay with someone who has the utilities you need.", norwegian: "Planlegg om dere skal bli hjemme eller bo hos noen som har forsyningene dere trenger.", thai: "วางแผนว่าจะอยู่บ้านหรือพักกับผู้ที่มีสาธารณูปโภคที่จำเป็น")
        case .hazardousRelease:
            return L10n.pick(language: language, english: "Identify an indoor room where doors, windows, and ventilation can be closed.", norwegian: "Finn et innendørs rom der dører, vinduer og ventilasjon kan stenges.", thai: "ระบุห้องภายในอาคารที่สามารถปิดประตู หน้าต่าง และระบบระบายอากาศได้")
        }
    }
}
