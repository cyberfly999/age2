import SwiftUI

let presetAmounts = [10, 100, 1000, 10000, 100000]
let notificationIntervalsKey = "notificationIntervals"

struct NotificationInterval: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var value: Int
    var unit: String
    var name: String = "My New Birthday"
    var body: String = "Tralala"
    
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Every")
                Picker("", selection: $interval.value) {
                    ForEach(presetAmounts, id: \.self) { amt in
                        Text("\(amt)").tag(amt)
                    }
                    Text("Other").tag(-1)
                }
                .frame(width: 120)
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

                Picker("", selection: $interval.unit) {
                    ForEach(notificationUnits, id: \.self) { unit in
                        Text(unit)
                    }
                }
                .pickerStyle(.menu)
                // Spacer()
                
                
                // optional delete button, let it commented
//                if let onDelete = onDelete {
//                    Button(role: .destructive) {
//                        onDelete()
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                    .buttonStyle(.borderless)
//                }
            }
            
            TextField("Title", text: $interval.name)
                .textFieldStyle(.roundedBorder)
                .padding(.top, 4)
            TextField("Topic", text: $interval.body)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("showZodiac") private var showZodiac: Bool = false
    @AppStorage(notificationIntervalsKey) private var notificationIntervalsData: Data = Data()
    @State private var notificationIntervals: [NotificationInterval] = []
    @State private var showNotificationOptions = false
    let notificationUnits = ["Seconds", "Minutes", "Hours", "Days", "Weeks", "Months", "Years"]
    
    private func saveNotificationIntervals() {
        if let encoded = try? JSONEncoder().encode(notificationIntervals) {
            notificationIntervalsData = encoded
        }
    }
    
    var body: some View {
        Form {
			Section(header: Text("Zodiac")) {
				Toggle("Show Zodiac", isOn: $showZodiac)
			}
			
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
                            withAnimation {
                                notificationIntervals.append(NotificationInterval(value: presetAmounts[0], unit: notificationUnits[0]))
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 6)
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .animation(.default, value: showNotificationOptions)
        .onAppear {
            if let decoded = try? JSONDecoder().decode([NotificationInterval].self, from: notificationIntervalsData), !decoded.isEmpty {
                notificationIntervals = decoded
            } else {
                notificationIntervals = [NotificationInterval(value: 1, unit: "Seconds")]
            }
        }
        .onChange(of: notificationIntervals) {
            saveNotificationIntervals()
        }
    }
}

#Preview {
    SettingsView()
}
