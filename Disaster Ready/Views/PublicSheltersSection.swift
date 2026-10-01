import SwiftUI

struct PublicSheltersSection: View {
    @State private var query = ""
    @State private var snapshot: ShelterSnapshot?
    @State private var isLoading = false
    @State private var messageKey: String?
    @State private var locationProvider = ShelterLocationProvider()

    let language: AppLanguage
    private let service = GeonorgeShelterService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ShelterReferenceIntroduction(language: language)
            ShelterManualSearch(
                query: $query,
                isLoading: isLoading,
                language: language,
                search: searchOfficialRegister
            )
            ShelterLocationLookup(
                isRequesting: locationProvider.isRequesting || isLoading,
                language: language,
                requestLocation: locationProvider.requestOneLocation
            )

            if let messageKey {
                Text(L10n.text(messageKey, language: language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("shelterReferenceStatus")
            }

            if let snapshot {
                ShelterResults(snapshot: snapshot, language: language)
            }

            ShelterSourceSection(language: language)
        }
        .padding(20)
        .background(DashboardCardBackground())
        .onChange(of: locationProvider.coordinate) { _, coordinate in
            guard let coordinate else { return }
            Task { await loadNearby(coordinate) }
        }
        .onChange(of: locationProvider.error) { _, error in
            guard let error else { return }
            messageKey = error == .permissionUnavailable
                ? "shelter_reference.location.permission_error"
                : "shelter_reference.location.error"
        }
    }

    private func searchOfficialRegister() {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        Task {
            await performLookup {
                try await service.searchSnapshot(matching: value)
            }
        }
    }

    private func loadNearby(_ coordinate: ShelterCoordinate) async {
        await performLookup {
            try await service.shelterSnapshot(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
    }

    @MainActor
    private func performLookup(_ lookup: () async throws -> ShelterSnapshot) async {
        isLoading = true
        messageKey = nil
        do {
            let result = try await lookup()
            snapshot = result
            if result.shelters.isEmpty {
                messageKey = "shelter_reference.no_results"
            }
        } catch {
            snapshot = nil
            messageKey = "shelter_reference.unavailable"
        }
        isLoading = false
    }
}

private struct ShelterReferenceIntroduction: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.text("shelter_reference.title", language: language), systemImage: "shield.lefthalf.filled")
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)
                .accessibilityIdentifier("publicSheltersSection")
            Text(L10n.text("shelter_reference.safety", language: language))
                .font(.subheadline.weight(.semibold))
            Text(L10n.text("shelter_reference.not_live", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ShelterManualSearch: View {
    @Binding var query: String
    let isLoading: Bool
    let language: AppLanguage
    let search: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.text("shelter_reference.manual.title", language: language))
                .font(.headline)
            Text(L10n.text("shelter_reference.manual.detail", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack {
                TextField(L10n.text("shelter_reference.manual.placeholder", language: language), text: $query)
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 44)
                    .submitLabel(.search)
                    .onSubmit(search)
                    .accessibilityIdentifier("shelterAreaSearchField")
                Button(action: search) {
                    Image(systemName: "magnifyingglass")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .accessibilityLabel(L10n.text("shelter_reference.search", language: language))
                .accessibilityIdentifier("searchOfficialSheltersButton")
            }
        }
    }
}

private struct ShelterLocationLookup: View {
    let isRequesting: Bool
    let language: AppLanguage
    let requestLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.text("shelter_reference.location.title", language: language))
                .font(.headline)
            Text(L10n.text("shelter_reference.location.detail", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button(action: requestLocation) {
                Label {
                    Text(L10n.text("shelter_reference.location.button", language: language))
                } icon: {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Image(systemName: "location.fill")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .disabled(isRequesting)
            .accessibilityIdentifier("useMyLocationForSheltersButton")
        }
    }
}

private struct ShelterResults: View {
    let snapshot: ShelterSnapshot
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(refreshText)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let datasetUpdatedAt = snapshot.datasetUpdatedAt {
                Text(L10n.format("shelter_reference.dataset_date", language: language, formatted(datasetUpdatedAt)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if snapshot.origin != nil {
                Text(L10n.text("shelter_reference.distance_notice", language: language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(snapshot.shelters) { shelter in
                PublicShelterRow(
                    shelter: shelter,
                    distance: distance(to: shelter),
                    language: language
                )
            }
        }
        .accessibilityIdentifier("publicShelterResults")
    }

    private var refreshText: String {
        let key = snapshot.isCached ? "shelter_reference.cached" : "shelter_reference.refreshed"
        return L10n.format(key, language: language, formatted(snapshot.lastUpdated))
    }

    private func formatted(_ date: Date) -> String {
        date.formatted(
            .dateTime.day().month().year().hour().minute().locale(AppLanguage.locale(for: language))
        )
    }

    private func distance(to shelter: CivilDefenceShelter) -> Double? {
        guard let origin = snapshot.origin else { return nil }
        return try? ShelterProximity.distance(from: origin, to: shelter)
    }
}

private struct PublicShelterRow: View {
    let shelter: CivilDefenceShelter
    let distance: Double?
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(primaryTitle)
                .font(.headline)
            if let roomNumber = shelter.roomNumber, !roomNumber.isEmpty, primaryTitle != roomNumber {
                Text(L10n.format("shelter_reference.room", language: language, roomNumber))
                    .font(.subheadline)
            }
            if let municipality = shelter.municipality, !municipality.isEmpty {
                Text(municipality)
                    .font(.subheadline)
            }
            if let capacity = shelter.capacity {
                Text(L10n.format("shelter_reference.capacity", language: language, capacity))
                    .font(.subheadline)
            }
            if let distance {
                Text(L10n.format("shelter_reference.distance", language: language, formattedDistance(distance)))
                    .font(.subheadline)
            }
            Label(L10n.text("shelter_reference.official_data", language: language), systemImage: "checkmark.seal.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
            Link(destination: mapURL) {
                Label(L10n.text("shelter_reference.view_map", language: language), systemImage: "map.fill")
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("viewShelterOnMapButton")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(InsetCardBackground())
        .accessibilityElement(children: .contain)
    }

    private var primaryTitle: String {
        if let name = shelter.name, !name.isEmpty { return name }
        if let address = shelter.address, !address.isEmpty { return address }
        if let roomNumber = shelter.roomNumber, !roomNumber.isEmpty { return roomNumber }
        return L10n.text("shelter_reference.unnamed", language: language)
    }

    private func formattedDistance(_ kilometers: Double) -> String {
        Measurement(value: kilometers, unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .road).locale(AppLanguage.locale(for: language)))
    }

    private var mapURL: URL {
        var components = URLComponents(string: "https://maps.apple.com/place")
        components?.queryItems = [
            URLQueryItem(name: "coordinate", value: "\(shelter.latitude),\(shelter.longitude)"),
            URLQueryItem(name: "name", value: primaryTitle)
        ]
        return components?.url ?? URL(string: "https://maps.apple.com/")!
    }
}

private struct ShelterSourceSection: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("shelter_reference.source_section", language: language))
                .font(.headline)
            ForEach(sources) { source in
                SourceAttributionCard(source: source, language: language)
            }
        }
    }

    @MainActor private var sources: [GuidanceSource] {
        ["dsb-civil-defence-shelters", GeonorgeShelterService.sourceID]
            .compactMap(GuidanceSourceRegistry.source(for:))
    }
}
