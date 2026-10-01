import Foundation

enum GuidanceSourceRegistry {
    /// A review date records Disaster Ready's comparison of bundled guidance.
    /// It must never be interpreted as a live authority update timestamp.
    static let reviewDateRepresentsLiveUpdate = false

    static let norway: [GuidanceSource] = [
        GuidanceSource(
            id: "dsb-self-preparedness",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Egenberedskap",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "dsb-flood-preparedness",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Slik forbereder du deg på flom",
            url: officialURL("https://www.dsb.no/sikkerhverdag/produkter-utstyr-og-fritid/slik-forbereder-du-deg-pa-flom/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "dsb-crisis-locations",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Oppholdssteder i kriser",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/oppholdssteder-i-kriser/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "dsb-civil-defence-shelters",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Verdt å vite om tilfluktsrom",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/verdt-a-vite-om-tilfluktsrom/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: GeonorgeShelterService.sourceID,
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB) / Geonorge",
            title: "Tilfluktsrom – Offentlige",
            url: officialURL("https://kartkatalog.geonorge.no/Metadata/uuid/dbae9aae-10e7-4b75-8d67-7f0e8828f3d8"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "met-weather-warnings",
            authority: "Meteorologisk institutt (MET)",
            title: "Ekstremværvarsler og andre farevarsler",
            url: officialURL("https://www.met.no/vaer-og-klima/ekstremvaervarsler-og-andre-farevarsler"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "met-norway-metalerts-2",
            authority: "Meteorologisk institutt (MET Norway)",
            title: "MetAlerts 2.0 API",
            url: officialURL("https://api.met.no/weatherapi/metalerts/2.0/documentation"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "nve-hazard-information",
            authority: "Norges vassdrags- og energidirektorat (NVE)",
            title: "Naturfare",
            url: officialURL("https://www.nve.no/naturfare/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: PaymentPreparednessCatalog.norwaySourceID,
            authority: "Norges Bank / Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Eigenberedskap for betalinger",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/eigenberedskap-for-betalingar/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        )
    ]

    /// Compatibility aliases preserve source identifiers shipped before the
    /// centralized registry without duplicating metadata in templates.
    static let aliases: [String: String] = [
        "dsb-preparedness": "dsb-self-preparedness",
        "dsb-evacuation": "dsb-crisis-locations",
        "nve-natural-hazards": "nve-hazard-information"
    ]

    /// IDs intentionally left without attribution until an official source is verified.
    static let pendingSourceIDs: Set<String> = []

    static func source(for sourceID: String) -> GuidanceSource? {
        let resolvedID = aliases[sourceID] ?? sourceID
        return norway.first { $0.id == resolvedID }
    }

    static func resolvedSources(for sourceIDs: [String]) -> [GuidanceSource] {
        var seenIDs = Set<String>()
        return sourceIDs.compactMap { sourceID in
            guard let source = source(for: sourceID), seenIDs.insert(source.id).inserted else {
                return nil
            }
            return source
        }
    }

    private static let reviewedDate: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 1)) ?? .distantPast
    }()

    private static func officialURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid bundled official source URL: \(value)")
        }
        return url
    }
}
