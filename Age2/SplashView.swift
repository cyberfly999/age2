//  SplashView.swift
//  Age2
//
//  Created by refactor on 25.07.2026.
//
import SwiftUI

struct SplashView: View {
    @State private var rotation: Double = 0
    var rotationDuration: Double = 2.0 // Configurable speed in seconds per rotation
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                Text("Welcome to your Era")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
}

#if DEBUG
#Preview {
    SplashView(rotationDuration: 1.5)
}
#endif
