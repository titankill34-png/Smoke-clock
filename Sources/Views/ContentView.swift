import Charts
import SwiftUI

struct ContentView: View {
    @Environment(SmokeStore.self) private var store
    @State private var selectedTab: Tab = .timer

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
                analyticsCard("Average gap today", averageGapTodayText)
                analyticsCard("Best day", bestDayText)
                analyticsCard("7-day trend", trendText)
            }

            // Real cigarette count per day, last 14 days
            VStack(spacing: 12) {
                Text("Cigarettes per day (14d)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if store.log.isEmpty {
                    Text("ยังไม่มีข้อมูล")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, minHeight: 140)
                } else {
                    Chart(store.dailyCounts(days: 14)) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Count", day.count)
                        )
                        .foregroundStyle(Color.white.opacity(0.55))
                        .cornerRadius(3)
                    }
                    .frame(height: 140)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                            AxisValueLabel(format: .dateTime.day())
                                .foregroundStyle(.gray)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                            AxisValueLabel()
                                .foregroundStyle(.gray)
                        }
                    }
                }
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

            settingRow("Starting gap", "\(Int(store.schedule.baseInterval / 60))m")
            settingRow("Daily increase", "+\(Int(store.schedule.dailyIncrement / 60))m")
            settingRow("Max gap", "\(Int(store.schedule.maxInterval / 3600))h")

            Spacer()

            Button(role: .destructive) {
                store.resetLog()
            } label: {
                Text("Reset log")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
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

    private func settingRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .foregroundStyle(.purple)
                .monospacedDigit()
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }

    private var gapText: String {
        let m = Int(store.currentInterval) / 60
        return m >= 60 ? "\(m / 60)h \(m % 60)m" : "\(m)m"
    }

    private var averageGapTodayText: String {
        guard let gap = store.averageGapToday else {
            return "ยังไม่มีข้อมูล"
        }
        let m = Int(gap) / 60
        return m >= 60 ? "\(m / 60)h \(m % 60)m" : "\(m)m"
    }

    private var bestDayText: String {
        guard let best = store.bestDay else {
            return "ยังไม่มีข้อมูล"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: best.date)) · \(best.count)"
    }

    private var trendText: String {
        guard let trend = store.weekOverWeekTrend else {
            return "ยังไม่มีข้อมูล"
        }
        let sign = trend > 0 ? "+" : ""
        return "\(sign)\(Int(trend.rounded()))%"
    }
}

#Preview {
    ContentView()
        .environment(SmokeStore())
}
