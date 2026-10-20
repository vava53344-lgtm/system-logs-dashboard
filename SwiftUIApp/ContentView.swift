import SwiftUI

enum LogLevel: String, CaseIterable {
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
    case success = "OK"
}

struct LogEntry: Identifiable {
    let id = UUID()
    let time: String
    let source: String
    let level: LogLevel
    let message: String
}

struct BoomBubble: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let duration: Double
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedSource = "all"
    @State private var selectedTheme: Bool = false
    @State private var selectedLevels: Set<LogLevel> = [.info, .warning, .error, .success]
    @State private var boomBubbles: [BoomBubble] = []

    private let logData: [LogEntry] = [
        LogEntry(time: "00:01:12", source: "kernel", level: .info, message: "System clock synchronized with NTP server"),
        LogEntry(time: "00:02:08", source: "api", level: .warning, message: "Rate limit approaching for /v1/metrics"),
        LogEntry(time: "00:03:41", source: "db", level: .success, message: "Daily backup completed successfully"),
        LogEntry(time: "00:04:22", source: "auth", level: .error, message: "Authentication token expired for user 4821"),
        LogEntry(time: "00:06:10", source: "scheduler", level: .info, message: "Queued job sync-customer-index finished without errors"),
        LogEntry(time: "00:08:02", source: "api", level: .success, message: "Deploy healthcheck passed for staging cluster"),
        LogEntry(time: "00:09:02", source: "kernel", level: .warning, message: "Disk usage above 78% on /var/lib"),
        LogEntry(time: "00:11:11", source: "db", level: .error, message: "Connection pool saturation detected on replica-2")
    ]

    private var filteredLogs: [LogEntry] {
        logData.filter { log in
            let levelMatch = selectedLevels.contains(log.level)
            let sourceMatch = selectedSource == "all" || log.source == selectedSource
            let query = searchText.lowercased()
            let textMatch = query.isEmpty || log.message.lowercased().contains(query) || log.source.lowercased().contains(query)
            return levelMatch && sourceMatch && textMatch
        }
    }

    var body: some View {
        ZStack {
            (selectedTheme ? Color.white : Color(red: 11/255, green: 16/255, blue: 32/255))
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("System Logs")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedTheme ? .black : .white)

                    TextField("Filter logs...", text: $searchText)
                        .padding(12)
                        .background(selectedTheme ? Color.black.opacity(0.05) : Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(selectedTheme ? .black : .white)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Levels")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        ForEach(LogLevel.allCases, id: \ .self) { level in
                            Toggle(isOn: Binding(
                                get: { selectedLevels.contains(level) },
                                set: { isOn in
                                    if isOn { selectedLevels.insert(level) } else { selectedLevels.remove(level) }
                                }
                            )) {
                                HStack {
                                    Text(level.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(width: 58, alignment: .leading)
                                        .padding(6)
                                        .background(levelColor(level))
                                        .clipShape(Capsule())
                                    Spacer()
                                }
                            }
                            .toggleStyle(.checkbox)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Source")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Picker("Source", selection: $selectedSource) {
                            Text("All sources").tag("all")
                            Text("Kernel").tag("kernel")
                            Text("API").tag("api")
                            Text("Database").tag("db")
                            Text("Auth").tag("auth")
                            Text("Scheduler").tag("scheduler")
                        }
                        .pickerStyle(.menu)
                    }

                    HStack(spacing: 10) {
                        Button("Dark") { selectedTheme = false }
                            .buttonStyle(.borderedProminent)
                            .tint(selectedTheme ? .gray : .cyan)

                        Button("Light") { selectedTheme = true }
                            .buttonStyle(.borderedProminent)
                            .tint(selectedTheme ? .cyan : .gray)
                    }

                    Button(action: createBoom) {
                        Text("БУМ")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(LinearGradient(colors: [.pink, .red], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(16)
                .frame(width: 300)
                .background(selectedTheme ? Color.gray.opacity(0.06) : Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                VStack(spacing: 0) {
                    HStack {
                        Text("Live Event Stream")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(selectedTheme ? .black : .white)
                        Spacer()
                        HStack(spacing: 8) {
                            Circle().frame(width: 10, height: 10).foregroundColor(.green)
                            Text("\(filteredLogs.count) events")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)

                    if filteredLogs.isEmpty {
                        Spacer()
                        Text("No logs match the current filters.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredLogs) { log in
                                    HStack(alignment: .center, spacing: 14) {
                                        Text(log.time)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80, alignment: .leading)

                                        Text(sourceTitle(log.source))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(selectedTheme ? .black : .white)
                                            .frame(width: 80, alignment: .leading)

                                        Text(log.message)
                                            .font(.system(size: 15))
                                            .foregroundColor(selectedTheme ? .black : .white)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Text(log.level.rawValue)
                                            .font(.system(size: 11, weight: .heavy))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                            .background(levelColor(log.level))
                                            .foregroundColor(levelTextColor(log.level))
                                            .clipShape(Capsule())
                                    }
                                    .padding(12)
                                    .background(selectedTheme ? Color.black.opacity(0.03) : Color.white.opacity(0.03))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(16)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(20)

            if !boomBubbles.isEmpty {
                ZStack {
                    ForEach(boomBubbles) { bubble in
                        Text("БУМ (IPA)")
                            .font(.system(size: bubble.size, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .pink.opacity(0.55), radius: 24, x: 0, y: 0)
                            .position(x: bubble.x, y: bubble.y)
                            .rotationEffect(.degrees(bubble.rotation))
                            .opacity(bubble.opacity)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    private func createBoom() {
        var results: [BoomBubble] = []
        for _ in 0..<1000 {
            let x = CGFloat.random(in: 30...UIScreen.main.bounds.width - 30)
            let y = CGFloat.random(in: 80...UIScreen.main.bounds.height - 80)
            let size = CGFloat.random(in: 18...42)
            let rotation = Double.random(in: -20...20)
            let opacity = Double.random(in: 0.8...1.0)
            let duration = Double.random(in: 0.8...1.4)
            results.append(BoomBubble(x: x, y: y, size: size, rotation: rotation, opacity: opacity, duration: duration))
        }
        boomBubbles = results

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            boomBubbles = []
        }
    }

    private func sourceTitle(_ value: String) -> String {
        switch value {
        case "kernel": return "Kernel"
        case "api": return "API"
        case "db": return "Database"
        case "auth": return "Auth"
        case "scheduler": return "Scheduler"
        default: return value
        }
    }

    private func levelColor(_ level: LogLevel) -> Color {
        switch level {
        case .info: return .cyan.opacity(0.18)
        case .warning: return .yellow.opacity(0.18)
        case .error: return .red.opacity(0.18)
        case .success: return .green.opacity(0.18)
        }
    }

    private func levelTextColor(_ level: LogLevel) -> Color {
        switch level {
        case .info: return .cyan
        case .warning: return .yellow
        case .error: return .red
        case .success: return .green
        }
    }
}

#Preview {
    ContentView()
}
