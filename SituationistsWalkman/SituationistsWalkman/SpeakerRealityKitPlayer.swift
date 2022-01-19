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
    
    func play(_ speaker: Speaker) {
        let audio1 = try! AudioFileResource.load(named: "\(speaker.audioFile!).mp3")
        audio1.shouldLoop = true
        let entity = AnchorEntity(anchor: speaker.geoAnchor)
        view.scene.addAnchor(entity)
        entity.playAudio(audio1)
    }
    
    func teardown() {}
    
    func updateDevicePosition(_ position: float4x4) {}
    
    func updateAnchorPosition(for name : String, position : float4x4) {}
    
}
