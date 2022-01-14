//
//  PHASEPlayer.swift
//  TestARKitObjectDetection
//
//  Created by Tim on 11/1/22.
//

import ARKit
import Foundation
import PHASE

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
    
    func setup() {
        try! self.engine.start()
    }
    
    func teardown() {
        self.engine.stop()
    }
    
    func playSampleAtPosition(sample : String, position : float4x4) -> PHASEPlayerSound {
        let sound = sounds[sample]!
        sound.startAtPosition(position)
        return sound
    }
    
    func positionAll() {
        for (_, sound) in sounds {
            addGeoAnchor(at: CLLocationCoordinate2D(latitude: sound.lat, longitude: sound.lon))
        }

    }
    
    private func addGeoAnchor(at location: CLLocationCoordinate2D, altitude: CLLocationDistance? = nil) {
        var geoAnchor: ARGeoAnchor!
        if let altitude = altitude {
            geoAnchor = ARGeoAnchor(coordinate: location, altitude: altitude)
        } else {
            geoAnchor = ARGeoAnchor(coordinate: location)
        }
        
        addGeoAnchor(geoAnchor)
    }
    
    private func addGeoAnchor(_ geoAnchor: ARGeoAnchor) {
//        TODO MSP - I think we may still need to do this as tracking can drop at any time
        // Don't add a geo anchor if Core Location isn't sure yet where the user is.
//        guard isGeoTrackingLocalized else {
//            alertUser(withTitle: "Cannot add geo anchor", message: "Unable to add geo anchor because geotracking has not yet localized.")
//            return
//        }
//        TODO MSP
//        arView.session.add(anchor: geoAnchor)
    }
    
    private var isGeoTrackingLocalized: Bool {
//        if let status = arView.session.currentFrame?.geoTrackingStatus, status.state == .localized {
//            return true
//        }
        return false
    }
    
}
