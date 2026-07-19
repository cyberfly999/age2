//
//  ZodiacCalculator.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 30.09.2025.
//
import Foundation
import SwiftUI

/// A lightweight, non‑throwing zodiac calculator.
///
/// - If the date string can’t be parsed, `zodiacSign` will be `nil`.
/// - If the time‑zone identifier is unknown, the current system zone is used.
final class ZodiacCalculator {
	// MARK: - Private state
	
	/// The parsed birth date (or `nil` if parsing failed).
	private let birthDate: Date?
	
	// MARK: - Initialiser
	
	/// Creates a calculator for the supplied date string and time‑zone.
	///
	/// - Parameters:
	///   - birthDateString: A string that can be parsed by the supplied formatter.
	///   - timeZoneIdentifier: An IANA time‑zone identifier (e.g. `"America/New_York"`).
	///   - dateFormatter: Optional formatter – defaults to `yyyy-MM-dd HH:mm:ss`.
	init(birthDateString: String,
		 timeZoneIdentifier: String,
		 dateFormatter: DateFormatter? = nil) {
		
		// 1️⃣ Build a formatter that knows the requested time‑zone.
		let formatter = dateFormatter ?? {
			let df = DateFormatter()
			df.dateFormat = "yyyy-MM-dd HH:mm:ss"
			df.locale    = Locale(identifier: "en_US_POSIX")
			return df
		}()
		
		formatter.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
		
		// 2️⃣ Try to parse the string.  If it fails we keep `birthDate` as nil.
		self.birthDate = formatter.date(from: birthDateString)
	}
	
	// MARK: - Public API
	
	/// The Western zodiac sign for the stored birth date, or `nil` if the input was invalid.
	var zodiacSign: String? {
		guard let date = birthDate else { return nil }
		
		// All signs are defined by month/day ranges.  We build a date
		// for the *same* year as `date` and compare.
		let calendar = Calendar.current
		let birthYear  = calendar.component(.year, from: date)
		
		func makeDate(month: Int, day: Int) -> Date {
			var comps = DateComponents()
			comps.year  = birthYear
			comps.month = month
			comps.day   = day
			return calendar.date(from: comps)!
		}
		
		// Sign definitions – inclusive ranges.
		let signs: [(name: String, startMonth: Int, startDay: Int,
					 endMonth: Int,   endDay: Int)] = [
			("Capricorn ♑︎", 12, 22, 1, 19),
			("Aquarius ♒︎",  1, 20, 2, 18),
			("Pisces ♓︎",    2, 19, 3, 20),
			("Aries ♈︎",     3, 21, 4, 19),
			("Taurus ♉︎",    4, 20, 5, 20),
			("Gemini ♊︎",    5, 21, 6, 20),
			("Cancer ♋︎",    6, 21, 7, 22),
			("Leo ♌︎",       7, 23, 8, 22),
			("Virgo ♍︎",     8, 23, 9, 22),
			("Libra ♎︎",     9, 23,10, 22),
			("Scorpio ♏︎",  10, 23,11, 21),
			("Sagittarius ♐︎",11,22,12,21)
		]
		
		for sign in signs {
			let start = makeDate(month: sign.startMonth, day: sign.startDay)
			
			// Capricorn wraps around the year end.
			let end: Date
			if sign.startMonth > sign.endMonth {
				// e.g. 12/22 – 1/19
				end = makeDate(month: sign.endMonth, day: sign.endDay)
			} else {
				end = makeDate(month: sign.endMonth, day: sign.endDay)
			}
			
			if sign.startMonth > sign.endMonth {
				// Wrapped range – two intervals.
				if date >= start || date <= end { return sign.name }
			} else {
				// Normal range.
				if date >= start && date <= end { return sign.name }
			}
		}
		
		// Should never happen – all dates belong to a sign.
		return nil
	}
}
