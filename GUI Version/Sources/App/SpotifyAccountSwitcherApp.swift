// SpotifyAccountSwitcherApp.swift
import SwiftUI
import UserNotifications

@main
struct SpotifyAccountSwitcherApp: App {
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentView()
                .environmentObject(profileManager)
                .environmentObject(appSettings)
                .frame(minWidth: 400, minHeight: 300)
                .onAppear {
                    setupNotifications()
                    profileManager.loadProfiles()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        // Menu Bar Extra
        MenuBarExtra("Spotify Switcher", systemImage: "music.note.list") {
            MenuBarView()
                .environmentObject(profileManager)
                .environmentObject(appSettings)
        }
        .menuBarExtraStyle(.window)
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(appSettings)
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}

// ContentView.swift
struct ContentView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingCreateProfile = false
    @State private var showingDeleteAlert = false
    @State private var profileToDelete: Profile?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Profile List
            if profileManager.profiles.isEmpty {
                emptyStateView
            } else {
                profileListView
            }
            
            // Footer
            footerView
        }
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingCreateProfile) {
            CreateProfileView()
                .environmentObject(profileManager)
        }
        .alert("Delete Profile", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let profile = profileToDelete {
                    profileManager.deleteProfile(profile)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let profile = profileToDelete {
                Text("Are you sure you want to delete the '\(profile.name)' profile? This cannot be undone.")
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "music.note.list")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spotify Account Switcher")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Switch between your Spotify accounts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Active profile indicator
                if let activeProfile = profileManager.activeProfile {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("Active: \(activeProfile)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Divider()
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Profiles Found")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("Create your first profile to start switching between Spotify accounts")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create First Profile") {
                showingCreateProfile = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var profileListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(profileManager.profiles) { profile in
                    ProfileRowView(
                        profile: profile,
                        isActive: profile.name == profileManager.activeProfile,
                        onSwitch: { profileManager.switchToProfile(profile) },
                        onDelete: { 
                            profileToDelete = profile
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                Button("Create Profile") {
                    showingCreateProfile = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if profileManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.trailing, 8)
                }
                
                Button("Refresh") {
                    profileManager.loadProfiles()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

// ProfileRowView.swift
struct ProfileRowView: View {
    let profile: Profile
    let isActive: Bool
    let onSwitch: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Icon
            ZStack {
                Circle()
                    .fill(isActive ? Color.green : Color.blue)
                    .frame(width: 40, height: 40)
                
                Image(systemName: isActive ? "checkmark" : "person.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Profile Info
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Created \(profile.createdDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status
            if isActive {
                Text("ACTIVE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
            
            // Actions
            HStack(spacing: 8) {
                if !isActive {
                    Button("Switch") {
                        onSwitch()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.green.opacity(0.05) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// CreateProfileView.swift
struct CreateProfileView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var profileName = ""
    @State private var isCreating = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create New Profile")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Save your current Spotify session as a new profile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
            // Form
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile Name")
                    .font(.headline)
                
                TextField("Enter profile name (e.g., work, personal)", text: $profileName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        createProfile()
                    }
                
                Text("Make sure Spotify is logged into the account you want to save, then quit Spotify before creating the profile.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Actions
            HStack {
                Spacer()
                
                Button("Create Profile") {
                    createProfile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                .overlay(
                    Group {
                        if isCreating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                )
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private func createProfile() {
        let name = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !name.isEmpty else {
            errorMessage = "Profile name cannot be empty"
            return
        }
        
        guard name.range(of: "^[a-zA-Z0-9_-]+$", options: .regularExpression) != nil else {
            errorMessage = "Profile name can only contain letters, numbers, hyphens, and underscores"
            return
        }
        
        isCreating = true
        errorMessage = ""
        
        profileManager.createProfile(name: name) { success, error in
            DispatchQueue.main.async {
                isCreating = false
                
                if success {
                    dismiss()
                } else {
                    errorMessage = error ?? "Failed to create profile"
                }
            }
        }
    }
}

// MenuBarView.swift
struct MenuBarView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(.green)
                Text("Spotify Switcher")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if let activeProfile = profileManager.activeProfile {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Active: \(activeProfile)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            Divider()
            
            // Profiles
            if profileManager.profiles.isEmpty {
                Text("No profiles found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(profileManager.profiles) { profile in
                    Button(action: {
                        profileManager.switchToProfile(profile)
                    }) {
                        HStack {
                            Image(systemName: profile.name == profileManager.activeProfile ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(profile.name == profileManager.activeProfile ? .green : .secondary)
                            
                            Text(profile.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(profile.name == profileManager.activeProfile)
                }
            }
            
            Divider()
            
            // Actions
            Button("Open Main Window") {
                NSApp.activate(ignoringOtherApps: true)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .frame(width: 200)
    }
}

// SettingsView.swift
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(appSettings)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AdvancedSettingsView()
                .environmentObject(appSettings)
                .tabItem {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Show notifications on profile switch", isOn: $appSettings.showNotifications)
                
                Toggle("Launch at login", isOn: $appSettings.launchAtLogin)
                
                Toggle("Hide dock icon", isOn: $appSettings.hideDockIcon)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct AdvancedSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Script Location:")
                    Spacer()
                    Text(appSettings.scriptPath)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Button("Choose Script Location") {
                    // Open file picker
                }
                .buttonStyle(.bordered)
                
                Toggle("Disable GPU acceleration", isOn: $appSettings.disableGPU)
                    .help("Enable if you experience UI crashes")
                
                HStack {
                    Text("Clear cache on switch:")
                    Toggle("", isOn: $appSettings.clearCacheOnSwitch)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}