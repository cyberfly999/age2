//  OnboardingView.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 10.07.2026.
//

import SwiftUI

struct OnboardingView: View {
    var complete: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome!\n\nHow would you like to start?")
                .font(.title2)
                .multilineTextAlignment(.center)
            Button(action: { complete("create") }) {
                Text("Create Profile")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.75))
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            Button(action: { complete("iosUser") }) {
                Text("Use Current iOS User")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.75))
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
        }
        .padding(32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
