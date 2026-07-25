import Foundation
import Observation

/// Observable state backing the app: the log of smokes plus the taper schedule.
///
/// State is persisted to a JSON file in the Documents directory so it survives
/// app restarts. The file is loaded on init and rewritten on every mutation.
@Observable
final class SmokeStore {
    /// Every logged smoke, oldest first.
    private(set) var log: [Date] {
        didSet { save() }
    }
    /// The active taper plan.
    var schedule: Schedule {
        didSet { save() }
    }

    /// Where state is persisted. Injectable so tests can use a temp file.
    @ObservationIgnored private let fileURL: URL

    init(fileURL: URL = SmokeStore.defaultFileURL) {
        self.fileURL = fileURL
        // Load persisted state; fall back to defaults on missing or corrupt data.
        if let snapshot = SmokeStore.loadSnapshot(from: fileURL) {
            self.schedule = snapshot.schedule
            self.log = snapshot.log
        } else {
            self.schedule = Schedule()
            self.log = []
        }
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

    // MARK: - Persistence

    /// The serializable shape of the store's state.
    private struct Snapshot: Codable {
        var log: [Date]
        var schedule: Schedule
    }

    /// Default persistence location: `smokestore.json` in the Documents directory.
    static var defaultFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("smokestore.json")
    }

    /// Load a snapshot from disk, returning `nil` if the file is missing or corrupt.
    private static func loadSnapshot(from url: URL) -> Snapshot? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    /// Persist the current state. Failures are swallowed so a write error never crashes the app.
    private func save() {
        let snapshot = Snapshot(log: log, schedule: schedule)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
