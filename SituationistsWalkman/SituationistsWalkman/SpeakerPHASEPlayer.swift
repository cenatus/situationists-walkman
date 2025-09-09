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
import AVFoundation
import AudioToolbox

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
            // this should be read from the GPX file referenceLevel field
            spatialMixerDefinition.gain = 0.8  // Set explicit gain to fix volume routing
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
                guard let url = Bundle.main.url(forResource: speaker.audioFile, withExtension: "mp3", subdirectory: "sounds") else {
                    print("***** SituWalk: ERROR - Audio file not found: \(speaker.audioFile).mp3 *****")
                    return
                }
                
                do {
                    try engine.assetRegistry.registerSoundAsset(
                        url: url, identifier: speaker.audioFile, assetType: .streamed,
                        channelLayout: nil, normalizationMode: .dynamic
                    )
                    print("***** SituWalk: Successfully registered sound asset: \(speaker.audioFile) *****")
                } catch {
                    print("***** SituWalk: ERROR - Failed to register sound asset \(speaker.audioFile): \(error.localizedDescription) *****")
                    return
                }
            } else {
                print("***** SituWalk: asset for audio file \(speaker.audioFile ) already added *****")
            }
            
            // TODO - do we still need this?
            let spatialMixerDefinition = makeSpatialMixerDefinition(
                spatialPipeline: makeSpatialPipeline(),
                distanceModelParameters: makeDistanceModelParameters()
            )
            
            let samplerNodeDefinition = makeSamplerNodeDefinition(spatialMixerDefinition: spatialMixerDefinition)
            
            if (engine.assetRegistry.asset(forIdentifier: speaker.name) == nil) {
                do {
                    try engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: speaker.name)
                    print("***** SituWalk: Successfully registered sound event asset: \(speaker.name) *****")
                } catch {
                    print("***** SituWalk: ERROR - Failed to register sound event asset \(speaker.name): \(error.localizedDescription) *****")
                    return
                }
            } else {
                print("***** SituWalk: sampler node for audio file \(speaker.name ) already added *****")
            }
            
            do {
                try engine.rootObject.addChild(source)
                print("***** SituWalk: Successfully added source to engine for: \(speaker.name) *****")
            } catch {
                print("***** SituWalk: ERROR - Failed to add source to engine for \(speaker.name): \(error.localizedDescription) *****")
                return
            }
            
            let mixerParameters = makeMixerParameters(
                spatialMixerDefinition: spatialMixerDefinition,
                source: source
            )
            
            do {
                self.soundEvent = try PHASESoundEvent(
                    engine: engine, assetIdentifier: speaker.name,
                    mixerParameters: mixerParameters
                )
                
                self.soundEvent!.prepare()
                print("***** SituWalk: Successfully prepared sound event for: \(speaker.name) *****")
            } catch {
                print("***** SituWalk: ERROR - Failed to create/prepare sound event for \(speaker.name): \(error.localizedDescription) *****")
                return
            }
        }
        
        func play() {
            guard let se = self.soundEvent else {
                print("***** SituWalk: Sound event not prepared, preparing now for: \(speaker.name) *****")
                self.prepare()
                self.play()
                return
            }
            print("***** SituWalk: playing audio file \(speaker.audioFile ) and anchor \(speaker.name ) *****")
            
            do {
                try se.start()
                print("***** SituWalk: Successfully called se.start() for: \(speaker.name) *****")
                
                // Test if we can call start again (should fail if already playing)
                // TODO - do we need this restart block?
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    do {
                        try se.start()
                        print("***** SituWalk: WARNING - Second start() call succeeded (shouldn't happen) *****")
                    } catch {
                        print("***** SituWalk: Good - Second start() failed as expected: \(error.localizedDescription) *****")
                    }
                }
            } catch {
                print("***** SituWalk: ERROR - Failed to start audio playback for \(speaker.name): \(error.localizedDescription) *****")
            }
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
    private let headTracking: Bool!
    
    private var playingSpeakers : [String : PHASESpeaker] = [:]
    private var devicePosition: simd_float4x4 = matrix_identity_float4x4;
    private var headPosition: simd_float4x4 = matrix_identity_float4x4;
    
    init(headTracking: Bool = false) {
        // Configure audio session BEFORE creating PHASE engine - try playAndRecord for iOS 18 compatibility
        // TODO - do we still need to do this?
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: [])
            print("***** SituWalk: Audio session configured with playAndRecord category *****")
        } catch {
            print("***** SituWalk: ERROR - Failed to configure audio session in init: \(error.localizedDescription) *****")
        }
        
        // Try automatic mode first, fallback to manual if needed
        do {
            self.engine = PHASEEngine(updateMode: .automatic)
            print("***** SituWalk: PHASE engine created with automatic update mode *****")
        } catch {
            print("***** SituWalk: Automatic mode failed, trying manual mode: \(error.localizedDescription) *****")
            self.engine = PHASEEngine(updateMode: .manual)
            print("***** SituWalk: PHASE engine created with manual update mode *****")
        }
        
        self.listener = PHASEListener(engine: self.engine)
        self.listener.worldTransform = matrix_identity_float4x4
        self.headTracking = headTracking
    }
    
    func setup() {
        print("***** SituWalk: Setting up PHASE audio engine *****")
        
        // Audio session already configured in init() - just log current state
        // TODO - do we still need to config an AVAudioSession?
        let audioSession = AVAudioSession.sharedInstance()
        print("***** SituWalk: Audio session route: \(audioSession.currentRoute) *****")
        print("***** SituWalk: Audio session sample rate: \(audioSession.sampleRate) *****")
        print("***** SituWalk: Audio session output volume: \(audioSession.outputVolume) *****")
        
        do {
            try self.engine.rootObject.addChild(self.listener)
            print("***** SituWalk: Added listener to engine root object *****")
        } catch {
            print("***** SituWalk: ERROR - Failed to add listener to engine: \(error.localizedDescription) *****")
        }
        
        self.engine.defaultReverbPreset = REVERB_PRESETS["largeRoom"]!
        print("***** SituWalk: Set default reverb preset *****")
        
        do {
            try self.engine.start()
            print("***** SituWalk: PHASE engine started successfully *****")
            
            // Try restarting after a brief delay to fix volume routing
            // TODO - do we need to execute this restart?
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("***** SituWalk: Attempting PHASE engine restart to fix volume routing *****")
                do {
                    self.engine.pause()
                    try self.engine.start()
                    print("***** SituWalk: PHASE engine restarted successfully *****")
                } catch {
                    print("***** SituWalk: ERROR - Failed to restart PHASE engine: \(error.localizedDescription) *****")
                }
            }
        } catch {
            print("***** SituWalk: ERROR - Failed to start PHASE engine: \(error.localizedDescription) *****")
            print("***** SituWalk: ERROR - Error code: \(error._code) *****")
        }
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
        if(headTracking) {
            listener.worldTransform = matrix_multiply(devicePosition, headPosition)
        } else {
            listener.worldTransform = devicePosition
        }
    }
    
    func updateAnchorPosition(for name : String, position : float4x4) {
        if let speaker = playingSpeakers[name] {
            speaker.updatePosition(position)
        }
    }
    
    private func updateHeadPosition(_ position : float4x4) {
        if(headTracking) {
            headPosition = position
            listener.worldTransform = matrix_multiply(devicePosition,  headPosition)
        }
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

