//
//  CheckingLocationView.swift
//  SituationistsWalkman
//
//  Created by Claude Code on 1/10/25.
//

import SwiftUI

struct CheckingLocationView: View {
    @EnvironmentObject var state: AppState
    @State private var showContent = false
    @State private var isSpinning = false

    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)

            OnboardingContainer {
                VStack(spacing: 30) {

                    // Loading content - portrait optimized
                    VStack(spacing: 20) {
                        // Spinning indicator
                        Circle()
                            .trim(from: 0.25, to: 1.0)
                            .stroke(Color(highlightColor), lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isSpinning)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.8), value: showContent)

                        Text("Checking your location...")
                            .foregroundColor(Color(textColor))
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)
                    }

                    Spacer(minLength: 20)

                    // Back button in case user wants to cancel
                    Button("Back") {
                        state.page = .intro
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(textColor))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 280)
                    .background(Color(textColor).opacity(0.2))
                    .cornerRadius(12)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: showContent)
                }
                .padding(.bottom, 80) // Space for safe area
            }

            // Start location checking when view appears
            ARViewContainer()
                .opacity(0) // Hidden but still running location check
        }
        .onAppear {
            showContent = true
            isSpinning = true
        }
    }
}

struct CheckingLocationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckingLocationView()
            .environmentObject(AppState())
    }
}