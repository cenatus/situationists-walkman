//
//  SpeakerRealityKitPlayer.swift
//  SituationistsWalkman
//
//  Created by Tim on 19/1/22.
//

import Foundation
import RealityKit
import ARKit

class SpeakerRealityKitPlayer: NSObject, SpeakerPlayer {
    
    private let view : ARView
    
    init(view: ARView) {
        self.view = view
    }
    
    func setup() {}
    
    func prepare(_ speaker: Speaker) {}
    
    func play(_ speaker: Speaker) {
        // Note: This RealityKit player is not used in the main app
        // The app uses SpeakerPHASEPlayer for spatial audio instead
        // This is just a stub to make the project compile
        print("RealityKit player not implemented - using PHASE audio instead")
    }
    
    func teardown() {}
    
    func updateDevicePosition(_ position: float4x4) {}
    
    func updateAnchorPosition(for name : String, position : float4x4) {}
    
}
