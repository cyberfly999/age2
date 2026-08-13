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
import UserNotifications

/// Ensures notification permissions are requested on app launch or before scheduling notifications.
private func requestNotificationAuthorizationIfNeeded() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus != .authorized else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            // You might want to handle 'granted == false' here.
        }
    }
}

struct AnimatedDigitView: View {
    @State private var displayedDigit: Int = 0
    @State private var rotation: Double = 0
    var digit: Int
    var body: some View {
        Text("\(displayedDigit)")
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            .frame(width: 28)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 1, y: 0, z: 0)
            )
            .onChange(of: digit) { _, newValue in
                if newValue != displayedDigit {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                        rotation += 360
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                        displayedDigit = newValue
                    }
                }
            }
            .onAppear {
                displayedDigit = digit
            }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("showZodiac") private var showZodiac: Bool = true

    @Query private var profiles: [UserProfile]

    // Control flags for onboarding and profile form visibility
    @State private var showOnboarding = false
    @State private var showProfileForm = false
    @State private var showSettingsSheet = false

    @State private var activeProfile: UserProfile? = nil
    
    @State private var now = Date()
    
    @State private var showSplash = true
    private let showSplashFor: TimeInterval = 3

    @State private var hasCheckedProfiles = false

    private var hasProfile: Bool { profiles.first != nil }
    
    // MARK: - New per instructions
    
    @State private var previousDigits: [Int] = []
    
    private var lifetimeDigits: [Int] {
        guard let profile = activeProfile else { return [] }
        let timeZone = TimeZone(identifier: profile.timeZoneIdentifier) ?? .current
        let runningAge = RunningAge(birthdate: profile.dateOfBirth, birthtime: profile.timeOfBirth, timeZone: timeZone)
        let seconds = Int(runningAge.calculateLifetimeInSeconds(currentDate: now))
        let formatted = String(seconds)
        return formatted.compactMap { Int(String($0)) }
    }
    
    // MARK: - Removed lifetimeInSecondsParts usage
    
    private func handleInitialScreen() {
        if profiles.isEmpty {
            showOnboarding = true
            activeProfile = nil
        } else {
            showOnboarding = false
            showProfileForm = false
            activeProfile = profiles.first
        }
        hasCheckedProfiles = true
    }

    /// Requests notification permission if not already granted.
    private func setupNotifications() {
        requestNotificationAuthorizationIfNeeded()
    }
    
    var body: some View {
        // Prevent onboarding/profile form if a profile exists
        let shouldShowOnboarding = hasCheckedProfiles && showOnboarding && !hasProfile && !showSplash
        let shouldShowProfileForm = hasCheckedProfiles && showProfileForm && !hasProfile && !showSplash && !showOnboarding
        
        ZStack {
            Group {
                if let profile = activeProfile {
                    // Main app view with greeting
                    NavigationView {
                        ZStack {
                            
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
                            
                            // Fireworks background
                            FireworksView()
                                .ignoresSafeArea()

                            // main view
                            VStack(spacing: 0) {
                                Text("Hello, \(profile.nickname)!")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
								
								Text("Your Era spans\n ")
									.foregroundColor(.white)
									.font(Font.largeTitle.bold())
									.multilineTextAlignment(.center)
								
                                HStack(spacing: 0) {
                                    ForEach(Array(lifetimeDigits.enumerated()), id: \.offset) { _, digit in
                                        AnimatedDigitView(digit: digit)
                                    }
                                    Text(" seconds")
                                        .foregroundColor(.white)
                                        .font(Font.largeTitle.bold())
                                }
                                .onChange(of: lifetimeDigits) { _, newDigits in
                                    previousDigits = newDigits
                                }
                                
                                // add zodiac here
                                if showZodiac && !ZodiacCalculator.zodiacSignText(for: activeProfile).isEmpty {
                                    Text(ZodiacCalculator.zodiacSignText(for: activeProfile))
                                        .foregroundColor(.white)
                                }
                                
                                if notificationsEnabled {
                                    Button(action: { NotificationManager.shared.scheduleMultipleNotifications(number: 5, interval: 10) }) {
                                        Text("Test Notifications")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.8))
                                            .cornerRadius(8)
                                    }
                                    .accessibilityLabel(Text("Send a couple of Scheduled Notifications"))
                                }
                                
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                HStack {
                                    Button {
                                        showSettingsSheet = true
                                    } label: {
                                        Image(systemName: "gearshape")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                    }
                                    .accessibilityLabel("Settings")

                                    Spacer()

                                    Button {
                                        profileFormInitial = profile
                                        showProfileForm = true
                                    } label: {
                                        Image(systemName: "person")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                    }
                                    .accessibilityLabel("Edit Profile")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .sharedBackgroundVisibility(.hidden)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } else {
                    // Show background while waiting for profile
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                    }
                }
            }
            if showSplash {
                SplashView()
                    .zIndex(2)
            }
        }
        .onAppear {
            // Always reset splash on every app launch, including after being killed
            showSplash = true
            setupNotifications()
            // At launch, show splash for n seconds as in let showSplashFor then fade out and decide next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + showSplashFor) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
                handleInitialScreen()
            }
        }
        .onChange(of: profiles) { _, _ in
            handleInitialScreen()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
            now = time
        }
        .sheet(isPresented: .constant(shouldShowOnboarding), onDismiss: {
            // After onboarding dismissed, if no active profile, show profile form
            if activeProfile == nil {
                showProfileForm = true
            }
        }) {
            OnboardingView { selection in
                hasCompletedOnboarding = true
                onboardingSelection = selection

                if selection == "iosUser" {
                    // Try to get device name as nickname with fallback
                    let deviceName = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let defaultNickname = deviceName.isEmpty ? String(localized: "User") : deviceName
                    let tempProfile = UserProfile(
                        nickname: defaultNickname,
                        name: nil,
                        prename: nil,
                        dateOfBirth: Date(),
                        timeOfBirth: Date(),
                        gender: nil,
                        timeZoneIdentifier: TimeZone.current.identifier
                    )
                    // Persist the newly created profile before dismissing onboarding and showing profile form
                    modelContext.insert(tempProfile)
                    do {
                        try modelContext.save()
                        activeProfile = tempProfile
                        // Hide onboarding and show profile form for further edits
                        showOnboarding = false
                        profileFormInitial = tempProfile
                        showProfileForm = true
                    } catch {
                        print("Failed to save profile after onboarding selection: \(error)")
                    }
                } else if selection == "create" {
                    // Dismiss onboarding and show empty profile form
                    showOnboarding = false
                    profileFormInitial = nil
                    showProfileForm = true
                }
            }
        }
        .sheet(isPresented: .constant(shouldShowProfileForm), onDismiss: {
            // If profile form dismissed but no active profile and no existing profiles, show onboarding again
            if activeProfile == nil && profiles.isEmpty {
                showOnboarding = true
                showProfileForm = false
            }
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
                        NotificationManager.shared.setupNotifications()
                        activeProfile = profile
                        showProfileForm = false
                        // Hide onboarding and profile form after saving
                        showOnboarding = false
                        showProfileForm = false
                    } catch {
                        // Handle save error if needed
                        print("Failed to save profile: \(error)")
                    }
                },
                onCancel: {
                    if profiles.isEmpty && activeProfile == nil {
                        // No profiles, show onboarding again
                        showOnboarding = true
                        showProfileForm = false
                    } else {
                        // Profiles exist, hide onboarding and profile form
                        showOnboarding = false
                        showProfileForm = false
                    }
                }
            )
        }
        .sheet(isPresented: $showSettingsSheet) {
            NavigationStack {
                SettingsView()
            }
        }
    }

    @State private var onboardingSelection: String? = nil
    @State private var profileFormInitial: UserProfile? = nil
}

// MARK: - Preview

#Preview {
    return ContentView()
}

