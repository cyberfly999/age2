import SwiftUI

let presetAmounts = [10, 100, 1000, 10000, 100000]

struct NotificationInterval: Identifiable, Hashable {
    let id = UUID()
    var value: Int
    var unit: String
    
    var usesCustomValue: Bool {
        value != 10 && value != 100 && value != 1000 && value != 10000 && value != 100000
    }
}

struct NotificationIntervalRow: View {
    @Binding var interval: NotificationInterval
    let notificationUnits: [String]
    let presetAmounts: [Int]
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text("Every")
            Picker("Amount", selection: $interval.value) {
                ForEach(presetAmounts, id: \.self) { amt in
                    Text("\(amt)").tag(amt)
                }
                Text("Other").tag(-1)
            }
            .frame(width: 80)
            .pickerStyle(.menu)
            .onChange(of: interval.value) { _, newValue in
                if newValue != -1 && !presetAmounts.contains(newValue) {
                    interval.value = presetAmounts[0]
                }
            }

            if interval.value == -1 {
                TextField("Other", value: $interval.value, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .frame(width: 70)
            }

            Picker("Unit", selection: $interval.unit) {
                ForEach(notificationUnits, id: \.self) { unit in
                    Text(unit)
                }
            }
            .pickerStyle(.menu)
            // Spacer()
			
			
			// optional delete button, let it commented
//            if let onDelete = onDelete {
//                Button(role: .destructive) {
//                    onDelete()
//                } label: {
//                    Image(systemName: "trash")
//                }
//                .buttonStyle(.borderless)
//            }
        }
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("showZodiac") private var showZodiac: Bool = false
    @State private var showNotificationOptions = false
    @State private var notificationIntervals: [NotificationInterval] = [NotificationInterval(value: 1, unit: "Seconds")]
    let notificationUnits = ["Seconds", "Minutes", "Hours", "Days", "Weeks", "Months", "Years"]
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
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
                    Section(header: Text("Notification Intervals")) {
                        ForEach(Array(notificationIntervals.enumerated()), id: \.element.id) { index, _ in
                            NotificationIntervalRow(
                                interval: $notificationIntervals[index],
                                notificationUnits: notificationUnits,
                                presetAmounts: presetAmounts,
                                onDelete: {
                                    notificationIntervals.remove(at: index)
                                }
                            )
                        }
                        .onDelete { indexSet in
                            notificationIntervals.remove(atOffsets: indexSet)
                        }
                        Button(action: {
                            notificationIntervals.append(NotificationInterval(value: presetAmounts[0], unit: notificationUnits[0]))
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 6)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            Section(header: Text("Zodiac")) {
                Toggle("Show Zodiac", isOn: $showZodiac)
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
