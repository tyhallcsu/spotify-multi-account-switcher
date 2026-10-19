// ScriptExecutor.swift
import Foundation

struct ScriptExecutor {
    static func execute(_ command: String, arguments: [String] = []) -> (success: Bool, output: String) {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return (process.terminationStatus == 0, output.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    static func findSpotifySwitcherScript() -> String? {
        let possiblePaths = [
            "/usr/local/bin/spotify-switcher",
            "\(NSHomeDirectory())/spotify-switcher.sh",
            "./spotify-switcher.sh"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
    static func isSpotifyRunning() -> Bool {
        let result = execute("pgrep -f Spotify")
        return result.success && !result.output.isEmpty
    }
    
    static func killSpotify() -> Bool {
        let result = execute("pkill -9 -f Spotify")
        return result.success
    }
    
    static func launchSpotify() -> Bool {
        let result = execute("open -a '/Applications/Spotify.app'")
        return result.success
    }
}