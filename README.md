# Cooldock

A personal native macOS floating dock — a borderless, always-on-top glass panel that floats over the desktop and follows you across Spaces. It ships a **Now Playing** widget that reads Spotify / Music live and controls playback right from the panel.

> Written in Swift + SwiftUI as a lightweight, single-purpose alternative to a full menu-bar suite.

<!-- Add a screenshot or GIF of the floating dock here — it's the one thing that sells a visual app:
     ![Cooldock](docs/cooldock.png) -->

## Build & run

Requires **macOS 14+** and the Swift toolchain (Xcode Command Line Tools is enough — `xcode-select --install`).

```sh
./build.sh        # compiles release + packages Cooldock.app
open Cooldock.app
```

On first launch macOS asks to allow controlling Spotify and Music — approve it, or the Now Playing widget can't read tracks.

## Controls

- Drag the panel anywhere; it remembers its position across launches.
- Menu-bar icon (stacked squares): **Show/Hide**, **Reset Position**, **Quit**.

## Widgets

- **Now Playing** *(shipping)* — live Spotify / Music track, artwork, and playback controls via AppleScript polling.
- **Pomodoro** *(built, not yet surfaced in the dock)* — a focus timer wired up in `Pomodoro.swift`, pending UI integration.

## Project layout

| File | Purpose |
|---|---|
| `Sources/Cooldock/main.swift` | App entry — panel + menu-bar setup |
| `Sources/Cooldock/DockPanel.swift` | Floating, non-activating `NSPanel` that spans Spaces |
| `Sources/Cooldock/NowPlaying.swift` | Spotify / Music polling via AppleScript |
| `Sources/Cooldock/Pomodoro.swift` | Focus timer (built, not currently shown) |
| `Sources/Cooldock/Widgets.swift` | SwiftUI dock + widget views |
| `build.sh` | Compiles a release build and packages `Cooldock.app` |

## License

[MIT](LICENSE) © 2026 Ansh Krishna
