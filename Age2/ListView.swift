//
//  ListView.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 28.09.2025.
//
import SwiftUI

struct ListView: View {
	
	let runningAge: RunningAge

	var body: some View {
		VStack {
			List {
				Section(header: Text("This Age is you and your's alone.").foregroundColor(Color.green)) {
					ForEach(AgeUnit.allCases) { unit in
						LabelValueRow(label: unit.label, value: Helpers.formatNumber(runningAge.calculateLifetime(in: unit)))
					}
				}
				.listRowSeparatorTint(.green)
				.listRowBackground(Color.clear)
			}
			.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
			.opacity(1)
			.background(Color.clear)
			.blendMode(.exclusion)
			.preferredColorScheme(.dark)
		}
		
	}
}


// Simple reusable row
private struct LabelValueRow: View {
	let label: String
	let value: String
	var body: some View {
		HStack {
			Text(label)
				.foregroundColor(Color.green)
			Spacer()
			Text(value)
				.monospaced()
		}
	}
}

enum AgeUnit: CaseIterable, Identifiable {
	case seconds, minutes, hours, days, weeks, months, years, decades, centuries
	
	var label: String {
		switch self {
		case .seconds:
			return "Seconds"
		case .minutes:
			return "Minutes"
		case .hours:
			return "Hours"
		case .days:
			return "Days"
		case .weeks:
			return "Weeks"
		case .months:
			return "Months"
		case .years:
			return "Years"
		case .decades:
			return "Decades"
		case .centuries:
			return "Centuries"
		}
	}
	
	var id: String {
		label
	}
}
