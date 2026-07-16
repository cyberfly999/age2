//
//  Helpers.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 27.09.2025.
//

import Foundation
import SwiftUI

final class Helpers {
	
	/// Formats a given Double value into a string with up to two decimal places.
	///
	/// - Parameter value: The Double value to format.
	/// - Returns: A string representation of the formatted number.
	public static func formatNumber(_ value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		
		let decimalValue = Decimal(value)
		
		return formatter.string(from: decimalValue as NSNumber) ?? "\(value)"
	}

	/// Returns a random pastel color from a predefined palette.
	///
	/// - Returns: A `Color` object representing the random pastel color.
	public static func randomColor() -> Color {
		// A palette of pastel colours that look nice together
		let colors: [Color] = [
			Color(red: 0.90, green: 0.95, blue: 1.00), // light sky
			Color(red: 1.00, green: 0.95, blue: 0.90), // soft peach
			Color(red: 0.95, green: 1.00, blue: 0.90), // mint
			Color(red: 0.95, green: 0.90, blue: 1.00), // lilac
			Color(red: 1.00, green: 0.90, blue: 0.95)  // blush
		]
		return colors.randomElement()!
	}
	
	// Helper to format the seconds as a readable string without decimals
	public static func formatSeconds(_ seconds: TimeInterval) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 0
		return formatter.string(from: NSNumber(value: seconds)) ?? "\(Int(seconds))"
	}

}

