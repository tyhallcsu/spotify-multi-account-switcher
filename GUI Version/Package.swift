// swift-tools-version: 5.7
// Package.swift (Swift Package Manager build of the GUI version)
import PackageDescription

let package = Package(
    name: "SpotifyAccountSwitcher",
    platforms: [
        .macOS(.v13)
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
    ]
)
