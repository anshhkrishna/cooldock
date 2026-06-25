# Cooldock

A personal native macOS floating dock — a borderless, always-on-top glass panel
that floats over the desktop and across Spaces. Currently ships a **Now Playing**
widget that reads Spotify / Music live and controls playback.

## Build & run

Requires macOS 14+ and the Swift toolchain (Command Line Tools is enough).

```sh
./build.sh        # compiles release + packages Cooldock.app
open Cooldock.app
```

On first launch macOS asks to allow controlling Spotify and Music — approve it,
or the Now Playing widget can't read tracks.

## Controls

- Drag the panel anywhere; it remembers its position.
- Menu-bar icon (stacked squares): Show/Hide, Reset Position, Quit.

## Layout

- `Sources/Cooldock/main.swift` — app entry, panel + menu-bar setup
- `Sources/Cooldock/DockPanel.swift` — floating, non-activating NSPanel
- `Sources/Cooldock/NowPlaying.swift` — Spotify/Music polling via AppleScript
- `Sources/Cooldock/Pomodoro.swift` — focus timer (built, not currently shown)
- `Sources/Cooldock/Widgets.swift` — SwiftUI dock + widget views
