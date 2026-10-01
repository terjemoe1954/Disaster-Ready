import MapKit
import SwiftUI

struct OfficialWeatherAlertsSection: View {
    @State private var area = ""
    @State private var snapshot: WeatherAlertSnapshot?
    @State private var isLoading = false
    @State private var message: String?
    @State private var lastCoordinate: ShelterCoordinate?
    @State private var locationProvider = ShelterLocationProvider()

    let language: AppLanguage
    let openPlan: (EmergencyType) -> Void
    private let service = METWeatherAlertService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)
                .accessibilityIdentifier("officialWeatherAlertsSection")
            Text(explanation).font(.subheadline).foregroundStyle(.secondary)
            ViewThatFits(in: .horizontal) {
                HStack { searchField; searchButton; locationButton }
                VStack(alignment: .leading, spacing: 10) { searchField; HStack { searchButton; locationButton } }
            }
            if let message { Text(message).font(.footnote).foregroundStyle(.secondary).accessibilityIdentifier("weatherAlertStatus") }
            if let snapshot {
                Label(refreshText(snapshot), systemImage: snapshot.isCached ? "externaldrive.fill.badge.exclamationmark" : "checkmark.icloud.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(snapshot.isCached ? .orange : .secondary)
                    .accessibilityIdentifier("weatherAlertFreshness")
                ForEach(snapshot.alerts) { alert in
                    OfficialWeatherAlertRow(alert: alert, language: language, openPlan: openPlan)
                }
            }
            Link(destination: officialURL) { Label(officialLinkTitle, systemImage: "safari") }
                .font(.subheadline.weight(.semibold))
            Link(licenceTitle, destination: licenceURL)
                .font(.caption)
        }
        .padding(20)
        .background(DashboardCardBackground())
        .onChange(of: locationProvider.coordinate) { _, coordinate in
            guard let coordinate else { return }
            lastCoordinate = coordinate
            load(coordinate: coordinate)
        }
        .onChange(of: locationProvider.error) { _, error in
            guard error != nil else { return }
            isLoading = false
            message = locationUnavailableMessage
        }
        .onChange(of: language) { _, _ in
            if snapshot?.alerts.isEmpty == true { message = noAlertsMessage }
        }
    }

    private var searchField: some View {
        TextField(searchPlaceholder, text: $area)
            .textFieldStyle(.roundedBorder).submitLabel(.search).onSubmit(search)
            .accessibilityLabel(searchPlaceholder).accessibilityIdentifier("weatherAlertAreaSearchField")
    }
    private var searchButton: some View {
        Button(action: search) { Label(searchTitle, systemImage: "magnifyingglass") }
            .buttonStyle(.borderedProminent).disabled(area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            .accessibilityIdentifier("weatherAlertSearchButton")
    }
    private var locationButton: some View {
        Button {
            isLoading = true; message = nil; locationProvider.requestOneLocation()
            if !locationProvider.isRequesting, locationProvider.error != nil {
                isLoading = false
                message = locationUnavailableMessage
            }
        } label: { Label(useLocationTitle, systemImage: "location.fill") }
            .buttonStyle(.bordered).disabled(isLoading || locationProvider.isRequesting)
            .accessibilityIdentifier("weatherAlertUseLocationButton")
    }

    private func search() {
        let query = area.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        isLoading = true; message = nil
        Task {
            do {
                let request = MKLocalSearch.Request(); request.naturalLanguageQuery = "\(query), Norway"
                let response = try await MKLocalSearch(request: request).start()
                guard let coordinate = response.mapItems.first?.location.coordinate else { throw WeatherAlertServiceError.invalidCoordinate }
                let value = ShelterCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                lastCoordinate = value; await refresh(coordinate: value)
            } catch { snapshot = nil; message = unavailableMessage; isLoading = false }
        }
    }
    private func load(coordinate: ShelterCoordinate) { isLoading = true; message = nil; Task { await refresh(coordinate: coordinate) } }
    private func refresh(coordinate: ShelterCoordinate) async {
        do {
            let result = try await service.alertSnapshot(latitude: coordinate.latitude, longitude: coordinate.longitude, languageCode: language == .norwegian ? "no" : "en")
            snapshot = result; message = result.alerts.isEmpty ? noAlertsMessage : nil
        } catch { snapshot = nil; message = unavailableMessage }
        isLoading = false
    }
    private func refreshText(_ snapshot: WeatherAlertSnapshot) -> String {
        let date = snapshot.fetchedAt.formatted(.dateTime.day().month().year().hour().minute().locale(AppLanguage.locale(for: language)))
        return snapshot.isCached
            ? L10n.pick(language: language, english: "CACHED INFORMATION — last successful refresh: \(date)", norwegian: "HURTIGLAGRET INFORMASJON — sist oppdatert: \(date)", thai: "ข้อมูลที่แคชไว้ — รีเฟรชสำเร็จล่าสุด: \(date)")
            : L10n.pick(language: language, english: "REFRESHED OFFICIAL ALERT DATA: \(date)", norwegian: "OPPDATERTE OFFISIELLE FAREVARSLER: \(date)", thai: "ข้อมูลคำเตือนทางการที่รีเฟรชแล้ว: \(date)")
    }

    private let officialURL = URL(string: "https://www.met.no/vaer-og-klima/ekstremvaervarsler-og-andre-farevarsler")!
    private let licenceURL = URL(string: "https://api.met.no/doc/License")!
    private var title: String { L10n.pick(language: language, english: "Official weather warnings", norwegian: "Offisielle farevarsler", thai: "คำเตือนสภาพอากาศทางการ") }
    private var explanation: String { L10n.pick(language: language, english: "Official, time-sensitive MET Norway data. Search an area or request one location reading. Your coordinates stay on this device.", norwegian: "Offisielle, tidskritiske data fra MET. Søk etter et område eller be om én posisjonsmåling. Koordinatene forblir på enheten.", thai: "ข้อมูลทางการที่เปลี่ยนแปลงตามเวลาจาก MET Norway ค้นหาพื้นที่หรือขอตำแหน่งหนึ่งครั้ง พิกัดจะอยู่ในอุปกรณ์นี้เท่านั้น") }
    private var searchPlaceholder: String { L10n.pick(language: language, english: "Municipality, town, or address", norwegian: "Kommune, sted eller adresse", thai: "เทศบาล เมือง หรือที่อยู่") }
    private var searchTitle: String { L10n.pick(language: language, english: "Search", norwegian: "Søk", thai: "ค้นหา") }
    private var useLocationTitle: String { L10n.pick(language: language, english: "Use My Location", norwegian: "Bruk min posisjon", thai: "ใช้ตำแหน่งของฉัน") }
    private var noAlertsMessage: String { L10n.pick(language: language, english: "No active official weather warnings found for this area. This is not a guarantee of safety.", norwegian: "Ingen aktive offisielle farevarsler funnet for området. Dette er ingen garanti for sikkerhet.", thai: "ไม่พบคำเตือนสภาพอากาศทางการที่ยังมีผลสำหรับพื้นที่นี้ ข้อมูลนี้ไม่ใช่การรับประกันความปลอดภัย") }
    private var unavailableMessage: String { L10n.pick(language: language, english: "Official warning data is unavailable and no usable cache exists. The rest of Disaster Ready remains available.", norwegian: "Offisielle farevarsler er utilgjengelige, og ingen brukbar hurtigbuffer finnes. Resten av Disaster Ready er fortsatt tilgjengelig.", thai: "ข้อมูลคำเตือนทางการไม่พร้อมใช้งานและไม่มีแคชที่ใช้ได้ ส่วนอื่นของ Disaster Ready ยังคงใช้งานได้") }
    private var locationUnavailableMessage: String { L10n.pick(language: language, english: "Location is unavailable. You can still search manually.", norwegian: "Posisjon er utilgjengelig. Du kan fortsatt søke manuelt.", thai: "ตำแหน่งไม่พร้อมใช้งาน คุณยังคงค้นหาด้วยตนเองได้") }
    private var officialLinkTitle: String { L10n.pick(language: language, english: "Open MET's official warnings", norwegian: "Åpne METs offisielle farevarsler", thai: "เปิดคำเตือนทางการของ MET") }
    private var licenceTitle: String { L10n.pick(language: language, english: "Data from MET Norway · CC BY 4.0 / NLOD 2.0", norwegian: "Data fra MET Norway · CC BY 4.0 / NLOD 2.0", thai: "ข้อมูลจาก MET Norway · CC BY 4.0 / NLOD 2.0") }
}

