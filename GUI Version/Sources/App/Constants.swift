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