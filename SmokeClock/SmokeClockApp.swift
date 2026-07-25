//
//  SmokeClockApp.swift
//  Smoke Clock
//

import SwiftUI

@main
struct SmokeClockApp: App {
    @State private var store: SmokeStore

    init() {
        let scheduler = NotificationScheduler()
        scheduler.requestAuthorization()
        _store = State(initialValue: SmokeStore(notifier: scheduler))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
