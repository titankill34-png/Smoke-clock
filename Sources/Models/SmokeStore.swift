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

    // MARK: - Analytics

    /// Number of smokes logged on each of the last `days` days, oldest first, including today.
    func dailyCounts(days: Int, referenceDate: Date = Date()) -> [DailyCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        return (0..<days).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let count = log.filter { $0 >= day && $0 < next }.count
            return DailyCount(date: day, count: count)
        }
    }

    /// Average gap between smokes logged today, from the real log. `nil` until
    /// at least two smokes have been logged today.
    var averageGapToday: TimeInterval? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let todays = log.filter { $0 >= start }.sorted()
        guard todays.count >= 2 else { return nil }
        let gaps = zip(todays, todays.dropFirst()).map { $1.timeIntervalSince($0) }
        return gaps.reduce(0, +) / Double(gaps.count)
    }

    /// The day with the fewest logged smokes, among days that have at least one entry.
    /// `nil` if the log is empty.
    var bestDay: DailyCount? {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: log) { calendar.startOfDay(for: $0) }
        guard let best = grouped.min(by: { $0.value.count < $1.value.count }) else { return nil }
        return DailyCount(date: best.key, count: best.value.count)
    }

    /// Percent change in smokes logged over the last 7 days versus the 7 days before that.
    /// Negative means fewer smokes (improvement). `nil` if there isn't at least 14 days
    /// of log history, or the prior week has no smokes to compare against.
    var weekOverWeekTrend: Double? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayTimestamps = log.map { calendar.startOfDay(for: $0) }
        guard let earliest = dayTimestamps.min() else { return nil }
        let historyDays = calendar.dateComponents([.day], from: earliest, to: today).day ?? 0
        guard historyDays >= 13 else { return nil }

        func count(daysAgoStart: Int, daysAgoEnd: Int) -> Int {
            let start = calendar.date(byAdding: .day, value: -daysAgoStart, to: today) ?? today
            let endExclusive = calendar.date(byAdding: .day, value: -daysAgoEnd + 1, to: today) ?? today
            return log.filter { $0 >= start && $0 < endExclusive }.count
        }

        let recent = count(daysAgoStart: 6, daysAgoEnd: 0)
        let previous = count(daysAgoStart: 13, daysAgoEnd: 7)
        guard previous > 0 else { return nil }
        return (Double(recent) - Double(previous)) / Double(previous) * 100
    }
}

/// Number of smokes logged on a given day.
struct DailyCount: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}
