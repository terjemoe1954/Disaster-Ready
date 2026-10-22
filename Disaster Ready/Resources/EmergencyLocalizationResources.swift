import Foundation

/// Static resources make semantic template keys visible to Xcode's String
/// Catalog extractor while templates continue to persist only stable keys.
enum EmergencyLocalizationResources {
    static let all: [LocalizedStringResource] = [
        LocalizedStringResource("emergency.powerOutage.title", defaultValue: "Power outage", comment: "Emergency type title"),
        LocalizedStringResource("emergency.powerAndCommunicationsOutage.title", defaultValue: "Power and communications outage", comment: "Emergency type title"),
        LocalizedStringResource("emergency.flood.title", defaultValue: "Flood", comment: "Emergency type title"),
        LocalizedStringResource("emergency.extremeWeather.title", defaultValue: "Extreme weather", comment: "Emergency type title"),
        LocalizedStringResource("emergency.landslide.title", defaultValue: "Landslide", comment: "Emergency type title"),
        LocalizedStringResource("emergency.wildfire.title", defaultValue: "Wildfire", comment: "Emergency type title"),
        LocalizedStringResource("emergency.houseFire.title", defaultValue: "House fire", comment: "Emergency type title"),
        LocalizedStringResource("emergency.waterOutage.title", defaultValue: "Water outage", comment: "Emergency type title"),
        LocalizedStringResource("emergency.evacuation.title", defaultValue: "Evacuation", comment: "Emergency type title"),
        LocalizedStringResource("emergency.hazardousRelease.title", defaultValue: "Hazardous release", comment: "Emergency type title"),
        LocalizedStringResource("emergency.warOrSecurityIncident.title", defaultValue: "War or security incident", comment: "Emergency type title"),

        LocalizedStringResource("emergency.powerOutage.summary", defaultValue: "Prepare the household for loss of electricity, communication, cooking, and heating.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.powerAndCommunicationsOutage.summary", defaultValue: "Power, mobile networks, internet, and satellite services may be unavailable at the same time. Your saved plan and offline guidance remain available here.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.flood.summary", defaultValue: "Prepare for flooding, unsafe routes, and possible evacuation from risk areas.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.extremeWeather.summary", defaultValue: "Prepare for severe weather and disruptions to transport, power, and communication.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.landslide.summary", defaultValue: "Prepare for landslide risk, blocked routes, and the need to leave early.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.wildfire.summary", defaultValue: "Prepare for smoke, rapidly changing fire conditions, and possible evacuation.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.houseFire.summary", defaultValue: "Prepare escape routes and a household meeting point outside the home.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.waterOutage.summary", defaultValue: "Prepare for loss of drinking water, sanitation, and normal cooking facilities.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.evacuation.summary", defaultValue: "Prepare where to go, how to travel, and which essential items to bring.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.hazardousRelease.summary", defaultValue: "Prepare to limit exposure and follow current instructions from authorities.", comment: "Offline preparedness summary"),
        LocalizedStringResource("emergency.warOrSecurityIncident.summary", defaultValue: "Prepare to receive official warnings and follow instructions about sheltering or evacuation.", comment: "Offline preparedness summary"),

        LocalizedStringResource("action.follow_official_information.title", defaultValue: "Follow official information", comment: "Preparedness action title"),
        LocalizedStringResource("action.follow_official_information.detail", defaultValue: "Monitor official information and follow current instructions from local authorities.", comment: "Safety-critical preparedness guidance"),
        LocalizedStringResource("action.powerOutage.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.powerOutage.prepare.detail", defaultValue: "Plan for light, communication, food preparation, and warmth without electricity.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.flood.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.flood.prepare.detail", defaultValue: "Know the local flood risk and plan how to leave before routes become unsafe.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.extremeWeather.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.extremeWeather.prepare.detail", defaultValue: "Secure loose items and prepare for disrupted transport, power, and communication.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.landslide.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.landslide.prepare.detail", defaultValue: "Know nearby risk areas and plan an early route to stable ground.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.wildfire.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.wildfire.prepare.detail", defaultValue: "Plan more than one route away from vegetation and smoke exposure.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.houseFire.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.houseFire.prepare.detail", defaultValue: "Practise escape routes and agree on an outdoor meeting point at a safe distance.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.waterOutage.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.waterOutage.prepare.detail", defaultValue: "Store drinking water and plan for cooking, hygiene, and sanitation.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.evacuation.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.evacuation.prepare.detail", defaultValue: "Plan where to go, how to travel, and what essential items to bring.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.hazardousRelease.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.hazardousRelease.prepare.detail", defaultValue: "Know how to close doors and ventilation while awaiting official instructions.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.warOrSecurityIncident.prepare.title", defaultValue: "Prepare your household", comment: "Preparedness action title"),
        LocalizedStringResource("action.warOrSecurityIncident.prepare.detail", defaultValue: "Prepare to receive official warnings and identify protective places in the building.", comment: "Offline preparedness guidance"),
        LocalizedStringResource("action.gas_installation.prepare.title", defaultValue: "Prepare for the gas installation", comment: "Shown only when a Norwegian household declares a gas installation"),
        LocalizedStringResource("action.gas_installation.prepare.detail", defaultValue: "Record where the gas shutoff is and follow instructions from emergency services or a qualified professional.", comment: "Gas preparedness guidance; never shown by default"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.check_safety.title", defaultValue: "Check that you and people nearby are safe", comment: "Combined outage action title"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.check_safety.detail", defaultValue: "Move away from immediate danger and help others only when you can do so safely.", comment: "Combined outage safety guidance"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.open_plan.title", defaultValue: "Open your emergency plan", comment: "Combined outage action title"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.open_plan.detail", defaultValue: "Use your saved meeting places, preparedness buddy, and offline directions. Do not assume a saved place is an official help centre.", comment: "Combined outage offline guidance"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.save_battery.title", defaultValue: "Save phone battery", comment: "Combined outage action title"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.save_battery.detail", defaultValue: "Use the phone only when needed and keep local guidance available. The app does not change connection settings for you.", comment: "Combined outage battery guidance"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.try_dab.title", defaultValue: "Try a battery-powered DAB radio", comment: "Combined outage action title"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.try_dab.detail", defaultValue: "NRK P1 is Norway's emergency preparedness channel, but reception is not guaranteed during every disruption.", comment: "Combined outage radio guidance"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.local_information.title", defaultValue: "Check saved places for information and help", comment: "Combined outage action title"),
        LocalizedStringResource("action.powerAndCommunicationsOutage.local_information.detail", defaultValue: "A saved address is planning information only. Opening hours, staffing, safe travel, and current availability are not confirmed.", comment: "Combined outage local information disclaimer"),

        LocalizedStringResource("shelter.outside_risk_area.title", defaultValue: "Outside the risk area", comment: "Suggested planning location type, not an official safe place"),
        LocalizedStringResource("shelter.outside_risk_area.detail", defaultValue: "Plan a location outside the affected or risk area and follow official evacuation instructions.", comment: "Safety-critical planning guidance"),
        LocalizedStringResource("shelter.robust_indoor_location.title", defaultValue: "Robust indoor location", comment: "Suggested planning location type, not an official shelter"),
        LocalizedStringResource("shelter.robust_indoor_location.detail", defaultValue: "Identify a robust indoor location appropriate to the current official warning.", comment: "Safety-critical planning guidance"),
        LocalizedStringResource("shelter.outdoor_meeting_point.title", defaultValue: "Outdoor meeting point", comment: "Suggested household meeting-point type"),
        LocalizedStringResource("shelter.outdoor_meeting_point.detail", defaultValue: "Choose a predetermined outdoor household meeting point at a safe distance from the home.", comment: "House-fire planning guidance"),
        LocalizedStringResource("shelter.planned_alternative_accommodation.title", defaultValue: "Planned alternative accommodation", comment: "Suggested planning location type"),
        LocalizedStringResource("shelter.planned_alternative_accommodation.detail", defaultValue: "Plan for family, friends, or a secondary home. Keep this separate from an official evacuation centre established by authorities.", comment: "Evacuation planning guidance"),
        LocalizedStringResource("shelter.follow_shelter_instructions.title", defaultValue: "Follow authority instructions", comment: "War or security incident location guidance"),
        LocalizedStringResource("shelter.follow_shelter_instructions.detail", defaultValue: "Current authority instructions determine whether to shelter in place, evacuate, or use a civil-defence shelter.", comment: "Safety-critical war or security guidance"),
        LocalizedStringResource("shelter.home_or_alternative_accommodation.title", defaultValue: "Home or alternative accommodation", comment: "Suggested planning location type"),
        LocalizedStringResource("shelter.home_or_alternative_accommodation.detail", defaultValue: "Plan whether to remain at home or stay with someone who has the utilities you need.", comment: "Preparedness location guidance"),
        LocalizedStringResource("shelter.preparedness_not_official.notice", defaultValue: "Suggested type of location for preparedness planning. Follow current instructions from local authorities during an actual emergency.", comment: "Required safety disclaimer for every template-generated location")
    ]

    static func value(for key: String, language: AppLanguage) -> String? {
        guard let values = outageTranslations[key] else { return nil }
        return switch language {
        case .english: values.english
        case .norwegian: values.norwegian
        case .thai: values.thai
        }
    }

    private static let outageTranslations: [String: (english: String, norwegian: String, thai: String)] = [
        "emergency.powerAndCommunicationsOutage.title": ("Power and communications outage", "Strøm og kommunikasjon borte", "ไฟฟ้าและการสื่อสารขัดข้อง"),
        "emergency.powerAndCommunicationsOutage.summary": ("Power, mobile networks, internet, and satellite services may be unavailable at the same time. Your saved plan and offline guidance remain available here.", "Strøm, mobilnett, internett og satellittjenester kan være utilgjengelige samtidig. Her finner du planen din og råd som er lagret på telefonen.", "ไฟฟ้า เครือข่ายมือถือ อินเทอร์เน็ต และบริการดาวเทียมอาจใช้งานไม่ได้พร้อมกัน แผนและคำแนะนำที่บันทึกไว้ยังคงอยู่ที่นี่"),
        "action.powerAndCommunicationsOutage.check_safety.title": ("Check that you and people nearby are safe", "Sjekk at du og de rundt deg er trygge", "ตรวจสอบว่าคุณและคนรอบข้างปลอดภัย"),
        "action.powerAndCommunicationsOutage.check_safety.detail": ("Move away from immediate danger and help others only when you can do so safely.", "Kom deg bort fra umiddelbar fare, og hjelp andre bare når det kan gjøres trygt.", "ออกห่างจากอันตรายทันที และช่วยผู้อื่นเมื่อทำได้อย่างปลอดภัยเท่านั้น"),
        "action.powerAndCommunicationsOutage.open_plan.title": ("Open your emergency plan", "Åpne nødplanen din", "เปิดแผนฉุกเฉินของคุณ"),
        "action.powerAndCommunicationsOutage.open_plan.detail": ("Use your saved meeting places, preparedness buddy, and offline directions. Do not assume a saved place is an official help centre.", "Bruk lagrede møteplasser, beredskapsvenn og veibeskrivelser. Ikke anta at et lagret sted er et offentlig hjelpesenter.", "ใช้จุดนัดพบ เพื่อนเตรียมพร้อม และเส้นทางที่บันทึกไว้ อย่าถือว่าสถานที่ที่บันทึกเป็นศูนย์ช่วยเหลือของทางการ"),
        "action.powerAndCommunicationsOutage.save_battery.title": ("Save phone battery", "Spar telefonbatteriet", "ประหยัดแบตเตอรี่โทรศัพท์"),
        "action.powerAndCommunicationsOutage.save_battery.detail": ("Use the phone only when needed and keep local guidance available. The app does not change connection settings for you.", "Bruk telefonen bare når det trengs, og behold lokale råd tilgjengelig. Appen endrer ikke tilkoblingsinnstillinger for deg.", "ใช้โทรศัพท์เมื่อจำเป็นและเก็บคำแนะนำในเครื่องไว้ แอปจะไม่เปลี่ยนการตั้งค่าการเชื่อมต่อให้คุณ"),
        "action.powerAndCommunicationsOutage.try_dab.title": ("Try a battery-powered DAB radio", "Prøv batteridrevet DAB-radio", "ลองวิทยุ DAB ที่ใช้แบตเตอรี่"),
        "action.powerAndCommunicationsOutage.try_dab.detail": ("NRK P1 is Norway's emergency preparedness channel, but reception is not guaranteed during every disruption.", "NRK P1 er beredskapskanalen, men mottak kan ikke garanteres ved alle typer bortfall.", "NRK P1 เป็นช่องเตรียมพร้อมฉุกเฉิน แต่ไม่รับประกันว่าจะรับสัญญาณได้ในทุกเหตุขัดข้อง"),
        "action.powerAndCommunicationsOutage.local_information.title": ("Check saved places for information and help", "Se lagrede steder for informasjon og hjelp", "ดูสถานที่ที่บันทึกไว้สำหรับข้อมูลและความช่วยเหลือ"),
        "action.powerAndCommunicationsOutage.local_information.detail": ("A saved address is planning information only. Opening hours, staffing, safe travel, and current availability are not confirmed.", "En lagret adresse er bare planleggingsinformasjon. Åpningstid, bemanning, trygg ferdsel og tilgjengelighet er ikke bekreftet.", "ที่อยู่ที่บันทึกไว้เป็นข้อมูลวางแผนเท่านั้น ไม่ได้ยืนยันเวลาเปิด บุคลากร ความปลอดภัยในการเดินทาง หรือการให้บริการปัจจุบัน")
    ]
}
