import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct ContentView: View {
    @Environment(SmokeStore.self) private var store
    @State private var selectedTab: Tab = .timer

    enum Tab { case timer, analytics, settings }

    private let bgTop = Color(hex: 0x1E1F22)
    private let bgBottom = Color(hex: 0x17181A)
    private let textPrimary = Color(hex: 0xF4F5F6)
    private let textDim = Color(hex: 0x8B8F96)
    private let cardFill = Color(hex: 0x202225)
    private let cardBorder = Color(hex: 0x2C2E33)
    private let inactive = Color(hex: 0x5F636A)
    private let buttonText = Color(hex: 0x17181A)

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [bgTop, bgBottom]),
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

                Rectangle()
                    .fill(cardBorder)
                    .frame(height: 1)

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
            sectionHeader(".01", "Timer")

            Spacer()

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
                RoundedRectangle(cornerRadius: 2)
                    .fill(cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(cardBorder, lineWidth: 1)
            )

            Button {
                store.logSmoke()
            } label: {
                Text("LOG ONE")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(buttonText)
                    .background(textPrimary)
                    .cornerRadius(2)
            }

            Spacer()
        }
    }

    private var analyticsTab: some View {
        VStack(spacing: 20) {
            sectionHeader(".02", "Analytics")

            VStack(spacing: 12) {
                analyticsCard("Total logged", "\(store.log.count)")
                analyticsCard("Current interval", gapText)
                analyticsCard("Days on taper", "\(store.schedule.dayIndex(for: Date()))")
            }

            VStack(spacing: 12) {
                Text("GAP PROGRESSION")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(2.5)
                    .foregroundStyle(textDim)
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
                        context.fill(path, with: .color(textPrimary))
                    }
                }
                .frame(height: 100)
                .background(cardFill)
                .cornerRadius(2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(cardBorder, lineWidth: 1)
            )

            Spacer()
        }
    }

    private var settingsTab: some View {
        VStack(spacing: 16) {
            sectionHeader(".03", "Settings")

            settingRow("Starting gap", "\(Int(store.schedule.baseInterval / 60))m")
            settingRow("Daily increase", "+\(Int(store.schedule.dailyIncrement / 60))m")
            settingRow("Max gap", "\(Int(store.schedule.maxInterval / 3600))h")

            Spacer()

            Button {
                store.resetLog()
            } label: {
                Text("RESET LOG")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(textPrimary)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Components

    private func sectionHeader(_ number: String, _ title: String) -> some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(inactive)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(textPrimary)
            Rectangle()
                .fill(cardBorder)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tabButton(_ label: String, _ tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(selectedTab == tab ? .white : inactive)

                Rectangle()
                    .fill(selectedTab == tab ? Color.white : Color.clear)
                    .frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statCard(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundStyle(textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(2.5)
                .foregroundStyle(textDim)
        }
        .frame(maxWidth: .infinity)
    }

    private func analyticsCard(_ label: String, _ value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(2.5)
                    .foregroundStyle(textDim)
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(textPrimary)
                    .monospacedDigit()
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private func settingRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(textPrimary)
            Spacer()
            Text(value)
                .foregroundStyle(textDim)
                .monospacedDigit()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(cardBorder, lineWidth: 1)
        )
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
