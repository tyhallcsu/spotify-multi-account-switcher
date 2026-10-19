// Package.swift (if using Swift Package Manager)
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SpotifyAccountSwitcher",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SpotifyAccountSwitcher",
            targets: ["SpotifyAccountSwitcher"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "SpotifyAccountSwitcher",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SpotifyAccountSwitcherTests",
            dependencies: ["SpotifyAccountSwitcher"],
            path: "Tests"
        ),
    ]
)









