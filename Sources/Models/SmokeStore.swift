import Foundation
import Observation

/// Observable state backing the app: the log of smokes plus the taper schedule.
@Observable
final class SmokeStore {
    /// Every logged smoke, oldest first.
    private(set) var log: [Date]
    /// The active taper plan.
    var schedule: Schedule

    init(schedule: Schedule = Schedule(), log: [Date] = []) {
        self.schedule = schedule
        self.log = log
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

    /// Record a smoke at the current moment.
    func logSmoke() {
        log.append(Date())
    }

    /// Clear the entire log.
    func resetLog() {
        log.removeAll()
    }
}
