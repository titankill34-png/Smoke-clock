import SwiftUI

struct ContentView: View {
    @Environment(SmokeStore.self) private var store
    @State private var selectedTab: Tab = .timer
    @State private var showResetConfirmation = false

    enum Tab { case timer, analytics, settings }

    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.18),
                    Color(red: 0.12, green: 0.08, blue: 0.20)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab header
                HStack(spacing: 0) {
                    tabButton("Timer", .timer)
                    tabButton("Analytics", .analytics)
                    tabButton("Settings", .settings)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Content
                ZStack {
                    if selectedTab == .timer {
                        timerTab
                    } else if selectedTab == .analytics {
                        analyticsTab
                    } else {
                        settingsTab
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Tabs

    private var timerTab: some View {
        VStack(spacing: 24) {
            Spacer()

            // Countdown card with glow
            VStack(spacing: 16) {
                CountdownView(target: store.nextAllowed)
                    .padding(.vertical, 32)

                HStack(spacing: 20) {
                    statCard("Today", "\(store.smokedToday)")
                    statCard("Gap", gapText)
                    statCard("Day", "\(store.schedule.dayIndex(for: Date()))")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.15, green: 0.12, blue: 0.25),
                                Color(red: 0.12, green: 0.15, blue: 0.22)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 10)
            )

            Button {
                store.logSmoke()
            } label: {
                Text("Log one")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.7, green: 0.3, blue: 0.8),
                                Color(red: 0.5, green: 0.2, blue: 0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }

            Spacer()
        }
    }

    private var analyticsTab: some View {
        VStack(spacing: 20) {
            Text("Analytics")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Stat cards
            VStack(spacing: 12) {
                analyticsCard("Total logged", "\(store.log.count)")
                analyticsCard("Current interval", gapText)
                analyticsCard("Days on taper", "\(store.schedule.dayIndex(for: Date()))")
            }

            // Mock graph
            VStack(spacing: 12) {
                Text("Gap progression")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Canvas { context, size in
                    let height: CGFloat = 100
                    let width = size.width

                    for i in 0..<7 {
                        let x = width * CGFloat(i) / 6
                        let yValue = CGFloat(i) * 0.15 // mock progression
                        let y = height * (1 - yValue)

                        var path = Path()
                        path.addEllipse(in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                        context.fill(path, with: .color(Color.purple))
                    }
                }
                .frame(height: 100)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.03))
            )

            Spacer()
        }
    }

    private var settingsTab: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            settingStepperRow(
                label: "Starting gap",
                value: startingGapBinding,
                range: 15...180,
                step: 5
            ) { "\($0)m" }

            settingStepperRow(
                label: "Daily increase",
                value: dailyIncreaseBinding,
                range: 0...30,
                step: 1
            ) { "+\($0)m" }

            settingStepperRow(
                label: "Max gap",
                value: maxGapBinding,
                range: 1...12,
                step: 1
            ) { "\($0)h" }

            Button {
                store.schedule.startDate = Calendar.current.startOfDay(for: Date())
            } label: {
                Text("เริ่มนับใหม่วันนี้")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(.purple)

            Spacer()

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Text("Reset log")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                "Reset log?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset log", role: .destructive) {
                    store.resetLog()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes every logged smoke. This can't be undone.")
            }
        }
    }

    // MARK: - Settings bindings

    private var startingGapBinding: Binding<Int> {
        Binding(
            get: { Int(store.schedule.baseInterval / 60) },
            set: { store.schedule.baseInterval = TimeInterval($0) * 60 }
        )
    }

    private var dailyIncreaseBinding: Binding<Int> {
        Binding(
            get: { Int(store.schedule.dailyIncrement / 60) },
            set: { store.schedule.dailyIncrement = TimeInterval($0) * 60 }
        )
    }

    private var maxGapBinding: Binding<Int> {
        Binding(
            get: { Int(store.schedule.maxInterval / 3600) },
            set: { store.schedule.maxInterval = TimeInterval($0) * 3600 }
        )
    }

    // MARK: - Components

    private func tabButton(_ label: String, _ tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selectedTab == tab ? .white : .gray)

                if selectedTab == tab {
                    Capsule()
                        .fill(Color.purple)
                        .frame(height: 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statCard(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func analyticsCard(_ label: String, _ value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func settingStepperRow(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int,
        formatter: @escaping (Int) -> String
    ) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            Stepper(value: value, in: range, step: step) {
                Text(formatter(value.wrappedValue))
                    .foregroundStyle(.purple)
                    .monospacedDigit()
            }
            .fixedSize()
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }

    private var gapText: String {
        let m = Int(store.currentInterval) / 60
        return m >= 60 ? "\(m / 60)h \(m % 60)m" : "\(m)m"
    }
}

#Preview {
    ContentView()
        .environment(SmokeStore())
}
