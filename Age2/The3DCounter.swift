
import SwiftUI


struct The3DCounter: View {
	@State private var count = 0

	var body: some View {
		VStack(spacing: 20) {
			ZStack {
				Text("\(count)")
					.font(.system(size: 100, weight: .bold))
					.rotation3DEffect(
						.degrees(Double(count * 360)),
						axis: (x: 1.0, y: 0.0, z: 0.0)
					)
					.animation(.spring(response: 0.9, dampingFraction: 0.7), value: count)
			}
			.frame(height: 120)

			Button("Increment") {
				count += 1
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

// MARK: - Preview

#Preview {
	return The3DCounter()
}
