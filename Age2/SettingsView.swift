import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                        if newValue {
                            NotificationManager.shared.setupNotifications()
                        } else {
                            // Optionally, handle disabling (no way to fully 'disable' in iOS settings, but app can suppress sending)
                        }
                    }
            }
            

        }
        .navigationTitle("Settings")
		
		Section(header: Text("Information")) {
			let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
			Text("Version: " + versionString)
		}
    }
}

#Preview {
    SettingsView()
}
