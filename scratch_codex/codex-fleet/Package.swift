// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CodexFleet",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "CodexFleet", targets: ["CodexFleet"]),
    ],
    targets: [
        .executableTarget(
            name: "CodexFleet",
            path: "Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ]
)
