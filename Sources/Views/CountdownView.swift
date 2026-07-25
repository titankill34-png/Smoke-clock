import SwiftUI

struct CountdownView: View {
    let target: Date?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = target.map { $0.timeIntervalSince(context.date) } ?? 0

            VStack(spacing: 12) {
                Text(remaining > 0 ? format(remaining) : "0:00:00")
                    .font(.system(size: 84, weight: .black, design: .default))
                    .monospacedDigit()
                    .tracking(-3)
                    .contentTransition(.numericText())
                    .foregroundStyle(Color(hex: 0xF4F5F6))

                Text(remaining > 0 ? "UNTIL NEXT" : "GAP COMPLETE")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(2.5)
                    .foregroundStyle(Color(hex: 0x8B8F96))
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
