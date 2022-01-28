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
    
    private class PHASESpeaker {
        private let speaker : Speaker
        private let engine : PHASEEngine
        private let listener: PHASEListener
        private let source : PHASESource
        private var soundEvent : PHASESoundEvent?
        
        init(_ speaker : Speaker, engine: PHASEEngine, listener: PHASEListener) {
            self.speaker = speaker
            self.engine = engine
            self.listener = listener
            
            let mesh = MDLMesh.newIcosahedron(withRadius: speaker.sourceRadius, inwardNormals: false, allocator: nil)
            let shape = PHASEShape(engine: engine, mesh: mesh)
            let source = PHASESource(engine: engine, shapes: [shape])
            print("***** SituWalk: speaker transform: \(speaker.transform())")
            source.worldTransform = speaker.transform()
            self.source = source
        }
        
        private func makeSpatialPipeline() -> PHASESpatialPipeline {
            let spatialPipelineFlags : PHASESpatialPipeline.Flags = [.directPathTransmission, .lateReverb]
            let spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineFlags)!
            spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = speaker.reverbSendLevel;
            return spatialPipeline
        }
        
        private func makeDistanceModelParameters() -> PHASEDistanceModelParameters {
            let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
            distanceModelParameters.fadeOutParameters =
            PHASEDistanceModelFadeOutParameters(cullDistance: speaker.cullDistance)
            distanceModelParameters.rolloffFactor = speaker.rolloffFactor
            return distanceModelParameters
        }
        
        
        private func makeSpatialMixerDefinition(spatialPipeline : PHASESpatialPipeline, distanceModelParameters: PHASEDistanceModelParameters) -> PHASESpatialMixerDefinition {
            let spatialMixerDefinition = PHASESpatialMixerDefinition(spatialPipeline: spatialPipeline)
            spatialMixerDefinition.distanceModelParameters = distanceModelParameters
            return spatialMixerDefinition
        }
        
        private func makeSamplerNodeDefinition(spatialMixerDefinition : PHASESpatialMixerDefinition) -> PHASESamplerNodeDefinition {
            let samplerNodeDefinition = PHASESamplerNodeDefinition(
                soundAssetIdentifier: speaker.audioFile,
                mixerDefinition: spatialMixerDefinition
            )
            samplerNodeDefinition.playbackMode = .looping
            samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: speaker.referenceLevel)
            samplerNodeDefinition.cullOption = .sleepWakeAtRealtimeOffset
            return samplerNodeDefinition
        }
        
        private func makeMixerParameters(spatialMixerDefinition : PHASESpatialMixerDefinition, source: PHASESource) -> PHASEMixerParameters {
            let mixerParameters = PHASEMixerParameters()
            mixerParameters.addSpatialMixerParameters(
                identifier: spatialMixerDefinition.identifier,
                source: source, listener: listener
            )
            return mixerParameters
        }
        
        func prepare() {
            print("***** SituWalk: preparing audio file \(speaker.audioFile ) and anchor \(speaker.name ) *****")
            if (engine.assetRegistry.asset(forIdentifier: speaker.audioFile) == nil) {
                let url = Bundle.main.url(forResource: speaker.audioFile
                                          , withExtension: "mp3"
                                          , subdirectory: "sounds")!
                try! engine.assetRegistry.registerSoundAsset(
                    url: url, identifier: speaker.audioFile, assetType: .streamed,
                    channelLayout: nil, normalizationMode: .dynamic
                )
            } else {
                print("***** SituWalk: asset for audio file \(speaker.audioFile ) already added *****")
            }
            
            let spatialMixerDefinition = makeSpatialMixerDefinition(
                spatialPipeline: makeSpatialPipeline(),
                distanceModelParameters: makeDistanceModelParameters()
            )
            
            let samplerNodeDefinition = makeSamplerNodeDefinition(spatialMixerDefinition: spatialMixerDefinition)
            
            if (engine.assetRegistry.asset(forIdentifier: speaker.name) == nil) {
                try! engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: speaker.name)
            } else {
                print("***** SituWalk: sampler node for audio file \(speaker.name ) already added *****")

            }
            
            try! engine.rootObject.addChild(source)
            
            let mixerParameters = makeMixerParameters(
                spatialMixerDefinition: spatialMixerDefinition,
                source: source
            )
            
            self.soundEvent = try! PHASESoundEvent(
                engine: engine, assetIdentifier: speaker.name,
                mixerParameters: mixerParameters
            )
            self.soundEvent!.prepare()
        }
        
        func play() {
            guard let se = self.soundEvent else {
                self.prepare()
                self.play()
                return
            }
            print("***** SituWalk: playing audio file \(speaker.audioFile ) and anchor \(speaker.name ) *****")
            se.start()
        }
        
        func updatePosition(_ position : float4x4) {
            source.worldTransform = position
        }
        
        func teardown() {
            engine.assetRegistry.unregisterAsset(identifier: speaker.audioFile)
            engine.assetRegistry.unregisterAsset(identifier: speaker.name)
            engine.rootObject.removeChild(source)
        }
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
    
    private let engine: PHASEEngine!
    private let listener: PHASEListener!
    private let hmm = CMHeadphoneMotionManager()
    
    private var playingSpeakers : [String : PHASESpeaker] = [:]
    private var devicePosition: simd_float4x4 = matrix_identity_float4x4;
    private var headPosition: simd_float4x4 = matrix_identity_float4x4;
    
    override init() {
        self.engine = PHASEEngine(updateMode: .automatic)
        self.listener = PHASEListener(engine: self.engine)
        self.listener.worldTransform = matrix_identity_float4x4
    }
    
    func setup() {
        try! self.engine.rootObject.addChild(self.listener)
        self.engine.defaultReverbPreset = REVERB_PRESETS["largeRoom"]!
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
        if hmm.isDeviceMotionActive {
            hmm.stopDeviceMotionUpdates()
        }
        for speaker in self.playingSpeakers.values {
            speaker.teardown()
        }
        self.engine.rootObject.removeChild(self.listener)
    }
    
    func prepare(_ speaker: Speaker) {
        let phaseSpeaker = PHASESpeaker(speaker, engine: self.engine, listener: self.listener)
        phaseSpeaker.prepare()
        playingSpeakers[speaker.name] = phaseSpeaker
    }
    
    func play(_ speaker: Speaker) {
        let phaseSpeaker = playingSpeakers[speaker.name]
        if(phaseSpeaker != nil) {
            phaseSpeaker!.play()
        } else {
            self.prepare(speaker)
            self.play(speaker)
        }
    }
    
    func updateDevicePosition(_ position: float4x4) {
        devicePosition = position
//        listener.worldTransform = matrix_multiply(devicePosition, headPosition)
        listener.worldTransform = devicePosition
    }
    
    func updateAnchorPosition(for name : String, position : float4x4) {
        if let speaker = playingSpeakers[name] {
            speaker.updatePosition(position)
        }
    }
    
    private func updateHeadPosition(_ position : float4x4) {
        headPosition = position
        print("******* HEAD POSITION: \(position)")
//        listener.worldTransform = matrix_multiply(devicePosition,  headPosition)
        listener.worldTransform = devicePosition
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

