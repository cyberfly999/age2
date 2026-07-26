import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @State private var showNotificationOptions = false
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        withAnimation {
                            showNotificationOptions = newValue
                        }
                        if newValue {
                            NotificationManager.shared.setupNotifications()
                        } else {
                            // Optionally, handle disabling (no way to fully 'disable' in iOS settings, but app can suppress sending)
                        }
                    }
                    .onAppear {
                        showNotificationOptions = notificationsEnabled
                    }
                
                if showNotificationOptions {
                    Section(header: Text("Notification Options")) {
                        Toggle("Show Banner", isOn: .constant(true)) // Placeholder
                        Toggle("Play Sound", isOn: .constant(false)) // Placeholder
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            Section(header: Text("Information")) {
                let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                Text("Version: " + versionString)
            }
        }
        .navigationTitle("Settings")
        .animation(.default, value: showNotificationOptions)
    }
}

#Preview {
    SettingsView()
}
