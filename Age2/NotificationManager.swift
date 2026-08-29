// NotificationManager.swift
// Basic push notification setup for Age2

import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	static let shared = NotificationManager()
	private override init() {}

	func setupNotifications() {
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if let error = error {
				print("Notification authorization error: \(error)")
			}
			if granted {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			} else {
				print("Push notification authorization denied")
			}
		}
	}

	// MARK: UNUserNotificationCenterDelegate

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Handle notification tap/actions here if needed
		completionHandler()
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Show notifications while app is in the foreground
		completionHandler([.banner, .sound])
	}

	/// Schedules a local notification that will be delivered even if the app is in the background, inactive, or closed—provided notification permissions are granted by the user.
	func triggerTestNotification() {
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
	
	func addNotification(time: Double, title: String, subtitle: String, body: String) {
		let center = UNUserNotificationCenter.current()

		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = title
			content.subtitle = subtitle
			content.body = body
			content.sound = UNNotificationSound.default

			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)

			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			center.add(request)
		}

		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					} else {
						print("Authorization declined")
					}
				}
			}
		}
	}

	/// Schedules 10 notifications, each 100 seconds apart, starting from now.
	func scheduleTenNotifications() {
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
	func scheduleMultipleNotifications(number: Int, interval: Int) {
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
	
	/// Schedules parameterized notifications from now
		func scheduleMultipleNotifs(number: Int, interval: Int, title: String, subtitle: String, body: String) {
			for i in 1...number {
				let content = UNMutableNotificationContent()
				content.title = title
				content.subtitle = subtitle
				content.body = body
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
}

// MARK: - UIApplicationDelegate methods for remote notifications

extension NotificationManager: UIApplicationDelegate {
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// Convert device token to string for backend registration
		let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		print("APNs device token: \(token)")
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to register for remote notifications: \(error)")
	}
}
