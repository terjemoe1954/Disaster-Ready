import Foundation

enum DrillCompletionStore {
    private static let storageKey = "drillCompletionDates"
    static let didChangeNotification = Notification.Name("DrillCompletionStoreDidChange")

    static func load() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let dates = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return dates
    }

    static func save(_ dates: [String: Date]) {
        guard let data = try? JSONEncoder().encode(dates) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
}
