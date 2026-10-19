// Profile.swift
import Foundation

struct Profile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let createdDate: Date
    let path: String
    
    init(name: String, path: String, createdDate: Date = Date()) {
        self.name = name
        self.path = path
        self.createdDate = createdDate
    }
}