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
        LoginItemManager.applyLaunchAtLoginPreference()

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
        item.button?.action = #selector(handleStatusItemClick)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        item.button?.imagePosition = .imageLeading
        item.button?.toolTip = "Battery history"

        statusItem = item
        updateStatusIcon(monitor.currentStatus)
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 380, height: 202)
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

    @objc private func handleStatusItemClick() {
        let event = NSApp.currentEvent
        let isRightClick = event?.type == .rightMouseUp
        let isControlClick = event?.modifierFlags.contains(.control) == true

        if isRightClick || isControlClick {
            showStatusMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            let positioningRect = button.bounds.offsetBy(dx: 0, dy: 6)
            popover.show(relativeTo: positioningRect, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showStatusMenu() {
        guard let button = statusItem?.button else { return }

        popover.performClose(nil)

        let menu = NSMenu()
        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        loginItem.target = self
        loginItem.state = LoginItemManager.isLaunchAtLoginPreferred ? .on : .off
        menu.addItem(loginItem)

        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: button)
        } else {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
        }
    }

    @objc private func toggleLaunchAtLogin() {
        LoginItemManager.setLaunchAtLoginEnabled(!LoginItemManager.isLaunchAtLoginPreferred)
    }
}
