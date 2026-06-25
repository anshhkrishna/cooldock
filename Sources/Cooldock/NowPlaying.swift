import AppKit
import Combine

/// Polls Spotify and Music via AppleScript for the currently playing track,
/// and sends transport commands back. The very first poll triggers a one-time
/// macOS automation permission prompt for each app.
@MainActor
final class NowPlayingModel: ObservableObject {
    @Published var isActive = false
    @Published var isPlaying = false
    @Published var title = "Nothing playing"
    @Published var artist = ""
    @Published var progress: Double = 0          // 0...1
    @Published var artwork: NSImage?

    private var source: Source = .none
    private var lastArtworkURL: String?
    private var timer: Timer?

    enum Source { case none, spotify, music }

    private let spotifyID = "com.spotify.client"
    private let musicID = "com.apple.Music"

    func start() {
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.poll() }
        }
    }

    // MARK: Transport controls

    func togglePlay() { sendCommand("playpause") }
    func next()       { sendCommand("next track") }
    func previous()   { sendCommand("previous track") }

    private func sendCommand(_ cmd: String) {
        guard source != .none else { return }
        let app = (source == .spotify) ? "Spotify" : "Music"
        _ = runScript("tell application \"\(app)\" to \(cmd)")
        // Optimistic refresh so the UI feels instant.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in self?.poll() }
    }

    // MARK: Polling

    private func isRunning(_ bundleID: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }

    private func poll() {
        if isRunning(spotifyID), let info = fetch(app: "Spotify"), info.playing {
            source = .spotify; apply(info); return
        }
        if isRunning(musicID), let info = fetch(app: "Music"), info.playing {
            source = .music; apply(info); return
        }
        // Nothing actively playing — fall back to whatever is paused, if anything.
        if isRunning(spotifyID), let info = fetch(app: "Spotify") {
            source = .spotify; apply(info); return
        }
        if isRunning(musicID), let info = fetch(app: "Music") {
            source = .music; apply(info); return
        }
        source = .none
        isActive = false
        isPlaying = false
        title = "Nothing playing"
        artist = ""
        progress = 0
        artwork = nil
        lastArtworkURL = nil
    }

    private struct TrackInfo {
        var playing: Bool
        var title: String
        var artist: String
        var progress: Double
        var artworkURL: String
    }

    private func fetch(app: String) -> TrackInfo? {
        // Spotify exposes "artwork url" (an http URL); Music does not, so we
        // request it conditionally and tolerate an empty value.
        let artLine = app == "Spotify" ? "set art to (get artwork url of current track)" : "set art to \"\""
        let script = """
        tell application "\(app)"
            if it is running then
                try
                    set ps to player state as string
                    set tn to name of current track
                    set an to artist of current track
                    set dur to duration of current track
                    set pos to player position
                    \(artLine)
                    return ps & "<<F>>" & tn & "<<F>>" & an & "<<F>>" & dur & "<<F>>" & pos & "<<F>>" & art
                on error
                    return "stopped<<F>><<F>><<F>>0<<F>>0<<F>>"
                end try
            end if
        end tell
        """
        guard let raw = runScript(script) else { return nil }
        let parts = raw.components(separatedBy: "<<F>>")
        guard parts.count >= 6 else { return nil }

        let state = parts[0]
        let dur = Double(parts[3]) ?? 0          // Spotify=ms, Music=seconds
        let pos = Double(parts[4]) ?? 0          // seconds
        // Normalize duration: Spotify reports milliseconds (large), Music seconds.
        let durSeconds = dur > 10_000 ? dur / 1000 : dur
        let frac = durSeconds > 0 ? min(max(pos / durSeconds, 0), 1) : 0

        return TrackInfo(
            playing: state == "playing",
            title: parts[1].isEmpty ? "Unknown track" : parts[1],
            artist: parts[2],
            progress: frac,
            artworkURL: parts[5]
        )
    }

    private func apply(_ info: TrackInfo) {
        isActive = true
        isPlaying = info.playing
        title = info.title
        artist = info.artist
        progress = info.progress
        loadArtwork(info.artworkURL)
    }

    private func loadArtwork(_ urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
            if !trimmed.isEmpty { return } // keep last art if URL was just missing
            artwork = nil; lastArtworkURL = nil; return
        }
        guard trimmed != lastArtworkURL else { return }
        lastArtworkURL = trimmed
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = NSImage(data: data) else { return }
            Task { @MainActor in self?.artwork = image }
        }.resume()
    }

    @discardableResult
    private func runScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&error)
        if error != nil { return nil }
        return result.stringValue
    }
}
