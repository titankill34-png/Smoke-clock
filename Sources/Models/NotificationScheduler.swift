import Foundation
import UserNotifications

/// Abstraction over local-notification scheduling so `SmokeStore` stays testable
/// without touching `UNUserNotificationCenter`.
protocol SmokeNotifying {
    func requestAuthorization()
    func scheduleNext(at date: Date, gapMinutes: Int)
    func cancelAll()
}

/// Schedules the single "time is up" local notification.
///
/// Local notifications only — no push. KSign cannot sign the push entitlement,
/// so `UNUserNotificationCenter` with an `UNTimeIntervalNotificationTrigger` is
/// the only mechanism used here.
final class NotificationScheduler: SmokeNotifying {
    /// Stable identifier so a fresh schedule always replaces the pending one
    /// instead of stacking duplicates.
    static let identifier = "dev.titankill34.smokeclock.nextAllowed"

    private let center = UNUserNotificationCenter.current()

    /// Ask for alert/sound permission. Safe to call on every launch.
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Cancel any pending "time is up" notification, then schedule a new one at
    /// `date`. A non-future `date` cancels only (nothing to fire).
    func scheduleNext(at date: Date, gapMinutes: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])

        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "ครบเวลาแล้ว"
        content.body = "เว้นไป \(gapMinutes) นาทีแล้ว สูบได้เลย"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier, content: content, trigger: trigger)
        center.add(request)
    }

    /// Remove every pending notification.
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
