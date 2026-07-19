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
