// ProfileManager.swift
import Foundation
import Combine
import UserNotifications

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfile: String?
    @Published var isLoading = false
    @Published var lastError: String?
    
    private let profilesPath = "\(NSHomeDirectory())/Library/Application Support/Spotify-Profiles"
    private let scriptName = "spotify-switcher"
    
    init() {
        loadProfiles()
        detectActiveProfile()
    }
    
    // MARK: - Public Methods
    
    func loadProfiles() {
        isLoading = true
        lastError = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let loadedProfiles = self.scanForProfiles()
            
            DispatchQueue.main.async {
                self.profiles = loadedProfiles
                self.isLoading = false
                self.detectActiveProfile()
            }
        }
    }
    
    func createProfile(name: String, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(false, "Internal error")
                return
            }
            
            let result = self.executeScript(command: "init", arguments: [name])
            
            DispatchQueue.main.async {
                if result.success {
                    self.loadProfiles()
                    completion(true, nil)
                } else {
                    completion(false, result.output)
                }
            }
        }
    }
    
    func switchToProfile(_ profile: Profile) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let result = self.executeScript(command: "switch", arguments: [profile.name])
            
            DispatchQueue.main.async {
                if result.success {
                    self.activeProfile = profile.name
                    self.sendNotification(title: "Profile Switched", 
                                        body: "Now using \(profile.name) account")
                } else {
                    self.lastError = result.output
                }
            }
        }
    }
    
    func deleteProfile(_ profile: Profile) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let result = self.executeScript(command: "remove", arguments: [profile.name])
            
            DispatchQueue.main.async {
                if result.success {
                    self.loadProfiles()
                    if self.activeProfile == profile.name {
                        self.activeProfile = nil
                    }
                } else {
                    self.lastError = result.output
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func scanForProfiles() -> [Profile] {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: profilesPath) else {
            return []
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: profilesPath)
            return contents.compactMap { item in
                let fullPath = "\(profilesPath)/\(item)"
                var isDirectory: ObjCBool = false
                
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                      isDirectory.boolValue else {
                    return nil
                }
                
                // Get creation date
                let attributes = try? fileManager.attributesOfItem(atPath: fullPath)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                
                return Profile(name: item, path: fullPath, createdDate: creationDate)
            }.sorted { $0.name < $1.name }
        } catch {
            return []
        }
    }
    
    private func detectActiveProfile() {
        // Check if there's a current Spotify profile that matches one of our saved profiles
        let mainSpotifyPath = "\(NSHomeDirectory())/Library/Application Support/Spotify"
        guard FileManager.default.fileExists(atPath: mainSpotifyPath) else {
            activeProfile = nil
            return
        }
        
        // Simple heuristic: check modification times or specific files
        // For now, we'll use a simpler approach and let the user indicate which is active
        activeProfile = UserDefaults.standard.string(forKey: "LastActiveProfile")
    }
    
    private func executeScript(command: String, arguments: [String]) -> (success: Bool, output: String) {
        let process = Process()
        let pipe = Pipe()
        
        // Try to find the script in various locations
        let possiblePaths = [
            "/usr/local/bin/spotify-switcher",
            "\(NSHomeDirectory())/spotify-switcher.sh",
            Bundle.main.path(forResource: "spotify-switcher", ofType: "sh"),
            "./spotify-switcher.sh"
        ].compactMap { $0 }
        
        var scriptPath: String?
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                scriptPath = path
                break
            }
        }
        
        guard let validScriptPath = scriptPath else {
            return (false, "Script not found. Please ensure spotify-switcher.sh is installed.")
        }
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [validScriptPath, command] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            let success = process.terminationStatus == 0
            return (success, success ? output : output)
        } catch {
            return (false, "Failed to execute script: \(error.localizedDescription)")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        guard AppSettings.shared.showNotifications else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}