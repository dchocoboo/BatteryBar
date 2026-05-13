// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BatteryBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "BatteryBar", targets: ["BatteryBar"])
    ],
    targets: [
        .executableTarget(
            name: "BatteryBar",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        )
    ]
)
