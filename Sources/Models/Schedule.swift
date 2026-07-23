import Foundation

/// A tapering plan: the required gap between smokes grows a little each day,
/// starting at `baseInterval` and never exceeding `maxInterval`.
struct Schedule {
    /// Starting gap between smokes on day 0.
    var baseInterval: TimeInterval
    /// How much the gap grows for each day on the taper.
    var dailyIncrement: TimeInterval
    /// Upper bound the gap is clamped to.
    var maxInterval: TimeInterval
    /// Midnight of the day the taper began.
    var startDate: Date

    init(
        baseInterval: TimeInterval = 45 * 60,
        dailyIncrement: TimeInterval = 5 * 60,
        maxInterval: TimeInterval = 4 * 3600,
        startDate: Date = Calendar.current.startOfDay(for: Date())
    ) {
        self.baseInterval = baseInterval
        self.dailyIncrement = dailyIncrement
        self.maxInterval = maxInterval
        self.startDate = startDate
    }

    /// Zero-based count of whole days since the taper began.
    func dayIndex(for date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        return max(0, days)
    }

    /// Required gap between smokes on the taper day containing `date`.
    func interval(for date: Date) -> TimeInterval {
        let raw = baseInterval + dailyIncrement * Double(dayIndex(for: date))
        return min(raw, maxInterval)
    }
}
