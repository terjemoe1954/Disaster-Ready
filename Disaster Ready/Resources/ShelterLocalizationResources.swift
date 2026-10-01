import Foundation

enum ShelterLocalizationResources {
    static let all: [LocalizedStringResource] = [
        LocalizedStringResource("shelter_reference.title", defaultValue: "Public civil-defence shelters", comment: "Title for the official Norwegian public shelter reference feature"),
        LocalizedStringResource("shelter_reference.safety", defaultValue: "Public civil-defence shelters are intended for situations where authorities instruct the population to use them. A nearby shelter is not automatically the correct place to go. Follow current instructions from Norwegian authorities.", comment: "Prominent safety-critical shelter explanation"),
        LocalizedStringResource("shelter_reference.not_live", defaultValue: "This is official reference data, not live information about whether a shelter is open, ready, or has available capacity.", comment: "Explains that register data is not a live shelter status"),
        LocalizedStringResource("shelter_reference.manual.title", defaultValue: "Search the official register", comment: "Heading for manual shelter lookup without location permission"),
        LocalizedStringResource("shelter_reference.manual.detail", defaultValue: "Search an official address or shelter number. No location permission is needed.", comment: "Description for manual official-register search"),
        LocalizedStringResource("shelter_reference.manual.placeholder", defaultValue: "Address or shelter number", comment: "Manual shelter register search field placeholder"),
        LocalizedStringResource("shelter_reference.search", defaultValue: "Search official shelter data", comment: "Button and VoiceOver label for manual shelter search"),
        LocalizedStringResource("shelter_reference.location.title", defaultValue: "Public shelters nearby", comment: "Heading for optional nearby lookup"),
        LocalizedStringResource("shelter_reference.location.detail", defaultValue: "Your location is used once on this device to calculate approximate distances. It is not stored or sent with the shelter-data request.", comment: "Privacy explanation for one-shot location lookup"),
        LocalizedStringResource("shelter_reference.location.button", defaultValue: "Use my location", comment: "Explicit action that triggers location permission and one-shot lookup"),
        LocalizedStringResource("shelter_reference.location.permission_error", defaultValue: "Location is unavailable or permission was not granted. You can still search the official register manually.", comment: "Location permission failure with manual alternative"),
        LocalizedStringResource("shelter_reference.location.error", defaultValue: "Your location could not be obtained. You can still search the official register manually.", comment: "One-shot location lookup failure"),
        LocalizedStringResource("shelter_reference.no_results", defaultValue: "No matching registered public shelters were found. The register may not cover every location.", comment: "Empty result for official shelter register"),
        LocalizedStringResource("shelter_reference.unavailable", defaultValue: "Shelter reference data is unavailable and no cached copy exists. Try again when a network connection is available.", comment: "Offline state when no official shelter cache exists"),
        LocalizedStringResource("shelter_reference.cached", defaultValue: "Cached shelter information — last refreshed %@", comment: "Cached dataset label; placeholder is local date and time"),
        LocalizedStringResource("shelter_reference.refreshed", defaultValue: "Shelter information refreshed %@", comment: "Successful dataset download time; placeholder is local date and time"),
        LocalizedStringResource("shelter_reference.dataset_date", defaultValue: "Official dataset extraction: %@", comment: "Dataset-provided extraction date; separate from guidance review date"),
        LocalizedStringResource("shelter_reference.room", defaultValue: "Shelter number %@", comment: "Official shelter room number; placeholder is the source value"),
        LocalizedStringResource("shelter_reference.unnamed", defaultValue: "Registered public shelter", comment: "Neutral label when official data contains no name or address"),
        LocalizedStringResource("shelter_reference.capacity", defaultValue: "Registered capacity: %lld", comment: "Official registered capacity, not live available space"),
        LocalizedStringResource("shelter_reference.distance", defaultValue: "Approximate distance: %@", comment: "On-device straight-line distance label"),
        LocalizedStringResource("shelter_reference.distance_notice", defaultValue: "Distance is approximate. The nearest entry is not a recommendation or an instruction to travel there.", comment: "Safety explanation for distance-sorted shelter results"),
        LocalizedStringResource("shelter_reference.view_map", defaultValue: "View on map", comment: "Neutral button that opens a shelter coordinate in Maps without routing"),
        LocalizedStringResource("shelter_reference.official_data", defaultValue: "Official shelter data", comment: "Attribution label for DSB Geonorge records"),
        LocalizedStringResource("shelter_reference.source_section", defaultValue: "Official data and guidance", comment: "Heading above source attribution cards"),
        LocalizedStringResource("shelter_reference.myplan.button", defaultValue: "View public civil-defence shelters", comment: "Neutral My Plan link shown only for war or security incident"),
        LocalizedStringResource("shelter_reference.myplan.detail", defaultValue: "Reference information only. Current authority instructions determine whether and when shelters should be used.", comment: "Authority-first explanation beside My Plan shelter link")
    ]
}
