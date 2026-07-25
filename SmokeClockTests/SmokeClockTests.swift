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

    func testEditingScheduleTakesEffectImmediately() throws {
        let store = SmokeStore(schedule: Schedule(baseInterval: 45 * 60))
        store.schedule.baseInterval = 20 * 60
        XCTAssertEqual(store.currentInterval, 20 * 60)
    }

    func testRestartingTodayResetsDayIndexToZero() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let store = SmokeStore(schedule: Schedule(startDate: Calendar.current.startOfDay(for: yesterday)))
        XCTAssertGreaterThan(store.schedule.dayIndex(for: Date()), 0)

        store.schedule.startDate = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(store.schedule.dayIndex(for: Date()), 0)
    }
}
