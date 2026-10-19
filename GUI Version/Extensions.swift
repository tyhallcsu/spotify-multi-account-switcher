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