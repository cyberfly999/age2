//
//  RunningAge.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 25.09.2025.
//
//  A lightweight model that keeps a person’s birth date and time,
//  and can report how long the person has lived in various time units.
//  Now includes support for storing an initial time zone and using the current time zone in calculations.
//

import Foundation
import UIKit

/// A lightweight model that keeps a person’s birth date and time,
/// and can report how long the person has lived in various time units.
final class RunningAge {
	
	// MARK: - Stored Properties
	
	/// The exact date & time of birth combined from separate date and time inputs
	/// (including the time zone that was used when creating it).
	let birthMoment: Date
	
	/// The time zone at object creation.
	let timeZoneAtCreation: TimeZone
	
	// MARK: - Constants
	
	/// Time‑interval constants for clarity and to avoid magic numbers.
	private static let secondsPerMinute: Double = 60.0
	private static let secondsPerHour:   Double = 3_600.0
	private static let secondsPerDay:    Double = 86_400.0
	
	// MARK: - Initializer
	
	/// Creates a new `RunningAge` instance.
	///
	/// - Parameters:
	///   - birthdate: A `Date` value that represents the birth date (date portion).
	///   - birthtime: A `Date` value that represents the birth time (time portion).
	///   - timeZone: The time zone to store at object creation (default: `.current`)
	init(birthdate: Date, birthtime: Date, timeZone: TimeZone = .current) {
		self.timeZoneAtCreation = timeZone
		
		// Combine birthdate's date components with birthtime's time components in the given time zone
		let calendar = Calendar.current
		var dateComponents = calendar.dateComponents(in: timeZone, from: birthdate)
		let timeComponents = calendar.dateComponents(in: timeZone, from: birthtime)
		
		dateComponents.hour = timeComponents.hour
		dateComponents.minute = timeComponents.minute
		dateComponents.second = timeComponents.second
		dateComponents.nanosecond = timeComponents.nanosecond
		
		self.birthMoment = calendar.date(from: dateComponents) ?? birthdate
	}
	
	// MARK: - Helper Properties
	
	/// The instant at which all lifetime calculations are based.
	///
	/// Cached so that multiple calls use the same `Date` value,
	/// ensuring consistency across all units.
	private var now: Date {
		if let cached = _now { return cached }
		let current = Date()
		_now = current
		return current
	}
	
	/// Lazy storage for the cached “now” value.
	private var _now: Date?
	
	/// Calendar instance
	private var calendar: Calendar {
		var cal = Calendar.current
		cal.timeZone = self.timeZoneAtCreation
		return cal
	}
	
	/// All relevant date components between the birth moment and `now` in the current time zone.
	///
	/// The calculation is performed only once per request, then reused
	/// by the month‑, year‑, decade‑ and century‑calculations.
	private var lifetimeComponents: DateComponents {
		calendar.dateComponents(
			[.year, .month],
			from: birthMoment,
			to: now
		)
	}
	
	// MARK: - Lifetime Calculations (Seconds / Minutes / Hours)
	
	/// Returns the lifetime in **seconds** as a `TimeInterval` (a typealias for `Double`).
	///
	/// - Parameter currentDate: An optional reference date to calculate the lifetime relative to.
	///                          If `nil` (default), uses the current cached date.
	func calculateLifetimeInSeconds(currentDate: Date? = nil) -> TimeInterval {
		let referenceNow = currentDate ?? now
		return referenceNow.timeIntervalSince(birthMoment)
	}
	
	/// Returns the lifetime in **minutes** as a `Double`.
	func calculateLifetimeInMinutes() -> Double {
		calculateLifetimeInSeconds() / Self.secondsPerMinute
	}
	
	/// Returns the lifetime in **hours** as a `Double`.
	func calculateLifetimeInHours() -> Double {
		calculateLifetimeInSeconds() / Self.secondsPerHour
	}
	
	// MARK: - Convenience Methods (Days / Weeks)
	
	/// Returns the lifetime in **days** as a `Double`.
	func calculateLifetimeInDays() -> Double {
		calculateLifetimeInSeconds() / Self.secondsPerDay
	}
	
	/// Returns the lifetime in **weeks** as a `Double`.
	func calculateLifetimeInWeeks() -> Double {
		calculateLifetimeInDays() / 7.0
	}
	
	// MARK: - Calendar‑Based Calculations (Months / Years)
	
	/// Returns the lifetime in **months** as a `Double`.
	///
	/// The calculation uses `Calendar` to account for varying month lengths.
	func calculateLifetimeInMonths() -> Double {
		let components = lifetimeComponents
		let years  = components.year ?? 0
		let months = components.month ?? 0
		return Double(years * 12 + months)
	}
	
	/// Returns the lifetime in **years** as a `Double`.
	///
	/// The calculation uses `Calendar` to account for leap years, etc.
	func calculateLifetimeInYears() -> Double {
		let components = calendar.dateComponents([.year], from: birthMoment, to: now)
		return Double(components.year ?? 0)
	}
	
	// MARK: - Derived Time Units (Decades / Centuries)
	
	/// Returns the lifetime in **decades** as a `Double`.
	func calculateLifetimeInDecades() -> Double {
		calculateLifetimeInYears() / 10.0
	}
	
	/// Returns the lifetime in **centuries** as a `Double`.
	func calculateLifetimeInCenturies() -> Double {
		calculateLifetimeInYears() / 100.0
	}
	
	/// Public getter for the stored birth date portion.
	///
	/// This method exposes the `birthMoment` value as a formatted string (`"yyyy-MM-dd"`).
	func getBirthdayAsString() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: birthMoment)
	}
	
	/// Calculates the lifetime in a specified unit.
	func calculateLifetime(in unit: AgeUnit) -> Double {
		switch unit {
		case .seconds:
			return calculateLifetimeInSeconds()
		case .minutes:
			return calculateLifetimeInMinutes()
		case .hours:
			return calculateLifetimeInHours()
		case .days:
			return calculateLifetimeInDays()
		case .weeks:
			return calculateLifetimeInWeeks()
		case .months:
			return calculateLifetimeInMonths()
		case .years:
			return calculateLifetimeInYears()
		case .decades:
			return calculateLifetimeInDecades()
		case .centuries:
			return calculateLifetimeInCenturies()
		}
	}
	
	
}
