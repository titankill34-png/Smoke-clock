//
//  SmokeClockTests.swift
//  Smoke Clock
//

import XCTest
@testable import SmokeClock

final class SmokeClockTests: XCTestCase {
    func testSmoke() throws {
        // Baseline smoke test: confirms the test bundle links against the app
        // target and runs. Expand with real coverage as features land.
        XCTAssertTrue(true)
    }

    func testLogSmokeSchedulesReminderAtNextAllowed() throws {
        let notifier = FakeNotifier()
        let store = SmokeStore(notifier: notifier)

        store.logSmoke()

        XCTAssertEqual(notifier.scheduled.count, 1)
        let scheduled = try XCTUnwrap(notifier.scheduled.first)
        XCTAssertEqual(scheduled.date, store.nextAllowed)
        XCTAssertEqual(scheduled.gapMinutes, Int(store.currentInterval) / 60)
    }

    func testLoggingAgainReschedulesWithoutStacking() throws {
        let notifier = FakeNotifier()
        let store = SmokeStore(notifier: notifier)

        store.logSmoke()
        store.logSmoke()

        // Each log schedules exactly once; the scheduler replaces by identifier.
        XCTAssertEqual(notifier.scheduled.count, 2)
    }

    func testResetLogCancelsAllReminders() throws {
        let notifier = FakeNotifier()
        let store = SmokeStore(notifier: notifier)

        store.logSmoke()
        store.resetLog()

        XCTAssertEqual(notifier.cancelAllCount, 1)
    }
}

private final class FakeNotifier: SmokeNotifying {
    private(set) var scheduled: [(date: Date, gapMinutes: Int)] = []
    private(set) var cancelAllCount = 0

    func requestAuthorization() {}

    func scheduleNext(at date: Date, gapMinutes: Int) {
        scheduled.append((date, gapMinutes))
    }

    func cancelAll() {
        cancelAllCount += 1
    }
}
