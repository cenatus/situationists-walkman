//
//  ExperienceView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI
import ARKit
import RealityKit

struct ExperienceView: View {
    @EnvironmentObject var state : AppState
        
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            ARViewContainer()
            
            // Debug overlay for field testing
            if state.debugMode {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
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
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
            if(state.localized && !state.debugMode) {
                MessageView(
                    message: "start-experience",
                    buttonText: "Home"
                )
            }
        }
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
