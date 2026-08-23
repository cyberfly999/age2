//
//  CloudShape.swift
//  ThisIsMyAge
//
//  Created by Vinzenz Hehlen on 27.09.2025.
//

import SwiftUI

// MARK: - Cloud Shape -------------------------------------------------------
/// A very simple “cloud” shape made from a few overlapping ellipses.
struct CloudShape: Shape {
	func path(in rect: CGRect) -> Path {
		var p = Path()

		// Main body
		let mainRect = CGRect(x: rect.width * 0.3,
							  y: rect.height * 0.4,
							  width: rect.width * 0.6,
							  height: rect.height * 0.4)
		p.addEllipse(in: mainRect)

		// Left puff
		let leftRect = CGRect(x: rect.width * 0.1,
							  y: rect.height * 0.5,
							  width: rect.width * 0.4,
							  height: rect.height * 0.3)
		p.addEllipse(in: leftRect)

		// Right puff
		let rightRect = CGRect(x: rect.width * 0.5,
							   y: rect.height * 0.5,
							   width: rect.width * 0.4,
							   height: rect.height * 0.3)
		p.addEllipse(in: rightRect)

		return p
	}
}

// MARK: - Cloud View --------------------------------------------------------

/// A single cloud that moves from left → right across the screen.
struct MovingCloud: View {
	// MARK: Public API
	let color: Color          // Base colour of the cloud
	let size: CGFloat         // Width of the cloud (height is proportional)
	let speed: Double         // Seconds to cross the screen
	let verticalOffset: CGFloat  // Y‑position offset

	// MARK: Private state
	@State private var xOffset: CGFloat? = nil

	var body: some View {
		GeometryReader { geometry in
			CloudShape()
				.fill(
					LinearGradient(gradient: Gradient(colors: [
						color.opacity(0.8),
						color.opacity(0.4)
					]), startPoint: .topLeading, endPoint: .bottomTrailing)
				)
				.frame(width: size, height: size * 0.6)   // Cloud is a bit taller than wide
				.blur(radius: 10)
				.shadow(color: color.opacity(0.3), radius: 20, x: 5, y: 5)
				.offset(x: xOffset ?? -geometry.size.width, y: verticalOffset)
				.onAppear {
					// Animate from left → right forever
					if xOffset == nil {
						xOffset = -geometry.size.width
						withAnimation(
							Animation.linear(duration: speed)
								.repeatForever(autoreverses: false)
						) {
							xOffset = geometry.size.width
						}
					}
				}
		}
	}
}

// MARK: - Cloud Background --------------------------------------------------

/// A full‑screen animated cloud background.
struct CloudBackgroundView: View {
	// MARK: Configuration
	private let numberOfClouds = 6

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				// ---------- Background gradient ----------
				LinearGradient(
					gradient: Gradient(colors: [
						Color.blue.opacity(0.45),
						Color.purple.opacity(0.55)
					]),
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.ignoresSafeArea()

				// ---------- Clouds ----------
				ForEach(0..<numberOfClouds, id: \.self) { index in
					MovingCloud(
						color: Helpers.randomColor(),
						size: CGFloat.random(in: 200...400),
						speed: Double.random(in: 15...40),
						verticalOffset: randomVerticalPosition(containerHeight: geometry.size.height)
					)
				}
			}
		}
	}

	private func randomVerticalPosition(containerHeight: CGFloat) -> CGFloat {
		// Keep clouds within the top 70 % of the available height
		let maxY = containerHeight * 0.7
		return CGFloat.random(in: -maxY/2 ... maxY/2)
	}
}
