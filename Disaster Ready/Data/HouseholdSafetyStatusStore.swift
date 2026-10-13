import Foundation

enum HouseholdSafetyStatus: String, Codable, CaseIterable, Identifiable {
    case notChecked
    case safe
    case needsHelp
    case unreachable

    var id: String { rawValue }
}

struct HouseholdSafetySnapshot: Codable {
    var statuses: [String: HouseholdSafetyStatus]
    var updatedAt: Date?
}

enum HouseholdSafetyStatusStore {
    private static let storageKey = "householdSafetySnapshot"

    static func load() -> HouseholdSafetySnapshot {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(HouseholdSafetySnapshot.self, from: data) else {
            return HouseholdSafetySnapshot(statuses: [:], updatedAt: nil)
        }
        return snapshot
    }

    static func save(_ snapshot: HouseholdSafetySnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
