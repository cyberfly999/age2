//
//  AnimatedDigitView.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 14.08.2026.
//

import SwiftUI
internal import Combine

struct AnimatedDigitView: View {
	@State private var displayedDigit: Int = 0
	@State private var rotation: Double = 0
	@State private var wobblePhase: Double = 0
	@State private var fontSize: CGFloat = 62
	var digit: Int
	
	var body: some View {
		Text("\(displayedDigit)")
			.font(Font.system(size: fontSize, weight: .light, design: .default))
			.foregroundColor(.white)
			.frame(width: 41, height: 80)
			.rotation3DEffect(
				.degrees(sin(wobblePhase) * 8),
				axis: (x: 1, y: 1, z: 1),
				perspective: 3
			)
			.rotation3DEffect(
				.degrees(rotation),
				axis: (x: 1, y: 0, z: 0),
				perspective: 1.5
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
			.onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { _ in
				wobblePhase += 0.04
			}

	}
}

