//
//  CreditsView.swift
//  SituationistsWalkman
//
//  Created by Tim on 27/1/22.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var state : AppState
    @State private var showCredits = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)

            OnboardingContainer {
                VStack(spacing: 30) {

                    // Credits content - portrait optimized
                    VStack(spacing: 20) {
                        Text("app-credits")
                            .foregroundColor(Color(textColor))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)

                        Text("artist-credits")
                            .foregroundColor(Color(textColor))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)

                        Text("production-credits")
                            .foregroundColor(Color(textColor))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)

                        Text("funding-credits")
                            .foregroundColor(Color(textColor))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                    .opacity(showCredits ? 1 : 0)
                    .offset(y: showCredits ? 0 : 30)
                    .animation(.easeOut(duration: 1.0), value: showCredits)

                    Spacer(minLength: 20)

                    // Back button - portrait optimized
                    Button(action: {
                        // Return to the tab they came from (tab 3 = BlurbView with credits button)
                        state.introTabIndex = 3
                        state.page = .intro
                    }) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(Color(backgroundColor))
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 280)
                            .background(Color(textColor))
                            .cornerRadius(12)
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 40)
                    .animation(.spring().delay(1.0), value: showButton)
                }
                .padding(.bottom, 80) // Space for safe area
            }
        }
        .onAppear {
            showCredits = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showButton = true
            }
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
