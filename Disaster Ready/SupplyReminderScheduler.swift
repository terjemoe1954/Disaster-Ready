import Foundation
import UserNotifications

struct SupplyReviewReminder: Sendable {
    let id: UUID
    let name: String
    let reviewDate: Date
}

enum SupplyReminderScheduler {
    private static let identifierPrefix = "supply-review-"
    private static let testIdentifier = "supply-test-reminder"

    static func requestAuthorizationAndSchedule(
        reminders: [SupplyReviewReminder],
        language: AppLanguage
    ) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        let isAuthorized: Bool
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = try await center.requestAuthorization(options: [.alert, .sound])
        case .denied:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }

        guard isAuthorized else { return false }
        try await replacePendingReminders(reminders, language: language, center: center)
        return true
    }

    static func removePendingReminders() async {
        let center = UNUserNotificationCenter.current()
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func scheduleTestNotification(language: AppLanguage) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral else {
            return false
        }

        let content = UNMutableNotificationContent()
        content.title = L10n.pick(
            language: language,
            english: "Test reminder",
            norwegian: "Testpåminnelse",
            thai: "ทดสอบการแจ้งเตือน"
        )
        content.body = L10n.pick(
            language: language,
            english: "Notifications from Disaster Ready are working.",
            norwegian: "Varslinger fra Disaster Ready fungerer.",
            thai: "การแจ้งเตือนจาก Disaster Ready ทำงานแล้ว"
        )
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: testIdentifier,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
        return true
    }

    private static func replacePendingReminders(
        _ reminders: [SupplyReviewReminder],
        language: AppLanguage,
        center: UNUserNotificationCenter
    ) async throws {
        let existingIdentifiers = Set(
            await center.pendingNotificationRequests()
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }
        )
        let scheduledReminders = reminders.compactMap { reminder -> (SupplyReviewReminder, Date)? in
            guard let deliveryDate = deliveryDate(for: reminder.reviewDate) else { return nil }
            return (reminder, deliveryDate)
        }
        let desiredIdentifiers = Set(scheduledReminders.map { reminderIdentifier(for: $0.0.id) })

        for (reminder, deliveryDate) in scheduledReminders {
            let content = UNMutableNotificationContent()
            content.title = L10n.pick(
                language: language,
                english: "Check your emergency supplies",
                norwegian: "Kontroller beredskapsutstyret",
                thai: "ตรวจสอบอุปกรณ์ฉุกเฉิน"
            )
            content.body = L10n.pick(
                language: language,
                english: "\(reminder.name) should be reviewed or replaced.",
                norwegian: "\(reminder.name) bør kontrolleres eller erstattes.",
                thai: "ควรตรวจสอบหรือเปลี่ยน \(reminder.name)"
            )
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: deliveryDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: reminderIdentifier(for: reminder.id),
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        }

        let staleIdentifiers = Array(existingIdentifiers.subtracting(desiredIdentifiers))
        center.removePendingNotificationRequests(withIdentifiers: staleIdentifiers)
    }

    static func reminderIdentifier(for id: UUID) -> String {
        identifierPrefix + id.uuidString
    }

    static func deliveryDate(
        for reviewDate: Date,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        let reviewDay = calendar.startOfDay(for: reviewDate)
        let today = calendar.startOfDay(for: referenceDate)

        guard reviewDay >= today else { return nil }

        let preferredDate = calendar.date(byAdding: .day, value: -30, to: reviewDay) ?? reviewDay
        let preferredAtNine = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: preferredDate
        ) ?? preferredDate

        if preferredAtNine > referenceDate {
            return preferredAtNine
        }

        return referenceDate.addingTimeInterval(60)
    }
}
