//
//  OrientationView.swift
//  SituationistsWalkman
//
//  Created by Claude Code on 1/10/25.
//

import SwiftUI

struct OrientationView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var state: AppState
    @State private var showContent = false

    // Eastcross Bridge coordinates for Apple Maps (start point)
    private let eastcrossBridgeCoordinate = "51.54597,-0.0169"

    var body: some View {
        OnboardingContainer {
            VStack(spacing: 5) {

                // Orientation content - portrait optimized
                VStack(spacing: 20) {
//                    Text("Ready to explore?")
//                        .foregroundColor(Color(textColor))
//                        .font(.title2)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .multilineTextAlignment(.center)
//                        .opacity(showContent ? 1 : 0)
//                        .animation(.easeOut(duration: 0.8), value: showContent)

                    // Location photo
                    Image("eastcross-bridge")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: 340)
                        .cornerRadius(12)
                        .clipped()
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.9)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)

                    Text("Head to **Eastcross Bridge** in the Olympic Park to begin the experience.")
                        .foregroundColor(Color(textColor))
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)

                    Text("Once you're there, the app will detect your location and guide you through getting started.")
                        .foregroundColor(Color(textColor))
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.9), value: showContent)
                }

                Spacer(minLength: 10)

                // Navigation buttons - portrait optimized
                VStack(spacing: 12) {
                    Button("Get Directions") {
                        // Open Apple Maps with Eastcross Bridge location
                        let mapsURL = "maps://maps.apple.com/?q=Eastcross+Bridge,+Queen+Elizabeth+Olympic+Park&ll=\(eastcrossBridgeCoordinate)"
                        if let url = URL(string: mapsURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(Color(backgroundColor))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 280)
                    .background(Color(highlightColor))
                    .cornerRadius(12)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring().delay(1.0), value: showContent)

                    Button("Continue") {
                        print("Continue to final tab button tapped")
                        currentPage = 3 // Go to BlurbView (final tab)
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(textColor))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 280)
                    .background(Color(textColor).opacity(0.2))
                    .cornerRadius(12)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring().delay(1.2), value: showContent)
                }
            }
            .padding(.bottom, 80) // Space for tab dots
        }
        .onAppear {
            showContent = true
        }
    }
}

struct OrientationView_Previews: PreviewProvider {
    static var previews: some View {
        OrientationView(currentPage: .constant(2))
            .environmentObject(AppState())
    }
}
