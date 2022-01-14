//
//  PHASEPlayerSound.swift
//  TestARKitObjectDetection
//
//  Created by Tim on 12/1/22.
//

import Foundation
import PHASE

class PHASEPlayerSound {
    struct Config: Codable {
        let anchor_name: String
        let audio_file: String
        let debug_color: String
        let source_radius: Float
        let cull_distance: Double
        let rolloff_factor: Double
        let reverb_send_level: Double
        let reference_level: Double
    }
    
    let player : PHASEPlayer!
    let source : PHASESource!
    let soundEvent : PHASESoundEvent!
    let config : Config!
    
    let anchorName : String!
    let audioFile: String!
    let debugColor: String!
    let sourceRadius: Float!
    let cullDistance: Double!
    let rolloffFactor: Double!
    let reverbSendLevel: Double!
    let referenceLevel: Double!
    
    var position : float4x4 {
        get { return source.transform }
        set(newValue) {
            source.transform = newValue
        }
    }
    
    init(player : PHASEPlayer, config: Config) {
        self.player = player
        self.config = config
        
        self.anchorName = config.anchor_name
        self.audioFile = config.audio_file
        self.debugColor = config.debug_color
        self.sourceRadius = config.source_radius
        self.cullDistance = config.cull_distance
        self.rolloffFactor = config.rolloff_factor
        self.reverbSendLevel = config.reverb_send_level
        self.referenceLevel = config.reference_level
        
        let url = Bundle.main.url(forResource: audioFile, withExtension: "mp3")!
        
        try! player.engine.assetRegistry.registerSoundAsset(
            url: url, identifier: audioFile, assetType: .resident,
            channelLayout: nil, normalizationMode: .dynamic
        )
        
        let spatialPipelineFlags : PHASESpatialPipeline.Flags = [.directPathTransmission, .lateReverb]
        let spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineFlags)!
        spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = reverbSendLevel;
        
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters =
        PHASEDistanceModelFadeOutParameters(cullDistance: cullDistance)
        distanceModelParameters.rolloffFactor = rolloffFactor

        let spatialMixerDefinition = PHASESpatialMixerDefinition(spatialPipeline: spatialPipeline)
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters
        
        let samplerNodeDefinition = PHASESamplerNodeDefinition(
            soundAssetIdentifier: audioFile,
            mixerDefinition: spatialMixerDefinition
        )
        
        samplerNodeDefinition.playbackMode = .looping
        samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: referenceLevel)
        samplerNodeDefinition.cullOption = .sleepWakeAtRealtimeOffset
        
        try! player.engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: anchorName)
        
        let mesh = MDLMesh.newIcosahedron(withRadius: sourceRadius, inwardNormals: false, allocator: nil)
        
        let shape = PHASEShape(engine: player.engine, mesh: mesh)
        self.source = PHASESource(engine: player.engine, shapes: [shape])
        self.source.transform = matrix_identity_float4x4
        try! player.engine.rootObject.addChild(source)
        
        let mixerParameters = PHASEMixerParameters()
        mixerParameters.addSpatialMixerParameters(
            identifier: spatialMixerDefinition.identifier,
            source: source, listener: player.listener
        )

        self.soundEvent = try! PHASESoundEvent(
            engine: player.engine, assetIdentifier: anchorName,
            mixerParameters: mixerParameters
        )
    }
        
    func startAtPosition(_ position: float4x4) {
        self.position = position
        soundEvent.start()
    }
}
