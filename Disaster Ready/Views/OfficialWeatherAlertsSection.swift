import MapKit
import SwiftUI

struct OfficialWeatherAlertsSection: View {
    @State private var area = ""
    @State private var snapshot: WeatherAlertSnapshot?
    @State private var isLoading = false
    @State private var message: String?

    let language: AppLanguage
    private let service = METWeatherAlertService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)
            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                TextField(searchPlaceholder, text: $area)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit(search)
                    .accessibilityIdentifier("weatherAlertAreaSearchField")
                Button(action: search) {
                    if isLoading { ProgressView() } else { Image(systemName: "magnifyingglass") }
                }
                .buttonStyle(.borderedProminent)
                .disabled(area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .accessibilityLabel(searchTitle)
            }
            if let message {
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }
            if let snapshot {
                Text(updatedText(snapshot))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(snapshot.alerts) { alert in
                    OfficialWeatherAlertRow(alert: alert, language: language)
                }
            }
            Link(destination: officialURL) {
                Label(officialLinkTitle, systemImage: "safari")
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("officialWeatherAlertsSection")
    }

    private func search() {
        let query = area.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        isLoading = true
        message = nil
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = "\(query), Norway"
                let response = try await MKLocalSearch(request: request).start()
                guard let coordinate = response.mapItems.first?.location.coordinate else {
                    throw WeatherAlertServiceError.invalidCoordinate
                }
                let result = try await service.alertSnapshot(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    languageCode: language == .norwegian ? "no" : "en"
                )
                snapshot = result
                message = result.alerts.isEmpty ? noAlertsMessage : nil
            } catch {
                snapshot = nil
                message = unavailableMessage
            }
            isLoading = false
        }
    }

    private func updatedText(_ snapshot: WeatherAlertSnapshot) -> String {
        let date = snapshot.lastUpdated.formatted(.dateTime.day().month().year().hour().minute().locale(AppLanguage.locale(for: language)))
        let cached = snapshot.isCached ? cachedSuffix : ""
        return L10n.pick(language: language, english: "Updated: \(date)\(cached)", norwegian: "Oppdatert: \(date)\(cached)", thai: "อัปเดต: \(date)\(cached)")
    }

    private let officialURL = URL(string: "https://www.met.no/vaer-og-klima/ekstremvaervarsler-og-andre-farevarsler")!
    private var title: String { L10n.pick(language: language, english: "Official weather warnings", norwegian: "Offisielle farevarsler", thai: "คำเตือนสภาพอากาศทางการ") }
    private var explanation: String { L10n.pick(language: language, english: "Search a Norwegian area for active warnings issued by the Norwegian Meteorological Institute. Follow the official instructions shown without modification.", norwegian: "Søk etter aktive farevarsler fra Meteorologisk institutt for et område i Norge. Følg de offisielle rådene som vises uten endringer.", thai: "ค้นหาคำเตือนที่ยังมีผลจากสถาบันอุตุนิยมวิทยานอร์เวย์ ข้อความทางการจะแสดงเป็นภาษาอังกฤษโดยไม่มีการดัดแปลง") }
    private var searchPlaceholder: String { L10n.pick(language: language, english: "Municipality, town, or address", norwegian: "Kommune, sted eller adresse", thai: "เทศบาล เมือง หรือที่อยู่") }
    private var searchTitle: String { L10n.pick(language: language, english: "Search warnings", norwegian: "Søk etter varsler", thai: "ค้นหาคำเตือน") }
    private var noAlertsMessage: String { L10n.pick(language: language, english: "No active official MET warnings were found for this area.", norwegian: "Ingen aktive offisielle farevarsler fra MET ble funnet for området.", thai: "ไม่พบคำเตือนทางการจาก MET ที่ยังมีผลสำหรับพื้นที่นี้") }
    private var unavailableMessage: String { L10n.pick(language: language, english: "Official warnings are unavailable. Check MET's official website and try again later.", norwegian: "Offisielle varsler er utilgjengelige. Sjekk METs offisielle nettsted og prøv igjen senere.", thai: "ไม่สามารถโหลดคำเตือนทางการได้ โปรดตรวจสอบเว็บไซต์ทางการของ MET และลองอีกครั้ง") }
    private var officialLinkTitle: String { L10n.pick(language: language, english: "Open MET's official warnings", norwegian: "Åpne METs offisielle farevarsler", thai: "เปิดคำเตือนทางการของ MET") }
    private var cachedSuffix: String { L10n.pick(language: language, english: " (saved copy)", norwegian: " (lagret kopi)", thai: " (สำเนาที่บันทึกไว้)") }
}

private struct OfficialWeatherAlertRow: View {
    let alert: OfficialAlert
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(alert.title, systemImage: severityIcon)
                .font(.headline)
                .foregroundStyle(severityColor)
            Text(alert.area).font(.subheadline.weight(.semibold))
            Text(alert.alertDescription)
            if !alert.consequences.isEmpty { Text(alert.consequences).font(.subheadline) }
            if !alert.instruction.isEmpty { Text(alert.instruction).font(.subheadline.weight(.semibold)) }
            Text(validityText).font(.caption).foregroundStyle(.secondary)
            Text(sourceText).font(.caption).foregroundStyle(.secondary)
            if let webURL = alert.webURL {
                Link(linkTitle, destination: webURL).font(.subheadline.weight(.semibold))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
    }

    private var severityColor: Color {
        switch alert.severity { case .red: .red; case .orange: .orange; case .yellow: .yellow; case .unknown: .primary }
    }
    private var severityIcon: String { alert.severity == .red ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill" }
    private var validityText: String {
        let end = alert.expiresAt.formatted(.dateTime.day().month().hour().minute().locale(AppLanguage.locale(for: language)))
        return L10n.pick(language: language, english: "Valid until \(end)", norwegian: "Gyldig til \(end)", thai: "มีผลถึง \(end)")
    }
    private var sourceText: String { L10n.pick(language: language, english: "Source: Norwegian Meteorological Institute (MET)", norwegian: "Kilde: Meteorologisk institutt (MET)", thai: "แหล่งข้อมูล: สถาบันอุตุนิยมวิทยานอร์เวย์ (MET)") }
    private var linkTitle: String { L10n.pick(language: language, english: "Read at MET", norwegian: "Les hos MET", thai: "อ่านที่ MET") }
}
