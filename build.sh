#!/bin/bash
# Builds Cooldock.app from the SwiftPM binary + Info.plist, then ad-hoc signs it
# so macOS automation (Spotify/Music control) permissions stick across rebuilds.
set -e
cd "$(dirname "$0")"

echo "→ Compiling (release)…"
swift build -c release

APP="Cooldock.app"
BIN=".build/release/Cooldock"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Cooldock"
cp Info.plist "$APP/Contents/Info.plist"

echo "→ Ad-hoc signing…"
codesign --force --sign - "$APP" >/dev/null 2>&1 || echo "  (codesign skipped)"

echo "✓ Built $APP"
echo "  Run it with:  open $APP"
