import MapKit
import SwiftUI

struct PublicSheltersSection: View {
    @State private var area = ""
    @State private var snapshot: ShelterSnapshot?
    @State private var isLoading = false
    @State private var errorMessage: String?

    let language: AppLanguage
    private let service = GeonorgeShelterService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "shield.lefthalf.filled")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            Text(safetyMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                TextField(searchPlaceholder, text: $area)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit(search)
                    .accessibilityIdentifier("shelterAreaSearchField")

                Button(action: search) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .accessibilityLabel(searchTitle)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let snapshot {
                Text(updatedText(snapshot))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(snapshot.shelters) { shelter in
                    PublicShelterRow(shelter: shelter, language: language)
                }
            }

            Link(destination: officialMapURL) {
                Label(officialMapTitle, systemImage: "map.fill")
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(20)
        .background(DashboardCardBackground())
        .accessibilityIdentifier("publicSheltersSection")
    }

    private func search() {
        let query = area.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = "\(query), Norway"
                let response = try await MKLocalSearch(request: request).start()
                guard let coordinate = response.mapItems.first?.location.coordinate else {
                    throw ShelterServiceError.invalidCoordinate
                }
                let result = try await service.shelterSnapshot(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                snapshot = result
                if result.shelters.isEmpty { errorMessage = noResultsMessage }
            } catch {
                snapshot = nil
                errorMessage = searchFailedMessage
            }
            isLoading = false
        }
    }

    private func updatedText(_ snapshot: ShelterSnapshot) -> String {
        let date = snapshot.lastUpdated.formatted(
            .dateTime.day().month().year().hour().minute().locale(AppLanguage.locale(for: language))
        )
        let suffix = snapshot.isCached ? cachedSuffix : ""
        return L10n.pick(
            language: language,
            english: "Downloaded: \(date)\(suffix)",
            norwegian: "Lastet ned: \(date)\(suffix)",
            thai: "ดาวน์โหลด: \(date)\(suffix)"
        )
    }

    private let officialMapURL = URL(string: "https://kart.dsb.no/") ?? URL(fileURLWithPath: "/")
    private var title: String { L10n.pick(language: language, english: "Public civil-defence shelters", norwegian: "Offentlige tilfluktsrom", thai: "ที่หลบภัยสาธารณะ") }
    private var safetyMessage: String { L10n.pick(language: language, english: "These are official civil-defence shelters, not ordinary meeting places. Authorities determine when shelters should be used. Do not travel to one merely because it is nearby.", norwegian: "Dette er offentlige tilfluktsrom, ikke vanlige møteplasser. Myndighetene avgjør når tilfluktsrom skal brukes. Ikke dra dit bare fordi et rom ligger i nærheten.", thai: "สถานที่เหล่านี้เป็นที่หลบภัยพลเรือนอย่างเป็นทางการ ไม่ใช่จุดนัดพบทั่วไป เจ้าหน้าที่จะกำหนดว่าเมื่อใดควรใช้ อย่าเดินทางไปเพียงเพราะอยู่ใกล้") }
    private var searchPlaceholder: String { L10n.pick(language: language, english: "Municipality, town, or address", norwegian: "Kommune, sted eller adresse", thai: "เทศบาล เมือง หรือที่อยู่") }
    private var searchTitle: String { L10n.pick(language: language, english: "Search area", norwegian: "Søk i område", thai: "ค้นหาพื้นที่") }
    private var officialMapTitle: String { L10n.pick(language: language, english: "Open DSB's official map", norwegian: "Åpne DSBs offisielle kart", thai: "เปิดแผนที่ทางการของ DSB") }
    private var noResultsMessage: String { L10n.pick(language: language, english: "No registered public shelters were found within 25 km. The register may not cover every location.", norwegian: "Ingen registrerte offentlige tilfluktsrom ble funnet innen 25 km. Registeret dekker ikke nødvendigvis alle steder.", thai: "ไม่พบที่หลบภัยสาธารณะที่ลงทะเบียนในระยะ 25 กม. ทะเบียนอาจไม่ครอบคลุมทุกพื้นที่") }
    private var searchFailedMessage: String { L10n.pick(language: language, english: "The official shelter service is unavailable. Use DSB's official map or try again later.", norwegian: "Den offisielle tilfluktsromtjenesten er utilgjengelig. Bruk DSBs offisielle kart eller prøv senere.", thai: "บริการข้อมูลที่หลบภัยอย่างเป็นทางการไม่พร้อมใช้งาน โปรดใช้แผนที่ DSB หรือลองใหม่ภายหลัง") }
    private var cachedSuffix: String { L10n.pick(language: language, english: " (saved reference copy)", norwegian: " (lagret referansekopi)", thai: " (สำเนาอ้างอิงที่บันทึกไว้)") }
}

private struct PublicShelterRow: View {
    let shelter: Shelter
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(shelter.address.isEmpty ? roomTitle : shelter.address)
                .font(.headline)
            if let capacity = shelter.capacity {
                Text(capacityText(capacity))
                    .font(.subheadline)
            }
            Text(sourceText)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let updatedAt = shelter.dataUpdatedAt {
                Text(updatedAt, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .environment(\.locale, AppLanguage.locale(for: language))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
    }

    private var roomTitle: String { L10n.pick(language: language, english: "Shelter \(shelter.roomNumber)", norwegian: "Tilfluktsrom \(shelter.roomNumber)", thai: "ที่หลบภัย \(shelter.roomNumber)") }
    private func capacityText(_ capacity: Int) -> String { L10n.pick(language: language, english: "Registered capacity: \(capacity)", norwegian: "Registrert kapasitet: \(capacity)", thai: "ความจุที่ลงทะเบียน: \(capacity)") }
    private var sourceText: String { L10n.pick(language: language, english: "Source: DSB / Geonorge", norwegian: "Kilde: DSB / Geonorge", thai: "แหล่งข้อมูล: DSB / Geonorge") }
}
