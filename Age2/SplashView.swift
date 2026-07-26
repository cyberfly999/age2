//  SplashView.swift
//  Age2
//
//  Created by Vince Hehlen on 25.07.2026.
//
import SwiftUI

struct SplashView: View {
    @State private var rotation: Double = 0
    var rotationDuration: Double = 2.0 // seconds per rotation
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 32) {
                Image(systemName: "gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                            rotation = 120
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

#Preview {
	SplashView(rotationDuration: 2.0)
}
