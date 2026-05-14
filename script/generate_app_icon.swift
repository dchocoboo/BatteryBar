#!/usr/bin/env swift

import AppKit
import Foundation

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourcesURL = rootURL.appendingPathComponent("Resources", isDirectory: true)
let iconsetURL = rootURL
    .appendingPathComponent("dist", isDirectory: true)
    .appendingPathComponent("AppIcon.iconset", isDirectory: true)
let icnsURL = resourcesURL.appendingPathComponent("AppIcon.icns")

try FileManager.default.createDirectory(at: resourcesURL, withIntermediateDirectories: true)
try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

struct IconImage {
    let filename: String
    let pixels: Int
}

let images = [
    IconImage(filename: "icon_16x16.png", pixels: 16),
    IconImage(filename: "icon_16x16@2x.png", pixels: 32),
    IconImage(filename: "icon_32x32.png", pixels: 32),
    IconImage(filename: "icon_32x32@2x.png", pixels: 64),
    IconImage(filename: "icon_128x128.png", pixels: 128),
    IconImage(filename: "icon_128x128@2x.png", pixels: 256),
    IconImage(filename: "icon_256x256.png", pixels: 256),
    IconImage(filename: "icon_256x256@2x.png", pixels: 512),
    IconImage(filename: "icon_512x512.png", pixels: 512),
    IconImage(filename: "icon_512x512@2x.png", pixels: 1024)
]

for image in images {
    let size = NSSize(width: image.pixels, height: image.pixels)
    let icon = NSImage(size: size)

    icon.lockFocus()
    drawIcon(in: NSRect(origin: .zero, size: size), scale: CGFloat(image.pixels) / 1024)
    icon.unlockFocus()

    guard
        let tiff = icon.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Failed to render \(image.filename)")
    }

    try png.write(to: iconsetURL.appendingPathComponent(image.filename))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = [
    "-c",
    "icns",
    iconsetURL.path,
    "-o",
    icnsURL.path
]

try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with exit code \(process.terminationStatus)")
}

print(icnsURL.path)

private func drawIcon(in rect: NSRect, scale: CGFloat) {
    let cornerRadius = rect.width * 0.225
    let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    let backgroundGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.055, green: 0.067, blue: 0.086, alpha: 1),
        NSColor(calibratedRed: 0.105, green: 0.122, blue: 0.150, alpha: 1)
    ])
    backgroundGradient?.draw(in: backgroundPath, angle: -45)

    NSColor(calibratedWhite: 1, alpha: 0.10).setStroke()
    backgroundPath.lineWidth = max(1, 8 * scale)
    backgroundPath.stroke()

    let inset = rect.width * 0.16
    let batteryRect = NSRect(
        x: rect.minX + inset,
        y: rect.minY + rect.height * 0.43,
        width: rect.width * 0.59,
        height: rect.height * 0.28
    )
    let capRect = NSRect(
        x: batteryRect.maxX + rect.width * 0.018,
        y: batteryRect.minY + batteryRect.height * 0.26,
        width: rect.width * 0.052,
        height: batteryRect.height * 0.48
    )

    let batteryPath = NSBezierPath(roundedRect: batteryRect, xRadius: rect.width * 0.065, yRadius: rect.width * 0.065)
    NSColor(calibratedWhite: 1, alpha: 0.90).setStroke()
    batteryPath.lineWidth = max(2, 34 * scale)
    batteryPath.stroke()

    let capPath = NSBezierPath(roundedRect: capRect, xRadius: rect.width * 0.018, yRadius: rect.width * 0.018)
    NSColor(calibratedWhite: 1, alpha: 0.82).setFill()
    capPath.fill()

    let fillRect = batteryRect.insetBy(dx: rect.width * 0.055, dy: rect.height * 0.060)
    let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: rect.width * 0.035, yRadius: rect.width * 0.035)
    let fillGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.24, green: 0.93, blue: 0.48, alpha: 1),
        NSColor(calibratedRed: 0.08, green: 0.70, blue: 0.98, alpha: 1)
    ])
    fillGradient?.draw(in: fillPath, angle: 0)

    let barWidth = rect.width * 0.048
    let barSpacing = rect.width * 0.030
    let baseX = rect.minX + rect.width * 0.25
    let baseY = rect.minY + rect.height * 0.22
    let heights = [0.115, 0.170, 0.235, 0.315]

    for (index, heightRatio) in heights.enumerated() {
        let barRect = NSRect(
            x: baseX + CGFloat(index) * (barWidth + barSpacing),
            y: baseY,
            width: barWidth,
            height: rect.height * heightRatio
        )
        let barPath = NSBezierPath(roundedRect: barRect, xRadius: barWidth * 0.45, yRadius: barWidth * 0.45)
        NSColor(calibratedWhite: 1, alpha: 0.88).setFill()
        barPath.fill()
    }

    let shineRect = NSRect(
        x: rect.minX + rect.width * 0.18,
        y: rect.minY + rect.height * 0.74,
        width: rect.width * 0.48,
        height: rect.height * 0.055
    )
    let shinePath = NSBezierPath(roundedRect: shineRect, xRadius: shineRect.height / 2, yRadius: shineRect.height / 2)
    NSColor(calibratedWhite: 1, alpha: 0.12).setFill()
    shinePath.fill()
}
