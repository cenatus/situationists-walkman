//
//  PHASEPlayer.swift
//  TestARKitObjectDetection
//
//  Created by Tim on 11/1/22.
//

import Foundation
import PHASE
import ARKit
import CoreMotion

class PHASEPlayer {
    
    struct Config: Codable {
        let reverb_preset: String
        let sounds : [PHASEPlayerSound.Config]
    }
    
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
    
    let engine: PHASEEngine!
    let listener: PHASEListener!
    let hmm = CMHeadphoneMotionManager()
    
    var sounds: [String : PHASEPlayerSound] = [:]
    
    private var _devicePosition: simd_float4x4 = matrix_identity_float4x4;
    private var _headPosition: simd_float4x4 = matrix_identity_float4x4;
    
    var listenerPosition : simd_float4x4 {
        get { return listener.transform }
    }
    
    var devicePosition : simd_float4x4 {
        get { return _devicePosition }
        set(position) {
            _devicePosition = position
            listener.transform = matrix_multiply(_devicePosition, _headPosition)
        }
    }
    
    var headPosition: simd_float4x4 {
        get { return _headPosition }
        set(position) {
            _headPosition = position
            listener.transform = matrix_multiply(_devicePosition,  _headPosition)
        }
    }
    
    init(_ configFileName : String) {
        self.engine = PHASEEngine(updateMode: .automatic)
        self.listener = PHASEListener(engine: self.engine)
        self.listener.transform = matrix_identity_float4x4
        try! self.engine.rootObject.addChild(self.listener)
        
        let path = Bundle.main.path(forResource: configFileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let config = try! decoder.decode(Config.self, from: data)
        
        self.engine.defaultReverbPreset = REVERB_PRESETS[config.reverb_preset]!
        
        for soundConfig in config.sounds {
            sounds[soundConfig.anchor_name] = PHASEPlayerSound(player: self, config: soundConfig)
        }
    }
    
    func setup(_ session : ARSession) {
        try! self.engine.start()
        for (_, sound) in sounds {
            sound.locateAndStart(session: session)
        }
        if hmm.isDeviceMotionAvailable {
            hmm.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error in
                 guard let motion = motion, error == nil else { return }
                 self?.headPosition = motion.attitude.rotationMatrix.toFloat4x4()
             })
        }
        
    }
    
    func teardown() {
        self.engine.stop()
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
