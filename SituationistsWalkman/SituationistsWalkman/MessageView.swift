//
//  MessageView.swift
//  SituationistsWalkman
//
//  Created by Tim on 28/1/22.
//
import SwiftUI

struct MessageView: View {
    @EnvironmentObject var state : AppState

    let message : LocalizedStringKey
    var buttonText = "Back"

    // Eastcross Bridge coordinates for Apple Maps (start point)
    private let eastcrossBridgeCoordinate = "51.54597,-0.0169"
    
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)

            OnboardingContainer {
                VStack(spacing: 30) {

                    // Message content - portrait optimized
                    Text(message)
                        .foregroundColor(Color(textColor))
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 20)

                    // Buttons - portrait optimized
                    VStack(spacing: 12) {
                        // Show special buttons for out-of-range error
                        if message == "out-of-range-error" {
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

                            Button(buttonText) {
                                self.state.page = .intro
                                self.state.localized = false
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(textColor))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 280)
                            .background(Color(textColor).opacity(0.2))
                            .cornerRadius(12)
                        } else {
                            Button(buttonText) {
                                self.state.page = .intro
                                self.state.localized = false
                            }
                            .font(.headline)
                            .foregroundColor(Color(backgroundColor))
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 280)
                            .background(Color(textColor))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.bottom, 80) // Space for safe area
            }
            
            // Debug overlay for field testing - only show after both location and boundary checks pass
            if state.debugMode && state.locationCheckPassed && state.insideOlympicPark {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Coverage: \(state.geoTrackingAvailable)")
                                .foregroundColor(state.geoTrackingAvailable.contains("✅") ? .green : .red)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            Text("Status: \(state.geoTrackingStatus)")
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            Text("Speakers: \(state.speakerCount)")
                                .foregroundColor(.green)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            if !state.geoTrackingReason.isEmpty {
                                Text("Reason: \(state.geoTrackingReason)")
                                    .foregroundColor(.yellow)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                            }
                            if !state.geoTrackingError.isEmpty {
                                Text("Error: \(state.geoTrackingError)")
                                    .foregroundColor(.red)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: "This is a test message.")
    }
}
