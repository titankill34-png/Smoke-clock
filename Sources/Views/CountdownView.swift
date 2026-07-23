import SwiftUI

struct CountdownView: View {
    let target: Date?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = target.map { $0.timeIntervalSince(context.date) } ?? 0

            VStack(spacing: 12) {
                Text(remaining > 0 ? format(remaining) : "0:00:00")
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.5, blue: 1.0),
                                Color(red: 0.7, green: 0.3, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 0)

                Text(remaining > 0 ? "until next" : "gap complete")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
    }

    private func format(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.up))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%d:%02d:%02d", h, m, s)
    }
}
