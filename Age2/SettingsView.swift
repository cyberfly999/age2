import SwiftUI
import AVFoundation

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
    @AppStorage("selectedVoiceIdentifier") private var selectedVoiceIdentifier: String = ""

    @State private var notificationIntervals: [NotificationInterval] = []
    @State private var showNotificationOptions = false
    @State private var speechSynthesizer: AVSpeechSynthesizer? = nil

    let notificationUnits = ["Seconds", "Minutes", "Hours", "Days", "Weeks", "Months", "Years"]
    
    private var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().sorted { $0.name < $1.name }
    }
    
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
            
            Section(header: Text("Voice")) {
                Picker("Voice", selection: $selectedVoiceIdentifier) {
                    ForEach(availableVoices, id: \.identifier) { voice in
                        Text("\(voice.name) (\(voice.language))").tag(voice.identifier)
                    }
                }
                .pickerStyle(.menu)
                .onAppear {
                    if selectedVoiceIdentifier.isEmpty, let first = availableVoices.first {
                        selectedVoiceIdentifier = first.identifier
                    }
                }
                Button(action: {
                    let utterance = AVSpeechUtterance(string: "This is a voice preview.")
                    if let voice = availableVoices.first(where: { $0.identifier == selectedVoiceIdentifier }) {
                        utterance.voice = voice
                    }
                    let synth = speechSynthesizer ?? AVSpeechSynthesizer()
                    synth.stopSpeaking(at: .immediate)
                    synth.speak(utterance)
                    speechSynthesizer = synth
                }) {
                    Label("Preview Voice", systemImage: "")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
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

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let r, g, b: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        default:
            return nil
        }
        self = Color(red: r, green: g, blue: b)
    }
    func toHexString() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    SettingsView()
}
