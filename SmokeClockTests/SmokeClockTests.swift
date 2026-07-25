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

    func testDailyCountsGroupsLogByDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let store = SmokeStore(log: [
            yesterday.addingTimeInterval(60 * 60),
            yesterday.addingTimeInterval(2 * 60 * 60),
            today.addingTimeInterval(30 * 60)
        ])

        let counts = store.dailyCounts(days: 3, referenceDate: today)
        XCTAssertEqual(counts.count, 3)
        XCTAssertEqual(counts.last?.date, today)
        XCTAssertEqual(counts.last?.count, 1)
        XCTAssertEqual(counts[counts.count - 2].date, yesterday)
        XCTAssertEqual(counts[counts.count - 2].count, 2)
    }

    func testAverageGapTodayNilWithFewerThanTwoSmokes() {
        let store = SmokeStore(log: [Date()])
        XCTAssertNil(store.averageGapToday)
    }

    func testAverageGapTodayComputesRealGap() {
        let now = Date()
        let store = SmokeStore(log: [
            now.addingTimeInterval(-40 * 60),
            now.addingTimeInterval(-20 * 60),
            now
        ])
        XCTAssertEqual(store.averageGapToday ?? 0, 20 * 60, accuracy: 1)
    }

    func testBestDayNilWhenLogEmpty() {
        let store = SmokeStore(log: [])
        XCTAssertNil(store.bestDay)
    }

    func testBestDayPicksFewestSmokes() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let store = SmokeStore(log: [
            yesterday.addingTimeInterval(60 * 60),
            today.addingTimeInterval(30 * 60),
            today.addingTimeInterval(60 * 60)
        ])

        XCTAssertEqual(store.bestDay?.date, yesterday)
        XCTAssertEqual(store.bestDay?.count, 1)
    }

    func testWeekOverWeekTrendNilWithoutEnoughHistory() {
        let store = SmokeStore(log: [Date()])
        XCTAssertNil(store.weekOverWeekTrend)
    }

    func testWeekOverWeekTrendComputesPercentChange() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var log: [Date] = []

        // Previous week (days -13...-7): 4 smokes on day -13.
        let previousWeekDay = calendar.date(byAdding: .day, value: -13, to: today)!
        log.append(contentsOf: (0..<4).map { previousWeekDay.addingTimeInterval(Double($0) * 3600) })

        // Recent week (days -6...0): 2 smokes today.
        log.append(contentsOf: (0..<2).map { today.addingTimeInterval(Double($0) * 3600) })

        let store = SmokeStore(log: log)
        XCTAssertEqual(store.weekOverWeekTrend ?? 0, -50, accuracy: 0.01)
    }
}
