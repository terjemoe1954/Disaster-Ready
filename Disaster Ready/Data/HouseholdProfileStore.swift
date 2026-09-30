import Foundation

enum HouseholdProfileStore {
    static let storageKey = "householdProfile.v1"
    static let legacyHouseholdSizeKey = "householdMemberCount"

    static func load(
        defaults: UserDefaults = .standard,
        locale: Locale = .current
    ) -> HouseholdProfile {
        if
            let data = defaults.data(forKey: storageKey),
            let profile = try? JSONDecoder().decode(HouseholdProfile.self, from: data)
        {
            return profile
        }

        let legacySize = defaults.object(forKey: legacyHouseholdSizeKey) as? Int ?? 1
        let profile = HouseholdProfile.defaultProfile(
            locale: locale,
            householdSize: legacySize
        )
        save(profile, defaults: defaults)
        return profile
    }

    static func save(
        _ profile: HouseholdProfile,
        defaults: UserDefaults = .standard
    ) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: storageKey)

        // Keep the 1.0.1 setting synchronized until all released versions have
        // passed through the profile migration.
        defaults.set(profile.householdSize, forKey: legacyHouseholdSizeKey)
    }
}
