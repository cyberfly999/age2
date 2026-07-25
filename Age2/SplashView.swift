//  SplashView.swift
//  Age2
//
//  Created by refactor on 25.07.2026.
//
import SwiftUI

struct SplashView: View {
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
                Text("Welcome to Age2")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
}

#if DEBUG
#Preview {
    SplashView()
}
#endif
