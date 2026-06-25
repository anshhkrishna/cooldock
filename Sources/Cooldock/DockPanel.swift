import AppKit

/// A borderless, always-on-top floating panel that behaves like a second dock:
/// joins every Space, floats above normal windows, never steals focus from the
/// active app, and remembers where you dragged it.
final class DockPanel: NSPanel, NSWindowDelegate {
    private let frameKey = "CooldockPanelFrame"

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isMovableByWindowBackground = true
        becomesKeyOnlyIfNeeded = true
        hidesOnDeactivate = false

        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        delegate = self
    }

    // Allow becoming key so the Notes text field can receive typing,
    // but never become "main" (so we don't pull focus away from other apps).
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    func restorePosition() {
        // Restore only the origin — the window sizes itself to its content.
        if let saved = UserDefaults.standard.string(forKey: frameKey) {
            setFrameOrigin(NSRectFromString(saved).origin)
        } else {
            resetToDefaultPosition()
        }
    }

    func resetToDefaultPosition() {
        guard let screen = NSScreen.main else { return }
        let vf = screen.visibleFrame
        let size = frame.size
        // Park it near the right edge, vertically centered.
        let origin = NSPoint(x: vf.maxX - size.width - 24,
                             y: vf.midY - size.height / 2)
        setFrameOrigin(origin)
    }

    func windowDidMove(_ notification: Notification) {
        UserDefaults.standard.set(NSStringFromRect(frame), forKey: frameKey)
    }
}
