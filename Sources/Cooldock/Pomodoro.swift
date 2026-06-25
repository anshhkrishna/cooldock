import Foundation
import Combine

/// A simple focus/break timer. Counts down, auto-switches modes, tracks how
/// many focus sessions you've completed.
@MainActor
final class PomodoroModel: ObservableObject {
    enum Mode { case focus, brk
        var label: String { self == .focus ? "Focus" : "Break" }
        var duration: TimeInterval { self == .focus ? 25 * 60 : 5 * 60 }
    }

    @Published var mode: Mode = .focus
    @Published var remaining: TimeInterval = Mode.focus.duration
    @Published var running = false
    @Published var completedSessions = 0

    private var timer: Timer?

    var total: TimeInterval { mode.duration }
    var progress: Double { total > 0 ? 1 - (remaining / total) : 0 }

    var timeString: String {
        let r = max(0, Int(remaining.rounded()))
        return String(format: "%02d:%02d", r / 60, r % 60)
    }

    func toggle() { running ? pause() : start() }

    func start() {
        running = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func pause() {
        running = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remaining = mode.duration
    }

    func skip() { advanceMode() }

    private func tick() {
        remaining -= 1
        if remaining <= 0 {
            if mode == .focus { completedSessions += 1 }
            advanceMode()
        }
    }

    private func advanceMode() {
        mode = (mode == .focus) ? .brk : .focus
        remaining = mode.duration
        // Keep running into the next interval automatically.
        if running { start() }
    }
}
