// Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 @sharmanhall. All rights reserved.</string>
    <key>NSMainStoryboardFile</key>
    <string>Main</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app needs to control Spotify to switch between accounts.</string>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
</dict>
</plist>

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

// Project.pbxproj configurations (Key settings for Xcode project)
/*
Key Build Settings:
- PRODUCT_NAME = "Spotify Account Switcher"
- PRODUCT_BUNDLE_IDENTIFIER = "com.sharmanhall.spotify-account-switcher"
- MACOSX_DEPLOYMENT_TARGET = "12.0"
- SWIFT_VERSION = "5.0"
- CODE_SIGN_STYLE = "Automatic"
- DEVELOPMENT_TEAM = "YOUR_TEAM_ID"
- CODE_SIGN_IDENTITY = "Apple Development"
- ENABLE_HARDENED_RUNTIME = "YES"
- ENABLE_APP_SANDBOX = "NO" (Required for script execution)
*/

// Entitlements.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.temporary-exception.sbpl</key>
    <string>(allow process-exec (literal "/bin/bash") (literal "/usr/local/bin/spotify-switcher"))</string>
</dict>
</plist>

// AppDelegate.swift (if needed for additional app lifecycle management)
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app behavior
        NSApp.setActivationPolicy(.regular)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Show main window when dock icon is clicked and no windows are visible
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep app running even when main window is closed (for menu bar functionality)
        return false
    }
}

// FileWatcher.swift (for monitoring profile changes)
import Foundation
import Combine

class FileWatcher: ObservableObject {
    private var source: DispatchSourceFileSystemObject?
    private let path: String
    
    @Published var didChange = false
    
    init(path: String) {
        self.path = path
        startWatching()
    }
    
    deinit {
        stopWatching()
    }
    
    private func startWatching() {
        let url = URL(fileURLWithPath: path)
        
        guard let fd = open(url.path, O_EVTONLY) else {
            print("Failed to open file descriptor for \(path)")
            return
        }
        
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global(qos: .background)
        )
        
        source?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.didChange.toggle()
            }
        }
        
        source?.setCancelHandler {
            close(fd)
        }
        
        source?.resume()
    }
    
    private func stopWatching() {
        source?.cancel()
        source = nil
    }
}

// Extensions.swift
import SwiftUI
import Foundation

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension String {
    var isValidProfileName: Bool {
        let pattern = "^[a-zA-Z0-9_-]+$"
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}

extension UserDefaults {
    func setLastActiveProfile(_ profileName: String) {
        set(profileName, forKey: "LastActiveProfile")
    }
    
    func getLastActiveProfile() -> String? {
        return string(forKey: "LastActiveProfile")
    }
}

// Constants.swift
import Foundation

struct AppConstants {
    static let appName = "Spotify Account Switcher"
    static let bundleIdentifier = "com.sharmanhall.spotify-account-switcher"
    static let version = "1.0.0"
    
    struct Paths {
        static let applicationSupport = "\(NSHomeDirectory())/Library/Application Support"
        static let spotifyMain = "\(applicationSupport)/Spotify"
        static let spotifyProfiles = "\(applicationSupport)/Spotify-Profiles"
        static let spotifyApp = "/Applications/Spotify.app"
    }
    
    struct UserDefaultsKeys {
        static let lastActiveProfile = "LastActiveProfile"
        static let showNotifications = "ShowNotifications"
        static let launchAtLogin = "LaunchAtLogin"
        static let hideDockIcon = "HideDockIcon"
        static let disableGPU = "DisableGPU"
        static let clearCacheOnSwitch = "ClearCacheOnSwitch"
        static let scriptPath = "ScriptPath"
    }
    
    struct Notifications {
        static let profileSwitched = "ProfileSwitched"
        static let profileCreated = "ProfileCreated"
        static let profileDeleted = "ProfileDeleted"
    }
}