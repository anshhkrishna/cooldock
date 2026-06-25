import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: DockPanel!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // .regular gives Cooldock a real icon in the macOS Dock.
        NSApp.setActivationPolicy(.regular)

        // Build the floating panel hosting the SwiftUI dock.
        let hosting = NSHostingView(rootView: ContentView())
        let panel = DockPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 240),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hosting
        // Shrink the window to fit the single widget.
        hosting.layoutSubtreeIfNeeded()
        panel.setContentSize(hosting.fittingSize)
        panel.restorePosition()
        panel.orderFrontRegardless()
        self.panel = panel

        setupStatusItem()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "square.stack.3d.up.fill",
                                   accessibilityDescription: "Cooldock")
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show / Hide Dock", action: #selector(toggleDock), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "Reset Position", action: #selector(resetPosition), keyEquivalent: "r"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Cooldock", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        self.statusItem = item
    }

    @objc private func toggleDock() {
        guard let panel else { return }
        if panel.isVisible { panel.orderOut(nil) } else { panel.orderFrontRegardless() }
    }

    @objc private func resetPosition() {
        panel?.resetToDefaultPosition()
        panel?.orderFrontRegardless()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
