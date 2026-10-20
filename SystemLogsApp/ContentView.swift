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

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 14)
    }
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
        LogEntry(time: "00:11:11", source: "db", level: .error, message: "Connection pool saturation detected on replica-2"),
        LogEntry(time: "00:12:19", source: "auth", level: .info, message: "MFA challenge issued for admin login attempt"),
        LogEntry(time: "00:13:55", source: "scheduler", level: .warning, message: "Background job retry count exceeded threshold"),
        LogEntry(time: "00:15:07", source: "api", level: .error, message: "Failed request: 503 on /api/search"),
        LogEntry(time: "00:16:44", source: "kernel", level: .success, message: "Memory compacting finished successfully"),
        LogEntry(time: "00:18:03", source: "db", level: .info, message: "Index rebuild completed on analytics table"),
        LogEntry(time: "00:20:29", source: "api", level: .info, message: "New API clients connected via websocket gateway"),
        LogEntry(time: "00:21:15", source: "auth", level: .success, message: "Password rotation completed for service account prod-worker"),
        LogEntry(time: "00:23:39", source: "kernel", level: .error, message: "Kernel panic recovered after unexpected reboot"),
        LogEntry(time: "00:24:58", source: "scheduler", level: .success, message: "Cleanup task removed 3.4GB of stale cache"),
        LogEntry(time: "00:26:11", source: "api", level: .warning, message: "Webhook retry queue exceeded normal latency"),
        LogEntry(time: "00:27:44", source: "db", level: .success, message: "Replica lag returned to normal threshold"),
        LogEntry(time: "00:29:10", source: "auth", level: .warning, message: "Multiple failed login attempts from 10.0.0.18")
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

    private var backgroundGradient: LinearGradient {
        if selectedTheme {
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 1.0), Color(red: 0.82, green: 0.90, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [Color(red: 0.03, green: 0.06, blue: 0.12), Color(red: 0.08, green: 0.12, blue: 0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var panelForeground: Color {
        selectedTheme ? .black : .white
    }

    private var mutedForeground: Color {
        selectedTheme ? .black.opacity(0.6) : .white.opacity(0.72)
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(selectedTheme ? 0.14 : 0.10))
                .frame(width: 360, height: 360)
                .position(x: 280, y: 100)
                .blur(radius: 30)

            Circle()
                .fill(Color.pink.opacity(selectedTheme ? 0.12 : 0.18))
                .frame(width: 420, height: 420)
                .position(x: 1060, y: 720)
                .blur(radius: 35)

            HStack(alignment: .top, spacing: 22) {
                sidebar
                    .frame(width: 300)

                mainPanel
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(20)

            if !boomBubbles.isEmpty {
                ZStack {
                    ForEach(boomBubbles) { bubble in
                        Text("БУМ")
                            .font(.system(size: bubble.size, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("System Logs")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(panelForeground)
                Spacer()
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .shadow(color: .green.opacity(0.8), radius: 10)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Search")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(mutedForeground)
                        .textCase(.uppercase)
                        .tracking(1.5)

                    TextField("Filter logs...", text: $searchText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedTheme ? Color.black.opacity(0.04) : Color.white.opacity(0.06))
                        )
                        .foregroundColor(panelForeground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.10), lineWidth: 1)
                        )
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Levels")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(mutedForeground)
                        .textCase(.uppercase)
                        .tracking(1.5)

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
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(levelColor(level))
                                    .clipShape(Capsule())
                                Spacer()
                            }
                        }
                        .toggleStyle(.checkbox)
                        .tint(.cyan)
                    }
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Source")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(mutedForeground)
                        .textCase(.uppercase)
                        .tracking(1.5)

                    Picker("Source", selection: $selectedSource) {
                        Text("All sources").tag("all")
                        Text("Kernel").tag("kernel")
                        Text("API").tag("api")
                        Text("Database").tag("db")
                        Text("Auth").tag("auth")
                        Text("Scheduler").tag("scheduler")
                    }
                    .pickerStyle(.menu)
                    .tint(panelForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(mutedForeground)
                        .textCase(.uppercase)
                        .tracking(1.5)

                    HStack(spacing: 10) {
                        Button("Dark") {
                            selectedTheme = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTheme ? Color.white.opacity(0.12) : Color.cyan.opacity(0.9))
                        .foregroundColor(selectedTheme ? panelForeground : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Button("Light") {
                            selectedTheme = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTheme ? Color.cyan.opacity(0.9) : Color.white.opacity(0.12))
                        .foregroundColor(selectedTheme ? .black : panelForeground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            GlassCard {
                Button(action: createBoom) {
                    Text("БУМ")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [Color.pink, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
    }

    private var mainPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Live Event Stream")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(panelForeground)

                Spacer()

                HStack(spacing: 8) {
                    Circle().frame(width: 10, height: 10).foregroundColor(.green)
                    Text("\(filteredLogs.count) events")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(mutedForeground)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)

            if filteredLogs.isEmpty {
                Spacer()
                Text("No logs match the current filters.")
                    .foregroundColor(mutedForeground)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredLogs) { log in
                            HStack(alignment: .center, spacing: 14) {
                                Text(log.time)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(mutedForeground)
                                    .frame(width: 80, alignment: .leading)

                                Text(sourceTitle(log.source))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(panelForeground)
                                    .frame(width: 80, alignment: .leading)

                                Text(log.message)
                                    .font(.system(size: 15))
                                    .foregroundColor(panelForeground)
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
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(selectedTheme ? Color.white.opacity(0.22) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
    }

    private func createBoom() {
        for index in 0..<1000 {
            let delay = Double(index) * 0.02
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                presentAlertWindow(title: "БУМ")
            }
        }

        var results: [BoomBubble] = []
        for _ in 0..<1000 {
            let x = CGFloat.random(in: 40...UIScreen.main.bounds.width - 40)
            let y = CGFloat.random(in: 80...UIScreen.main.bounds.height - 80)
            let size = CGFloat.random(in: 18...42)
            let rotation = Double.random(in: -18...18)
            let opacity = Double.random(in: 0.82...1.0)
            let duration = Double.random(in: 0.9...1.4)
            results.append(BoomBubble(x: x, y: y, size: size, rotation: rotation, opacity: opacity, duration: duration))
        }

        boomBubbles = results

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            boomBubbles = []
        }
    }

    private func presentAlertWindow(title: String) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.view.tintColor = .systemPink
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)

        if let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            let presenter = rootVC.presentedViewController ?? rootVC
            presenter.present(alert, animated: true)
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
        case .info: return .cyan.opacity(0.20)
        case .warning: return .yellow.opacity(0.20)
        case .error: return .red.opacity(0.20)
        case .success: return .green.opacity(0.20)
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