private struct OfficialWeatherAlertRow: View {
    let alert: OfficialAlert
    let language: AppLanguage
    let openPlan: (EmergencyType) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(alert.headline ?? alert.event, systemImage: severityIcon).font(.headline).foregroundStyle(severityColor)
            Text(severityText).font(.subheadline.weight(.bold))
            if let area = alert.geographicDescription { Text(area).font(.subheadline.weight(.semibold)) }
            if let value = alert.alertDescription { Text(value) }
            if let value = alert.consequences { Text(value).font(.subheadline) }
            if let value = alert.instruction { Text(value).font(.subheadline.weight(.semibold)) }
            Text(validityText).font(.caption).foregroundStyle(.secondary)
            Text(sourceText).font(.caption).foregroundStyle(.secondary)
            if let plan = alert.planType {
                Button(planTitle(plan)) { openPlan(plan) }.buttonStyle(.bordered).accessibilityIdentifier("weatherAlertPlanShortcut")
            }
            if let webURL = alert.webURL { Link(linkTitle, destination: webURL).font(.subheadline.weight(.semibold)) }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading).background(InsetCardBackground())
        .accessibilityElement(children: .contain)
    }
    private var severityColor: Color { switch alert.severity { case .red: .red; case .orange: .orange; case .yellow: .yellow; case .green: .green; case .unknown: .primary } }
    private var severityIcon: String { alert.severity == .red ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill" }
    private var severityText: String { L10n.pick(language: language, english: "Official warning level: \(alert.severity.rawValue)", norwegian: "Offisielt farenivå: \(alert.severity.rawValue)", thai: "ระดับคำเตือนทางการ: \(alert.severity.rawValue)") }
    private var validityText: String {
        guard let end = alert.expiresAt else { return L10n.pick(language: language, english: "Expiry not supplied", norwegian: "Utløpstid ikke oppgitt", thai: "ไม่ได้ระบุเวลาสิ้นสุด") }
        let value = end.formatted(.dateTime.day().month().hour().minute().locale(AppLanguage.locale(for: language)))
        return L10n.pick(language: language, english: "Expires: \(value)", norwegian: "Utløper: \(value)", thai: "สิ้นสุด: \(value)")
    }
    private func planTitle(_ plan: EmergencyType) -> String {
        let name = plan == .flood ? L10n.pick(language: language, english: "flood", norwegian: "flom", thai: "น้ำท่วม") : L10n.pick(language: language, english: "extreme-weather", norwegian: "ekstremvær", thai: "สภาพอากาศรุนแรง")
        return L10n.pick(language: language, english: "Open my \(name) plan", norwegian: "Åpne planen min for \(name)", thai: "เปิดแผน\(name)ของฉัน")
    }
    private var sourceText: String { L10n.pick(language: language, english: "Source: Norwegian Meteorological Institute (MET Norway)", norwegian: "Kilde: Meteorologisk institutt (MET)", thai: "แหล่งข้อมูล: สถาบันอุตุนิยมวิทยานอร์เวย์ (MET Norway)") }
    private var linkTitle: String { L10n.pick(language: language, english: "Read at MET", norwegian: "Les hos MET", thai: "อ่านที่ MET") }
}
