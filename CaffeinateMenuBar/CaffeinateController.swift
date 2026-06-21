import Foundation
import Combine

@MainActor
final class CaffeinateController: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var endsAt: Date?

    private var process: Process?
    private var endTimer: Timer?

    func start(flags: CaffeinateFlags, duration: TimeInterval?) {
        stop()

        var args: [String] = []
        if flags.preventDisplaySleep { args.append("-d") }
        if flags.preventIdleSleep { args.append("-i") }
        if flags.preventDiskSleep { args.append("-m") }
        if flags.preventSystemSleep { args.append("-s") }
        if flags.assertUserActive { args.append("-u") }
        if let duration {
            args.append("-t")
            args.append(String(Int(duration)))
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        proc.arguments = args
        proc.terminationHandler = { [weak self] _ in
            Task { @MainActor in
                self?.handleTermination()
            }
        }

        do {
            try proc.run()
            process = proc
            isRunning = true
            if let duration {
                let end = Date().addingTimeInterval(duration)
                endsAt = end
                scheduleEndTimer(at: end)
            } else {
                endsAt = nil
            }
        } catch {
            NSLog("Failed to launch caffeinate: \(error)")
            isRunning = false
        }
    }

    func stop() {
        endTimer?.invalidate()
        endTimer = nil
        if let proc = process, proc.isRunning {
            proc.terminate()
        }
        process = nil
        isRunning = false
        endsAt = nil
    }

    private func handleTermination() {
        process = nil
        isRunning = false
        endsAt = nil
        endTimer?.invalidate()
        endTimer = nil
    }

    private func scheduleEndTimer(at date: Date) {
        endTimer?.invalidate()
        let interval = max(0.1, date.timeIntervalSinceNow)
        endTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.stop() }
        }
    }
}

struct CaffeinateFlags: Equatable {
    var preventDisplaySleep: Bool = true   // -d
    var preventIdleSleep: Bool = true      // -i
    var preventDiskSleep: Bool = false     // -m
    var preventSystemSleep: Bool = false   // -s (AC only)
    var assertUserActive: Bool = false     // -u
}
