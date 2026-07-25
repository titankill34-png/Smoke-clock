import Foundation
import Observation

/// Observable state backing the app: the log of smokes plus the taper schedule.
@Observable
final class SmokeStore {
    /// Every logged smoke, oldest first.
    private(set) var log: [Date]
    /// The active taper plan.
    var schedule: Schedule
    /// Drives local notifications; kept separate from the store's own logic.
    var notifier: SmokeNotifying?

    init(schedule: Schedule = Schedule(), log: [Date] = [], notifier: SmokeNotifying? = nil) {
        self.schedule = schedule
        self.log = log
        self.notifier = notifier
    }

    /// Required gap between smokes for today's taper day.
    var currentInterval: TimeInterval {
        schedule.interval(for: Date())
    }

    /// The most recently logged smoke, if any.
    var lastSmoke: Date? {
        log.last
    }

    /// When the next smoke becomes allowed: last smoke + current interval.
    /// `nil` until the first smoke is logged.
    var nextAllowed: Date? {
        guard let last = lastSmoke else { return nil }
        return last.addingTimeInterval(currentInterval)
    }

    /// Number of smokes logged since midnight today.
    var smokedToday: Int {
        let start = Calendar.current.startOfDay(for: Date())
        return log.filter { $0 >= start }.count
    }

    /// Record a smoke at the current moment and (re)schedule the reminder.
    func logSmoke() {
        log.append(Date())
        if let next = nextAllowed {
            notifier?.scheduleNext(at: next, gapMinutes: Int(currentInterval) / 60)
        }
    }

    /// Clear the entire log and drop any pending reminder.
    func resetLog() {
        log.removeAll()
        notifier?.cancelAll()
    }
}
