import Foundation

enum GuidanceSourceRegistry {
    /// A review date records Disaster Ready's comparison of bundled guidance.
    /// It must never be interpreted as a live authority update timestamp.
    static let reviewDateRepresentsLiveUpdate = false
    static let contentVersion = "NO-2026.10.22"

    private static let baseNorway: [GuidanceSource] = [
        GuidanceSource(
            id: "dsb-self-preparedness",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Egenberedskap",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/"),
            countryCode: "NO",
            lastReviewed: reviewedDate,
            contentVersion: contentVersion
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
            id: "dsb-information-communication",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Råd hvis internett og mobilnett ikke virker",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/raad-hvis-mobilnett-og-internett-ikke-virker/"),
            countryCode: "NO",
            lastReviewed: reviewedDate,
            contentVersion: contentVersion
        ),
        GuidanceSource(
            id: "nkom-emergency-calls",
            authority: "Nasjonal kommunikasjonsmyndighet (Nkom)",
            title: "Nødnummer, nødanrop og lokalisering",
            url: officialURL("https://nkom.no/telefoni-og-telefonnummer/nodnummer-nodanrop-og-lokalisering"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "kartverket-space-weather",
            authority: "Kartverket",
            title: "Romvær og posisjonstjenester",
            url: officialURL("https://sesolstorm.kartverket.no/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "norwegian-space-agency-space-weather",
            authority: "Direktoratet for romvirksomhet",
            title: "Det farlige romværet",
            url: officialURL("https://www.romsenter.no/laer-om-romvirksomhet/det-farlige-romvaeret"),
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
        ),
        GuidanceSource(
            id: "no-emergency-fire-110",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "110-sentralene",
            url: officialURL("https://www.dsb.no/brannsikkerhet/nodmelding/110-sentralene/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "no-emergency-police-112",
            authority: "Politiet",
            title: "Ring politiet",
            url: officialURL("https://www.politiet.no/kontakt-politiet/ring-politiet"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "no-medical-numbers",
            authority: "Helsenorge / Helsedirektoratet",
            title: "Legevakt og medisinsk nødhjelp",
            url: officialURL("https://www.helsenorge.no/hjelpetilbud-i-kommunene/legevakt/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        )
    ]

    static let norway: [GuidanceSource] = baseNorway.map { source in
        GuidanceSource(
            id: source.id,
            authority: source.authority,
            title: source.title,
            url: source.url,
            countryCode: source.countryCode,
            lastReviewed: source.lastReviewed,
            contentVersion: source.contentVersion ?? contentVersion
        )
    }

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
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 22)) ?? .distantPast
    }()

    private static func officialURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid bundled official source URL: \(value)")
        }
        return url
    }
}
