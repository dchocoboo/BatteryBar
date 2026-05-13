import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = BatteryMonitor(
        reader: IOKitBatteryReader(),
        store: BatterySampleStore()
    )

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        configureStatusItem()
        configurePopover()
        LoginItemManager.enableLaunchAtLogin()

        monitor.onStatusChange = { [weak self] status in
            self?.updateStatusIcon(status)
        }
        monitor.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.target = self
        item.button?.action = #selector(togglePopover)
        item.button?.imagePosition = .imageLeading
        item.button?.toolTip = "Battery history"

        statusItem = item
        updateStatusIcon(monitor.currentStatus)
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 380, height: 278)
        popover.contentViewController = NSHostingController(
            rootView: BatteryPopoverView(monitor: monitor)
        )
    }

    private func updateStatusIcon(_ status: BatteryStatus) {
        guard let button = statusItem?.button else { return }

        button.image = NSImage(
            systemSymbolName: status.symbolName,
            accessibilityDescription: status.accessibilityDescription
        )
        button.image?.isTemplate = true
        button.title = status.menuBarTitle
        button.toolTip = status.tooltip
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
