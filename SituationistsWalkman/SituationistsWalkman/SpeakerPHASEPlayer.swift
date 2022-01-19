//
//  SpeakerPHASEPlayer.swift
//  SituationistsWalkman
//
//  Created by Tim on 19/1/22.
//

import Foundation
import PHASE
import ARKit
import CoreMotion
import RealityKit

class SpeakerPHASEPlayer : NSObject, SpeakerPlayer {
    
    // kinda amazed you can't just look up in an enum by string directly, but ¯\_(ツ)_/¯
    let REVERB_PRESETS : [String :PHASEReverbPreset] = Dictionary.init(uniqueKeysWithValues: [
        ("cathedral", PHASEReverbPreset.cathedral),
        ("largeHall", PHASEReverbPreset.largeHall),
        ("largeHall2", PHASEReverbPreset.largeHall2),
        ("largeChamber", PHASEReverbPreset.largeChamber),
        ("largeRoom", PHASEReverbPreset.largeRoom),
        ("largeRoom2", PHASEReverbPreset.largeRoom2),
        ("mediumHall", PHASEReverbPreset.mediumHall),
        ("mediumHall2", PHASEReverbPreset.mediumHall2),
        ("mediumHall3", PHASEReverbPreset.mediumHall3),
        ("mediumChamber", PHASEReverbPreset.mediumChamber),
        ("mediumRoom", PHASEReverbPreset.mediumRoom),
        ("smallRoom", PHASEReverbPreset.smallRoom),
        ("none", PHASEReverbPreset.none)
    ])
    
    let config: SpeakerConfig!
    let engine: PHASEEngine!
    let listener: PHASEListener!
    let hmm = CMHeadphoneMotionManager()
    
    private var devicePosition: simd_float4x4 = matrix_identity_float4x4;
    private var headPosition: simd_float4x4 = matrix_identity_float4x4;
    
    init(_ config: SpeakerConfig) {
        self.config = config
        self.engine = PHASEEngine(updateMode: .automatic)
        self.listener = PHASEListener(engine: self.engine)
        self.listener.transform = matrix_identity_float4x4
    }
    
    func setup() {
        try! self.engine.rootObject.addChild(self.listener)
        self.engine.defaultReverbPreset = REVERB_PRESETS[config.reverbPreset]!
        try! self.engine.start()
        if hmm.isDeviceMotionAvailable {
            hmm.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error in
                guard let motion = motion, error == nil else { return }
                let position = motion.attitude.rotationMatrix.toFloat4x4()
                self?.updateHeadPosition(position)
            })
        }
        
    }
    
    func teardown() {
        self.engine.stop()
    }
    
    func play(_ speaker: Speaker) {
        /*speaker.play(on: self) */
    }
    
    func updateDevicePosition(_ position: float4x4) {
        devicePosition = position
        listener.transform = matrix_multiply(devicePosition, headPosition)
    }
    
    private func updateHeadPosition(_ position : float4x4) {
        headPosition = position
        listener.transform = matrix_multiply(devicePosition,  headPosition)
    }
}

extension CMRotationMatrix {
    func toFloat4x4() -> float4x4 {
        let m = self
        let x = SIMD4(Float(m.m11), Float(m.m21), Float(m.m31), 0)
        let y = SIMD4(Float(m.m12), Float(m.m22), Float(m.m32), 0)
        let z = SIMD4(Float(m.m13), Float(m.m23), Float(m.m33), 0)
        let w = SIMD4(Float(0), Float(0), Float(0), Float(1))
        return simd_float4x4(columns: (x, y, z, w))
    }
}

