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
    
    @State private var showSplash = true
    
    // Added deferred state properties for onboarding/profile presentation
    @State private var deferredOnboardingNeeded = false
    @State private var deferredOnboardingSelection: String? = nil
    @State private var deferredProfileFormNeeded = false
    @State private var deferredProfileFormInitial: UserProfile? = nil

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
        return String(localized: "Your era spans \(formatted) seconds")
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
    
    /// Requests notification permission if not already granted.
    private func setupNotifications() {
        requestNotificationAuthorizationIfNeeded()
    }
    
    /// Schedules a local notification that will be delivered even if the app is in the background, inactive, or closed—provided notification permissions are granted by the user.
    private func triggerTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test local notification."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
	/// Schedules 10 notifications, each 100 seconds apart, starting from now.
	private func scheduleTenNotifications() {
		for i in 1...10 {
			let content = UNMutableNotificationContent()
			content.title = "Scheduled Notification #\(i)"
			content.body = "This is notification #\(i) of 10."
			content.sound = .default
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(100 * i), repeats: false)
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Failed to schedule notification #\(i): \(error)")
				}
			}
		}
	}

	/// Schedules notifications from now
	private func scheduleMultipleNotifications(number: Int, interval: Int) {
		for i in 1...number {
			let content = UNMutableNotificationContent()
			content.title = "Scheduled Notificationgedonner #\(i)"
			content.body = "This is notification #\(i) of \(number)."
			content.sound = .default
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval * i), repeats: false)
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Failed to schedule notification #\(i): \(error)")
				}
			}
		}
	}
    
    private var splashView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                Text("Welcome to Age2")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }

    var body: some View {
        ZStack {
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
								
								Button(action: triggerTestNotification) {
									Text("Notify")
										.foregroundColor(.cyan)
										.padding(.horizontal, 8)
										.padding(.vertical, 8)
										.background(Color.black.opacity(0.8))
										.cornerRadius(8)
								}
								.accessibilityLabel(Text("Send Test Notification"))
								
								Button(action: scheduleTenNotifications) {
									Text("Notify x10")
										.foregroundColor(.cyan)
										.padding(.horizontal, 8)
										.padding(.vertical, 8)
										.background(Color.black.opacity(0.8))
										.cornerRadius(8)
								}
								.accessibilityLabel(Text("Send 10 Scheduled Notifications"))
								
								Button(action: { scheduleMultipleNotifications(number: 5, interval: 10) }) {
									Text("Send a couple of  Scheduled Notifications")
										.foregroundColor(.cyan)
										.padding(.horizontal, 8)
										.padding(.vertical, 8)
										.background(Color.black.opacity(0.8))
										.cornerRadius(8)
								}
								.accessibilityLabel(Text("Send a couple of Scheduled Notifications"))

								
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
            if showSplash {
                splashView
                    .zIndex(2)
            }
        }
        .onAppear {
            setupNotifications()
            showOnboarding = false
            showProfileForm = false
            // Defer onboarding/profile triggers until after splash
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
                // Decide what to present after splash
                if !hasCompletedOnboarding {
                    deferredOnboardingNeeded = true
                } else if let first = profiles.first {
                    activeProfile = first
                } else {
                    deferredOnboardingNeeded = true
                }
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
            now = time
        }
        .sheet(isPresented: $showOnboarding, onDismiss: {
            if activeProfile == nil {
                deferredProfileFormNeeded = true
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
                    if showSplash {
                        deferredProfileFormNeeded = true
                        profileFormInitial = tempProfile
                    } else {
                        showProfileForm = true
                        profileFormInitial = tempProfile
                    }
                } else if selection == "create" {
                    // Present empty form for new profile creation
                    activeProfile = nil
                    showOnboarding = false
                    if showSplash {
                        deferredProfileFormNeeded = true
                        profileFormInitial = nil
                    } else {
                        showProfileForm = true
                        profileFormInitial = nil
                    }
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
                        NotificationManager.shared.setupNotifications()
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
        .onChange(of: showSplash) { oldValue, newValue in
            if !newValue {
                if deferredOnboardingNeeded {
                    showOnboarding = true
                    deferredOnboardingNeeded = false
                }
                if deferredProfileFormNeeded {
                    showProfileForm = true
                    deferredProfileFormNeeded = false
                }
            }
        }
    }

    @State private var profileFormInitial: UserProfile? = nil
}

// MARK: - Preview

#Preview {
	return ContentView()
}
