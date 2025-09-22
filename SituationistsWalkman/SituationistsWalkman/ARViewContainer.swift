//
//  ARViewContainer.swift
//  SituationistsWalkman
//
//  Created by Tim on 19/1/22.
//
import SwiftUI
import RealityKit
import ARKit
import AVFAudio
import AudioToolbox
import AVFoundation

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var state : AppState
    
    class Coordinator : NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate, GPXParserDelegate {
        var state : AppState!
        var arView : ARView!
        var container : ARViewContainer!
        var player: SpeakerPlayer!
        let alertPlayer: AVAudioPlayer!
        
        override init() {
            let alertURL = Bundle.main.url(forResource: "need_tracking_alert", withExtension: "mp3", subdirectory: "sounds")!
            self.alertPlayer = try! AVAudioPlayer(contentsOf: alertURL)
            alertPlayer.volume = 0.75
            super.init()
        }
        
        var speakers: [Speaker] = []
        // TODO - do we still need to track this visualEntities?
        var visualEntities: [String: AnchorEntity] = [:]
        var positionedEntities: Set<String> = []
        
        //- MARK: ARSessionDelegate
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            print("***** SituWalk: Geotracking status changed: \(geoTrackingStatus.state) *****")
            print("***** SituWalk: Accuracy: \(geoTrackingStatus.accuracy) *****")
            print("***** SituWalk: Reason: \(geoTrackingStatus.stateReason) *****")
            
            // Update UI state for field debugging (on main queue)
            DispatchQueue.main.async {
                // Decode state enum to human readable
                let stateText: String
                switch geoTrackingStatus.state {
                case .initializing:
                    stateText = "Initializing"
                case .localized:
                    stateText = "Localized ✅"
                case .localizing:
                    stateText = "Localizing..."
                case .notAvailable:
                    stateText = "Not Available ❌"
                @unknown default:
                    stateText = "Unknown(\(geoTrackingStatus.state.rawValue))"
                }
                
                // Decode reason enum to human readable
                let reasonText: String
                switch geoTrackingStatus.stateReason {
                case .none:
                    reasonText = "None"
                case .worldTrackingUnstable:
                    reasonText = "World tracking unstable"
                case .waitingForLocation:
                    reasonText = "Waiting for GPS"
                case .geoDataNotLoaded:
                    reasonText = "Geo data not loaded"
                case .visualLocalizationFailed:
                    reasonText = "Visual localization failed"
                case .waitingForAvailabilityCheck:
                    reasonText = "Checking availability"
                case .notAvailableAtLocation:
                    reasonText = "Not available at location"
                case .needLocationPermissions:
                    reasonText = "Need location permissions"
                @unknown default:
                    reasonText = "Unknown(\(geoTrackingStatus.stateReason.rawValue))"
                }
                
                self.state.geoTrackingStatus = stateText
                self.state.geoTrackingReason = reasonText
            }
            
            if geoTrackingStatus.state == .localizing && state.localized {
                print("***** SituWalk: Geotracking status: RELOCALIZING *****")
                state.localized = false
                alertPlayer.play()
            } else if geoTrackingStatus.state == .localized && !state.localized {
                print("***** SituWalk: Geotracking status LOCALIZED *****")
                state.localized = true
                
                // Test system audio after localization
                // TODO - remove me when happy with audio later
                AudioServicesPlaySystemSound(1007) // SMS sound
                print("***** SituWalk: Playing test SMS sound after localization *****")
                
                // Test non-spatial audio playback to verify files work
                // TODO - remove me (and implementation) when happy with audio later
                self.testNonSpatialAudio()
                
                for (speaker) in self.speakers {
                    print("***** SituWalk: Adding geo anchor for speaker: \(speaker.name) *****")
                    arView.session.add(anchor: speaker.geoAnchor)
                    print("***** SituWalk: Starting audio for speaker: \(speaker.name) *****")
                    player.play(speaker)
                    print("***** SituWalk: Creating visual entity for speaker: \(speaker.name) *****")
                    arView.scene.addAnchor(
                        SpeakerVisualiser.createEntity(for: speaker)
                    )
                    print("***** SituWalk: Added visual entity to scene for speaker: \(speaker.name) *****")
                }
            } else if geoTrackingStatus.state == .notAvailable {
                print("***** SituWalk: Geo tracking NOT AVAILABLE at this location *****")
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let name = anchor.name {
                    player.updateAnchorPosition(for: name, position: anchor.transform)
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let cameraTransform = frame.camera.transform

            // PHASE audio expects landscape-left orientation (cameras top-left)
            // Apply orientation-specific transform based on device orientation
            // For lanyard usage: portrait upright (onboarding) vs portrait inverted (experience)

            let orientationTransform: simd_float4x4
            let deviceOrientation = UIDevice.current.orientation

            switch deviceOrientation {
            case .portrait:
                // Portrait upright: cameras top-right -> landscape-left equivalent
                orientationTransform = simd_float4x4(
                    columns: (
                        simd_float4(0, 1, 0, 0),   // X becomes Y
                        simd_float4(-1, 0, 0, 0),  // Y becomes -X
                        simd_float4(0, 0, 1, 0),   // Z unchanged
                        simd_float4(0, 0, 0, 1)    // Translation unchanged
                    )
                )
            case .portraitUpsideDown:
                // Portrait inverted: cameras bottom-left (lanyard position) -> landscape-left equivalent
                orientationTransform = simd_float4x4(
                    columns: (
                        simd_float4(0, -1, 0, 0),  // X becomes -Y
                        simd_float4(1, 0, 0, 0),   // Y becomes X
                        simd_float4(0, 0, 1, 0),   // Z unchanged
                        simd_float4(0, 0, 0, 1)    // Translation unchanged
                    )
                )
            case .landscapeLeft:
                // Already in expected orientation (cameras top-left)
                orientationTransform = matrix_identity_float4x4
            case .landscapeRight:
                // Landscape right: cameras top-right -> landscape-left equivalent
                orientationTransform = simd_float4x4(
                    columns: (
                        simd_float4(-1, 0, 0, 0),  // X becomes -X
                        simd_float4(0, -1, 0, 0),  // Y becomes -Y
                        simd_float4(0, 0, 1, 0),   // Z unchanged
                        simd_float4(0, 0, 0, 1)    // Translation unchanged
                    )
                )
            default:
                // Fallback to portrait transform
                orientationTransform = simd_float4x4(
                    columns: (
                        simd_float4(0, 1, 0, 0),
                        simd_float4(-1, 0, 0, 0),
                        simd_float4(0, 0, 1, 0),
                        simd_float4(0, 0, 0, 1)
                    )
                )
            }

            let correctedTransform = simd_mul(cameraTransform, orientationTransform)
            player.updateDevicePosition(correctedTransform)
            
            // Debug distance to single test speaker (once per 10 seconds) - check visual entity position
            // TODO - remove this whole block when tidying up.
//            if let testSpeaker = self.speakers.first,
//               let visualEntity = visualEntities[testSpeaker.name],
//               Int(CACurrentMediaTime()) % 10 == 0 {
//                let speakerPos = visualEntity.position
//                let devicePos = position.columns.3
//                let distance = simd_distance(speakerPos, SIMD3<Float>(devicePos.x, devicePos.y, devicePos.z))
//                
//                print("***** SituWalk: Distance to \(testSpeaker.name) at \(speakerPos): \(String(format: "%.1f", distance))m *****")
//            }
        }
        
        // MARK: - ARCoachingOverlayViewDelegate
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            print("***** SituWalk: Coaching overlay requested session reset *****")
            self.container.restartSession(arView: self.arView)
        }
        
        // MARK: - GPXParserDelegate
        func parser(_ parser: GPXParser, didFinishParsingFileWithAnchors speakers: [Speaker]) {
            if speakers.isEmpty {
                print("***** SituWalk: ERROR - GPX file does not contain anchors or is invalid *****")
                DispatchQueue.main.async {
                    self.state.speakerCount = 0
                    self.state.geoTrackingReason = "No speakers loaded from GPX"
                }
                return
            }
                                    
            self.speakers = speakers
            for speaker in self.speakers {
                player.prepare(speaker)
                print("***** SituWalk: Loaded speaker: \(speaker.name) at \(speaker.lat), \(speaker.lon) *****")
                print("***** SituWalk: Speaker color: \(speaker.color) *****")
                print("***** SituWalk: Speaker audioFile: \(speaker.audioFile) *****")
                print("***** SituWalk: Speaker cullDistance: \(speaker.cullDistance) *****")
                print("***** SituWalk: Speaker referenceLevel: \(speaker.referenceLevel) *****")
            }
            print("***** SituWalk: \(speakers.count) speakers(s) loaded successfully *****")
            DispatchQueue.main.async {
                self.state.speakerCount = speakers.count
            }
        }
        
        func parseGPXFile(with url: URL) {
            print("***** SituWalk: Attempting to parse GPX file: \(url.path) *****")
            guard let parser = GPXParser(contentsOf: url) else {
                print("***** SituWalk: ERROR - Unable to open GPX file: \(url.path) *****")
                DispatchQueue.main.async {
                    self.state.speakerCount = 0
                    self.state.geoTrackingReason = "Failed to load GPX file"
                }
                return
            }
            
            parser.delegate = self
            parser.parse()
            print("***** SituWalk: GPX parsing initiated *****")
        }
        
        func testNonSpatialAudio() {
            guard let url = Bundle.main.url(forResource: "msp-cb", withExtension: "mp3", subdirectory: "sounds") else {
                print("***** SituWalk: ERROR - Could not find test audio file *****")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.5
                player.numberOfLoops = 0
                player.play()
                print("***** SituWalk: Playing non-spatial test audio: msp-cb *****")
            } catch {
                print("***** SituWalk: ERROR - Failed to play non-spatial test audio: \(error.localizedDescription) *****")
            }
        }
    } // end Coordinator class
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        // Suppress RealityKit shader warnings FIRST
        // TODO - not sure this does anything?
        setenv("OS_ACTIVITY_MODE", "disable", 1)
        setenv("OS_ACTIVITY_DT_MODE", "NO", 1)
        
        print("***** SituWalk: Creating view *****")
        
        let url = Bundle.main.url(forResource: "speakers", withExtension: "gpx")!
        
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        arView.automaticallyConfigureSession = false
        
        var player : SpeakerPlayer
        player = SpeakerPHASEPlayer(headTracking: state.headTracking)
        player.setup()
        
        context.coordinator.state = state
        context.coordinator.arView = arView
        context.coordinator.container = self
        context.coordinator.player = player
        
        context.coordinator.parseGPXFile(with: url)
        
        setupCoachingOverlay(arView: arView, context: context)
        restartSession(arView: arView)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        return arView
    }
    
    static func dismantleUIView(_ arView: ARView, coordinator: Coordinator) {
        print("***** SituWalk: Dismantling view *****")
        arView.session.pause()
        arView.removeFromSuperview()
        coordinator.player.teardown()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func restartSession(arView : ARView) {
        print("***** SituWalk: Restarting session *****")
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            DispatchQueue.main.async {
                if !available {
                    print("***** SituWalk: ERROR - Geo tracking not available at this location *****")
                    self.state.geoTrackingAvailable = "❌ NOT AVAILABLE"
                    if let error = error {
                        print("***** SituWalk: Error details: \(error.localizedDescription) *****")
                        self.state.geoTrackingError = error.localizedDescription
                    } else {
                        self.state.geoTrackingError = "No error details provided"
                    }
                    self.state.page = .outsideGeoTrackingArea
                } else {
                    print("***** SituWalk: Geo tracking available - starting session *****")
                    self.state.geoTrackingAvailable = "✅ AVAILABLE"
                    self.state.geoTrackingError = ""
                    let geoTrackingConfig = ARGeoTrackingConfiguration()
                    geoTrackingConfig.planeDetection = [.horizontal]
                    arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
                    arView.scene.anchors.removeAll()
                    self.state.geoTrackingStatus = "Starting..."
                }
            }
        }
    }
    
    func setupCoachingOverlay(arView : ARView, context : Context) {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = context.coordinator
        arView.addSubview(coachingOverlay)
        coachingOverlay.goal = .geoTracking
        coachingOverlay.session = arView.session
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
    }
}
