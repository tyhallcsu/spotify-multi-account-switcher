// AppSettings.swift
import AppKit
import Foundation
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: "ShowNotifications")
        }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "LaunchAtLogin")
            configureLaunchAtLogin()
        }
    }
    
    @Published var hideDockIcon: Bool {
        didSet {
            UserDefaults.standard.set(hideDockIcon, forKey: "HideDockIcon")
            configureAppDisplay()
        }
    }
    
    @Published var disableGPU: Bool {
        didSet {
            UserDefaults.standard.set(disableGPU, forKey: "DisableGPU")
        }
    }
    
    @Published var clearCacheOnSwitch: Bool {
        didSet {
            UserDefaults.standard.set(clearCacheOnSwitch, forKey: "ClearCacheOnSwitch")
        }
    }
    
    @Published var scriptPath: String {
        didSet {
            UserDefaults.standard.set(scriptPath, forKey: "ScriptPath")
        }
    }
    
    init() {
        self.showNotifications = UserDefaults.standard.object(forKey: "ShowNotifications") as? Bool ?? true
        self.launchAtLogin = UserDefaults.standard.object(forKey: "LaunchAtLogin") as? Bool ?? false
        self.hideDockIcon = UserDefaults.standard.object(forKey: "HideDockIcon") as? Bool ?? false
        self.disableGPU = UserDefaults.standard.object(forKey: "DisableGPU") as? Bool ?? false
        self.clearCacheOnSwitch = UserDefaults.standard.object(forKey: "ClearCacheOnSwitch") as? Bool ?? true
        self.scriptPath = UserDefaults.standard.string(forKey: "ScriptPath") ?? "/usr/local/bin/spotify-switcher"
    }
    
    private func configureLaunchAtLogin() {
        // Implementation for launch at login
        // This would typically involve modifying login items
    }
    
    private func configureAppDisplay() {
        if hideDockIcon {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
}