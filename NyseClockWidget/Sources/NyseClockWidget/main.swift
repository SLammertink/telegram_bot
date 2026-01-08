import SwiftUI

private enum MarketStatus {
    case open
    case closed

    var label: String {
        switch self {
        case .open:
            return "Open"
        case .closed:
            return "Closed"
        }
    }

    var color: Color {
        switch self {
        case .open:
            return Color(red: 0.12, green: 0.91, blue: 0.44)
        case .closed:
            return Color(red: 1.0, green: 0.42, blue: 0.42)
        }
    }
}

private struct MarketClock {
    private let calendar: Calendar
    private let formatter: DateFormatter

    init() {
        var nyCalendar = Calendar(identifier: .gregorian)
        nyCalendar.timeZone = TimeZone(identifier: "America/New_York") ?? .current
        calendar = nyCalendar

        formatter = DateFormatter()
        formatter.timeZone = nyCalendar.timeZone
        formatter.dateFormat = "HH:mm:ss"
    }

    func formattedTime(from date: Date) -> String {
        formatter.string(from: date)
    }

    func status(for date: Date) -> MarketStatus {
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        guard let weekday = components.weekday,
              let hour = components.hour,
              let minute = components.minute else {
            return .closed
        }

        if weekday == 1 || weekday == 7 {
            return .closed
        }

        let minutes = hour * 60 + minute
        let openMinutes = 9 * 60 + 30
        let closeMinutes = 16 * 60

        return minutes >= openMinutes && minutes < closeMinutes ? .open : .closed
    }
}

struct ContentView: View {
    @State private var currentTime = "--:--:--"
    @State private var status: MarketStatus = .closed

    private let clock = MarketClock()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.14, green: 0.16, blue: 0.22), Color(red: 0.04, green: 0.05, blue: 0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Market")
                            .font(.caption2)
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("NYSE Clock")
                            .font(.title2.weight(.semibold))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(status.color)
                            .frame(width: 10, height: 10)
                            .shadow(color: status.color.opacity(0.6), radius: 8, x: 0, y: 0)
                        Text(status.label.uppercased())
                            .font(.caption.weight(.semibold))
                            .tracking(2)
                            .foregroundStyle(status.color)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.12))
                    .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(currentTime)
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .tracking(3)
                    Text("Eastern Time (New York)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Text("Session: 9:30 AM – 4:00 PM ET")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 20)
            .frame(width: 340)
        }
        .onAppear(perform: update)
        .onReceive(timer) { _ in
            update()
        }
    }

    private func update() {
        let now = Date()
        currentTime = clock.formattedTime(from: now)
        status = clock.status(for: now)
    }
}

@main
struct NyseClockWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 340, minHeight: 240)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
