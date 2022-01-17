//
//  ExperienceView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI
import ARKit

// TODO: integrate CMHeadphoneMotionManager and implement its delegate folowing exmpl in Tim's spike, IFF supported (this could even be made part of the PhasePlayer itself tbh).

struct ExperienceView: View, ARViewContainerDelegate {
    @EnvironmentObject var state : AppState
    
    let playerConfig = "sounds"
    
    var player : PHASEPlayer { return  PHASEPlayer(playerConfig) }
    
    var body: some View {
        ZStack {
            ARViewContainer(delegate: self)
            VStack {
                Spacer()
                Spacer()
                Button("Home") {
                    self.state.page = .intro
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white).opacity(0.7))
            }
        }
    }
    
    // MARK: - ARViewContainerDelegate
    
    func didCompleteARKitGeoCoaching(session : ARSession) {
        print("*****LOCALIZED!!!***")
        player.setup(session)
        // TODO: something to render the debug spheres
    }

    func didUpdateListenerPosition(position: float4x4) {
        player.devicePosition = position
    }
    
    func didFailARKitGeoCoaching() {
        state.page = .outsideGeoTrackingArea
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
