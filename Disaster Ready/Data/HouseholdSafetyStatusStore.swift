import Foundation

enum HouseholdSafetyStatus: String, Codable, CaseIterable, Identifiable {
    case notChecked
    case safe
    case needsHelp
    case unreachable

    var id: String { rawValue }
}

struct HouseholdSafetySnapshot: Codable, Equatable {
    var statuses: [String: HouseholdSafetyStatus]
    var updatedAt: Date?

    static let empty = HouseholdSafetySnapshot(statuses: [:], updatedAt: nil)
}

enum HouseholdSafetyStatusStore {
    private static let storageKey = "householdSafetySnapshot"

    static func load() -> HouseholdSafetySnapshot {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(HouseholdSafetySnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }

    static func save(_ snapshot: HouseholdSafetySnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
