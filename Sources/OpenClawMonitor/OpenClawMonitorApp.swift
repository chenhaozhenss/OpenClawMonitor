import SwiftUI
import Combine

// --- Data Models ---
struct RelayResponse: Codable {
    let ok: Bool
    let result: UsageInfo
}

struct UsageInfo: Codable {
    let totalTokens: Int
    let totalCost: Double
}

// --- Logic Manager ---
class OpenClawRelayManager: ObservableObject {
    @Published var tokens: Int = 0
    @Published var cost: Double = 0.0
    @Published var lastUpdated: String = "Connecting..."
    @Published var isOnline: Bool = false
    
    private let apiURL = "http://204.44.113.111:19999/usage/william"
    
    init() {
        fetch()
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.fetch()
        }
    }
    
    func fetch() {
        guard let url = URL(string: apiURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data, let decoded = try? JSONDecoder().decode(RelayResponse.self, from: data) {
                    self.tokens = decoded.result.totalTokens
                    self.cost = decoded.result.totalCost
                    self.isOnline = true
                    let formatter = DateFormatter()
                    formatter.timeStyle = .medium
                    self.lastUpdated = "Live: \(formatter.string(from: Date()))"
                } else {
                    self.isOnline = false
                    self.lastUpdated = "Sync Error"
                }
            }
        }.resume()
    }
}

// --- UI ---
struct MenuView: View {
    @StateObject var manager = OpenClawRelayManager()
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: manager.isOnline ? "waveform.path.ecg" : "exclamationmark.triangle")
                    .foregroundColor(manager.isOnline ? .green : .red)
                Text(manager.isOnline ? "OpenClaw Live" : "Offline").font(.headline)
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                Label("\(manager.tokens) Tokens", systemImage: "cpu")
                Label("$\(String(format: "%.4f", manager.cost))", systemImage: "dollarsign.circle")
            }.font(.system(.body, design: .monospaced))
            Divider()
            Text(manager.lastUpdated).font(.caption2).foregroundColor(.secondary)
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
        .padding()
        .frame(width: 200)
    }
}

@main
struct OpenClawMonitorApp: App {
    @StateObject private var manager = OpenClawRelayManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuView(manager: manager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "bolt.circle.fill")
                Text("\(manager.tokens)")
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

struct MenuView: View {
    @ObservedObject var manager: OpenClawRelayManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(manager.isOnline ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(manager.isOnline ? "OpenClaw Connected" : "Connection Lost")
                    .font(.headline)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "cpu")
                    Text("Tokens: \(manager.tokens)")
                }
                HStack {
                    Image(systemName: "dollarsign.circle")
                    Text("Cost: $\(String(format: "%.4f", manager.cost))")
                }
            }
            .font(.system(.body, design: .monospaced))
            
            Divider()
            
            Text(manager.lastUpdated)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Divider()
            
            Button("Manual Refresh") {
                manager.fetch()
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 220)
    }
}
