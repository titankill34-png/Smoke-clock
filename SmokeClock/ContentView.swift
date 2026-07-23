//
//  ContentView.swift
//  Smoke Clock
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .imageScale(.large)
                .font(.system(size: 48))
            Text("Smoke Clock")
                .font(.title2)
                .bold()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
