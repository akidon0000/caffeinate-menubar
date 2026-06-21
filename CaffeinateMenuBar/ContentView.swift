import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: CaffeinateController

    @AppStorage("flag.d") private var preventDisplaySleep = true
    @AppStorage("flag.i") private var preventIdleSleep = true
    @AppStorage("flag.m") private var preventDiskSleep = false
    @AppStorage("flag.s") private var preventSystemSleep = false
    @AppStorage("flag.u") private var assertUserActive = false

    @AppStorage("duration.mode") private var durationMode: DurationMode = .indefinite
    @AppStorage("duration.minutes") private var minutes: Int = 60

    @State private var now = Date()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            Divider()

            GroupBox("Options") {
                VStack(alignment: .leading, spacing: 8) {
                    flagToggle("-d", "ディスプレイのスリープを防ぐ（画面を点けっぱなし）", isOn: $preventDisplaySleep)
                    flagToggle("-i", "システムのアイドルスリープを防ぐ", isOn: $preventIdleSleep)
                    flagToggle("-m", "ディスクのアイドルスリープを防ぐ", isOn: $preventDiskSleep)
                    flagToggle("-s", "システムスリープを防ぐ（AC電源接続中のみ有効）", isOn: $preventSystemSleep)
                    flagToggle("-u", "ユーザーが操作中であると宣言する（既定で 5 秒間）", isOn: $assertUserActive)
                }
                .padding(.vertical, 4)
            }

            GroupBox("Duration") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("", selection: $durationMode) {
                        ForEach(DurationMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    if durationMode == .timed {
                        HStack {
                            Slider(value: Binding(
                                get: { Double(minutes) },
                                set: { minutes = Int($0) }
                            ), in: 5...480, step: 5)
                            Text("\(minutes) min")
                                .monospacedDigit()
                                .frame(width: 64, alignment: .trailing)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            HStack {
                if controller.isRunning {
                    Button(role: .destructive) {
                        controller.stop()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .keyboardShortcut(.defaultAction)
                } else {
                    Button {
                        controller.start(flags: currentFlags, duration: currentDuration)
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .keyboardShortcut(.defaultAction)
                }

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                }
                .help("Quit")
            }
        }
        .padding(14)
        .frame(width: 320)
        .onReceive(ticker) { now = $0 }
    }

    @ViewBuilder
    private func flagToggle(_ flag: String, _ description: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 1) {
                Text(flag).font(.system(.body, design: .monospaced))
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.checkbox)
    }

    private var header: some View {
        HStack {
            Image(systemName: controller.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(controller.isRunning ? "Awake" : "Idle")
                    .font(.headline)
                if let endsAt = controller.endsAt {
                    Text("Ends in \(remaining(until: endsAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if controller.isRunning {
                    Text("Until stopped")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private func remaining(until date: Date) -> String {
        let secs = max(0, Int(date.timeIntervalSince(now)))
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    private var currentFlags: CaffeinateFlags {
        CaffeinateFlags(
            preventDisplaySleep: preventDisplaySleep,
            preventIdleSleep: preventIdleSleep,
            preventDiskSleep: preventDiskSleep,
            preventSystemSleep: preventSystemSleep,
            assertUserActive: assertUserActive
        )
    }

    private var currentDuration: TimeInterval? {
        durationMode == .timed ? TimeInterval(minutes * 60) : nil
    }
}

enum DurationMode: String, CaseIterable, Identifiable {
    case indefinite
    case timed

    var id: String { rawValue }
    var label: String {
        switch self {
        case .indefinite: return "Until stopped"
        case .timed: return "Timer"
        }
    }
}
