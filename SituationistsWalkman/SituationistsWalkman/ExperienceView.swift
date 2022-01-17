//
//  ExperienceView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI
import ARKit
import RealityKit

struct ExperienceView: View, ARViewContainerDelegate {
    @EnvironmentObject var state : AppState
    
    let playerConfig = "sounds"
    
    var player : PHASEPlayer { return  PHASEPlayer(playerConfig) }
    
    // If you're thinking of refactoring this so it's inside the player
    // class and completely transparent here, while I agree that'd be
    // vastly more aesthetically pleasing, please don't! That brings
    // back the weird deadlock/livelock/whateverlock errors it was put
    // here to solve, and i've no idea why.
//    let playerQueue = DispatchQueue(label: "phasePlayer", qos: .userInteractive)
    
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
    
    func didCompleteARKitGeoCoaching(session : ARSession, scene : RealityKit.Scene) {
        print("*****LOCALIZED!!!***")
        player.setup(session, scene: scene)
    }

    func didUpdateListenerPosition(position: float4x4) {
//        playerQueue.async { player.devicePosition = position }
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
