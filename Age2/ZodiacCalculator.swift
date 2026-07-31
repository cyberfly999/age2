//
//  ZodiacCalculator.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 30.09.2025.
//
import Foundation
import SwiftUI

/// Controls the output format for zodiac results.
enum ZodiacOutputStyle {
    case name
    case symbol
    case both
}

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
	
	/// Returns the Western zodiac for the birth date in the requested output style, or `nil` if input was invalid.
	func zodiac(style: ZodiacOutputStyle = .both) -> String? {
		guard let date = birthDate else { return nil }
		
		let calendar = Calendar.current
		let birthYear  = calendar.component(.year, from: date)
		
		func makeDate(month: Int, day: Int) -> Date {
			var comps = DateComponents()
			comps.year  = birthYear
			comps.month = month
			comps.day   = day
			return calendar.date(from: comps)!
		}
		
		let signs: [(name: String, symbol: String, startMonth: Int, startDay: Int,
					 endMonth: Int,   endDay: Int)] = [
			("Capricorn",   "♑︎", 12, 22, 1, 19),
			("Aquarius",    "♒︎",  1, 20, 2, 18),
			("Pisces",      "♓︎",  2, 19, 3, 20),
			("Aries",       "♈︎",  3, 21, 4, 19),
			("Taurus",      "♉︎",  4, 20, 5, 20),
			("Gemini",      "♊︎",  5, 21, 6, 20),
			("Cancer",      "♋︎",  6, 21, 7, 22),
			("Leo",         "♌︎",  7, 23, 8, 22),
			("Virgo",       "♍︎",  8, 23, 9, 22),
			("Libra",       "♎︎",  9, 23,10, 22),
			("Scorpio",     "♏︎", 10, 23,11, 21),
			("Sagittarius", "♐︎", 11,22,12,21)
		]
		
		for sign in signs {
			let start = makeDate(month: sign.startMonth, day: sign.startDay)
			let end: Date
			if sign.startMonth > sign.endMonth {
				end = makeDate(month: sign.endMonth, day: sign.endDay)
			} else {
				end = makeDate(month: sign.endMonth, day: sign.endDay)
			}
			
			if sign.startMonth > sign.endMonth {
				if date >= start || date <= end {
					switch style {
					case .name: return sign.name
					case .symbol: return sign.symbol
					case .both: return "\(sign.name) \(sign.symbol)"
					}
				}
			} else {
				if date >= start && date <= end {
					switch style {
					case .name: return sign.name
					case .symbol: return sign.symbol
					case .both: return "\(sign.name) \(sign.symbol)"
					}
				}
			}
		}
		
		return nil
	}
}
