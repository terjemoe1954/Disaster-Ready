import Foundation

enum GuidanceSourceRegistry {
    static let norway: [GuidanceSource] = [
        GuidanceSource(
            id: "dsb-preparedness",
            authority: "Direktoratet for samfunnssikkerhet og beredskap (DSB)",
            title: "Egenberedskap",
            url: officialURL("https://www.dsb.no/sikkerhverdag/egenberedskap/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "met-weather-warnings",
            authority: "Meteorologisk institutt (MET)",
            title: "Vær og farevarsler",
            url: officialURL("https://www.met.no/en/weather-and-climate"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        ),
        GuidanceSource(
            id: "nve-natural-hazards",
            authority: "Norges vassdrags- og energidirektorat (NVE)",
            title: "Naturfare, flom og skred",
            url: officialURL("https://www.nve.no/naturfare/"),
            countryCode: "NO",
            lastReviewed: reviewedDate
        )
    ]

    private static let reviewedDate: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: 9, day: 30)) ?? .distantPast
    }()

    private static func officialURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid bundled official source URL: \(value)")
        }
        return url
    }
}
