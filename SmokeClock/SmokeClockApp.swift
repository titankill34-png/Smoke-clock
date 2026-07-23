//
//  SmokeClockApp.swift
//  Smoke Clock
//

import SwiftUI

@main
struct SmokeClockApp: App {
    @State private var store = SmokeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
