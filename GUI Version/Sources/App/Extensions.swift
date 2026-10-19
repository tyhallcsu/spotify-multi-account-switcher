// Extensions.swift
import SwiftUI
import Foundation

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
