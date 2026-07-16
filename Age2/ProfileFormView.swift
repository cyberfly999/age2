// Extracted from ContentView.swift
import SwiftUI

struct ProfileFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var nickname: String
    @State private var name: String
    @State private var prename: String
    @State private var dateOfBirth: Date
    @State private var timeOfBirth: Date
    @State private var gender: String?
    @State private var selectedTimeZone: String

    let genders = ["Male", "Female", "Other", "Prefer not to say"]

    var onComplete: (UserProfile) -> Void
    var onCancel: (() -> Void)? = nil
    private var editingProfile: UserProfile?

    init(initialProfile: UserProfile? = nil, onComplete: @escaping (UserProfile) -> Void, onCancel: (() -> Void)? = nil) {
        self.onComplete = onComplete
        self.onCancel = onCancel
        _nickname = State(initialValue: initialProfile?.nickname ?? "")
        _name = State(initialValue: initialProfile?.name ?? "")
        _prename = State(initialValue: initialProfile?.prename ?? "")
        _dateOfBirth = State(initialValue: initialProfile?.dateOfBirth ?? Date())
        _timeOfBirth = State(initialValue: initialProfile?.timeOfBirth ?? Date())
        _gender = State(initialValue: initialProfile?.gender)
        _selectedTimeZone = State(initialValue: initialProfile?.timeZoneIdentifier ?? TimeZone.current.identifier)
        self.editingProfile = initialProfile
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nickname")) {
                    TextField("Nickname", text: $nickname)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }

                if editingProfile == nil {
                    Section(header: Text("Name")) {
                        TextField("Prename (optional)", text: $prename)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                        TextField("Name (optional)", text: $name)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                }

                Section(header: Text("Date of Birth")) {
                    DatePicker("Date", selection: $dateOfBirth, displayedComponents: .date)
                    DatePicker("Time", selection: $timeOfBirth, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Gender (optional)")) {
                    Picker("Gender", selection: Binding(
                        get: { gender ?? "" },
                        set: { newValue in
                            gender = newValue.isEmpty ? nil : newValue
                        })
                    ) {
                        Text("None").tag("")
                        ForEach(genders, id: \.self) { genderOption in
                            Text(genderOption).tag(genderOption)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Time Zone")) {
                    Picker("Time Zone", selection: $selectedTimeZone) {
                        Text(TimeZone.current.identifier + " (Current)").tag(TimeZone.current.identifier)
                        ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { timeZoneID in
                            Text(timeZoneID).tag(timeZoneID)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle(editingProfile == nil ? "Create Profile" : "Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel?()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let profile = UserProfile(
                            id: editingProfile?.id ?? UUID(),
                            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name.trimmingCharacters(in: .whitespacesAndNewlines),
                            prename: prename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : prename.trimmingCharacters(in: .whitespacesAndNewlines),
                            dateOfBirth: dateOfBirth,
                            timeOfBirth: timeOfBirth,
                            gender: gender,
                            timeZoneIdentifier: selectedTimeZone
                        )
                        onComplete(profile)
                        dismiss()
                    }
                    .disabled(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
