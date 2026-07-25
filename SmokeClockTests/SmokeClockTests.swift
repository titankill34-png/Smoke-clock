//
//  SmokeClockTests.swift
//  Smoke Clock
//

import XCTest
@testable import SmokeClock

final class SmokeClockTests: XCTestCase {
    private var fileURL: URL!

    override func setUpWithError() throws {
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("smokestore-test-\(UUID().uuidString).json")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testPersistsAndReloadsLogAndSchedule() throws {
        let schedule = Schedule(
            baseInterval: 30 * 60,
            dailyIncrement: 10 * 60,
            maxInterval: 6 * 3600,
            startDate: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let store = SmokeStore(fileURL: fileURL)
        store.schedule = schedule
        store.logSmoke()
        store.logSmoke()

        let expectedLog = store.log
        XCTAssertEqual(expectedLog.count, 2)

        // A fresh store pointed at the same file must recover the same state.
        let reloaded = SmokeStore(fileURL: fileURL)
        XCTAssertEqual(reloaded.log, expectedLog)
        XCTAssertEqual(reloaded.schedule, schedule)
        XCTAssertEqual(reloaded.schedule.baseInterval, 30 * 60)
        XCTAssertEqual(reloaded.schedule.dailyIncrement, 10 * 60)
        XCTAssertEqual(reloaded.schedule.maxInterval, 6 * 3600)
        XCTAssertEqual(reloaded.schedule.startDate, schedule.startDate)
    }

    func testResetLogPersists() throws {
        let store = SmokeStore(fileURL: fileURL)
        store.logSmoke()
        store.resetLog()

        let reloaded = SmokeStore(fileURL: fileURL)
        XCTAssertTrue(reloaded.log.isEmpty)
    }

    func testMissingFileFallsBackToDefaults() throws {
        // fileURL does not exist yet.
        let store = SmokeStore(fileURL: fileURL)
        XCTAssertTrue(store.log.isEmpty)
        XCTAssertEqual(store.schedule, Schedule())
    }

    func testCorruptFileFallsBackToDefaultsWithoutCrashing() throws {
        try Data("not valid json{".utf8).write(to: fileURL)

        let store = SmokeStore(fileURL: fileURL)
        XCTAssertTrue(store.log.isEmpty)
        XCTAssertEqual(store.schedule, Schedule())
    }
}
