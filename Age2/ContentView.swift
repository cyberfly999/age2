//
//  ContentView.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 10.07.2026.
//

import SwiftUI
import SwiftData
import AuthenticationServices
import UIKit
internal import Combine
import Foundation

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    @Query private var profiles: [UserProfile]

    @State private var showOnboarding = true
    @State private var onboardingSelection: String? = nil

    @State private var showProfileForm = false
    @State private var activeProfile: UserProfile? = nil
    
    @State private var now = Date()
    
    // Computed property to calculate lifetime in seconds formatted string, using current 'now' date for live update
    private var lifetimeInSecondsText: String {
        guard let profile = activeProfile else { return "" }
        let timeZone = TimeZone(identifier: profile.timeZoneIdentifier) ?? .current
        let runningAge = RunningAge(birthdate: profile.dateOfBirth, birthtime: profile.timeOfBirth, timeZone: timeZone)
        let seconds = runningAge.calculateLifetimeInSeconds(currentDate: now)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: seconds)) ?? "\(Int(seconds))"
        return String(localized: "You are \(formatted) seconds old")
    }
    
    private var zodiacSignText: String {
        guard let profile = activeProfile else { return "" }
        let timeZone = TimeZone(identifier: profile.timeZoneIdentifier) ?? .current
        
        // Combine dateOfBirth and timeOfBirth into one Date in the profile's timeZone
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let birthDateComponents = calendar.dateComponents([.year, .month, .day], from: profile.dateOfBirth)
        let birthTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: profile.timeOfBirth)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = birthDateComponents.year
        combinedComponents.month = birthDateComponents.month
        combinedComponents.day = birthDateComponents.day
        combinedComponents.hour = birthTimeComponents.hour
        combinedComponents.minute = birthTimeComponents.minute
        combinedComponents.second = birthTimeComponents.second
        
        guard let combinedDate = calendar.date(from: combinedComponents) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDateTime = formatter.string(from: combinedDate)
        
		let zodiacCalculator = ZodiacCalculator(birthDateString: formattedDateTime, timeZoneIdentifier: profile.timeZoneIdentifier)
        let zodiac = zodiacCalculator.zodiacSign ?? ""
        
        if zodiac.isEmpty {
            return ""
        } else {
            return String(localized: "Zodiac: \(zodiac)")
        }
    }

    var body: some View {
        Group {
            if let profile = activeProfile {
                // Main app view with greeting
                NavigationView {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.45),
                                Color.purple.opacity(0.55)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("Hello, \(profile.nickname)!")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
							
							Text(lifetimeInSecondsText)
                                .foregroundColor(.white)
							// add zodiac here
                            if !zodiacSignText.isEmpty {
                                Text(zodiacSignText)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                profileFormInitial = profile
                                showProfileForm = true
                            }) {
                                Image(systemName: "person.crop.circle")
                                    .imageScale(.large)
                            }
                            .accessibilityLabel(Text("Edit Profile"))
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                // Show background while waiting for profile
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.45),
                            Color.purple.opacity(0.55)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            showOnboarding = !hasCompletedOnboarding

            if !showOnboarding {
                // Try to load activeProfile from existing profiles if available
                if let first = profiles.first {
                    activeProfile = first
                } else {
                    // No profile exists, force onboarding
                    showOnboarding = true
                }
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
            now = time
        }
        .sheet(isPresented: $showOnboarding, onDismiss: {
            // If onboarding finished but no profile, present profile form
            if activeProfile == nil {
                showProfileForm = true
            }
        }) {
            OnboardingView { selection in
                onboardingSelection = selection
                hasCompletedOnboarding = true

                if selection == "iosUser" {
                    // Try to get device name as nickname with fallback
                    let deviceName = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    // Pre-fill nickname with device name or fallback
                    let defaultNickname = deviceName.isEmpty ? String(localized: "User") : deviceName
                    // Create a temporary UserProfile with defaults and empty date/time, nil name/prename
                    let tempProfile = UserProfile(
                        nickname: defaultNickname,
                        name: nil,
                        prename: nil,
                        dateOfBirth: Date(),
                        timeOfBirth: Date(),
                        gender: nil,
                        timeZoneIdentifier: TimeZone.current.identifier
                    )
                    activeProfile = nil
                    showOnboarding = false
                    showProfileForm = true
                    profileFormInitial = tempProfile
                } else if selection == "create" {
                    // Present empty form for new profile creation
                    activeProfile = nil
                    showOnboarding = false
                    showProfileForm = true
                    profileFormInitial = nil
                }
            }
        }
        .sheet(isPresented: $showProfileForm, onDismiss: {
            // If profile form dismissed but no active profile, maybe handle fallback if needed
        }) {
            ProfileFormView(
                initialProfile: profileFormInitial,
                onComplete: { profile in
                    // Save profile to model context and update activeProfile
                    if let existingIndex = profiles.firstIndex(where: { $0.id == profile.id }) {
                        // Update existing
                        let existing = profiles[existingIndex]
                        existing.nickname = profile.nickname
                        existing.name = profile.name
                        existing.prename = profile.prename
                        existing.dateOfBirth = profile.dateOfBirth
                        existing.timeOfBirth = profile.timeOfBirth
                        existing.gender = profile.gender
                        existing.timeZoneIdentifier = profile.timeZoneIdentifier
                    } else {
                        // Insert new profile
                        modelContext.insert(profile)
                    }
                    do {
                        try modelContext.save()
                        activeProfile = profile
                        showProfileForm = false
                    } catch {
                        // Handle save error if needed
                        print("Failed to save profile: \(error)")
                    }
                },
                onCancel: {
                    // Only show onboarding if there are truly no profiles and no active profile
                    if profiles.isEmpty && activeProfile == nil {
                        showOnboarding = true
                        showProfileForm = false
                    } else {
                        // Dismiss form and keep the current user profile without showing onboarding
                        // This prevents onboarding from being shown again after the first profile was created and saved,
                        // and keeps the profile when canceling.
                        showProfileForm = false
                    }
                }
            )
        }
    }

    @State private var profileFormInitial: UserProfile? = nil
}

// MARK: - Preview

#Preview {
	return ContentView()
}

