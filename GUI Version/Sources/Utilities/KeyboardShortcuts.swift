// KeyboardShortcuts.swift
import SwiftUI
import Carbon

class KeyboardShortcutManager: ObservableObject {
    private var shortcuts: [String: EventHotKeyRef] = [:]
    
    func registerShortcut(identifier: String, keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(identifier.hashValue), id: UInt32(identifier.hashValue))
        
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if status == noErr, let hotKey = hotKeyRef {
            shortcuts[identifier] = hotKey
        }
    }
    
    func unregisterShortcut(identifier: String) {
        if let hotKey = shortcuts[identifier] {
            UnregisterEventHotKey(hotKey)
            shortcuts.removeValue(forKey: identifier)
        }
    }
    
    func unregisterAllShortcuts() {
        for (identifier, _) in shortcuts {
            unregisterShortcut(identifier: identifier)
        }
    }
}