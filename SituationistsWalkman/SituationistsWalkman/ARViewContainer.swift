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
import CoreLocation

struct ARViewContainer: UIViewRepresentable {

    @EnvironmentObject var state : AppState

    // Play zone boundary polygon (counter-clockwise from SW)
    private static let playZoneBoundary = [
        CLLocationCoordinate2D(latitude: 51.54444, longitude: -0.01336), // SW
        CLLocationCoordinate2D(latitude: 51.54693, longitude: -0.00431), // SE
        CLLocationCoordinate2D(latitude: 51.55088, longitude: -0.00727), // NE
        CLLocationCoordinate2D(latitude: 51.54845, longitude: -0.01585)  // NW
    ]

    // Point-in-polygon algorithm
    private static func isInsidePlayZone(_ location: CLLocationCoordinate2D) -> Bool {
        let x = location.longitude
        let y = location.latitude
        let polygon = playZoneBoundary

        var inside = false
        var j = polygon.count - 1

        for i in 0..<polygon.count {
            let xi = polygon[i].longitude
            let yi = polygon[i].latitude
            let xj = polygon[j].longitude
            let yj = polygon[j].latitude

            if ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
                inside = !inside
            }
            j = i
        }

        return inside
    }
    
    class Coordinator : NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate, GPXParserDelegate, CLLocationManagerDelegate {
        var state : AppState!
        var arView : ARView!
        var container : ARViewContainer!
        var player: SpeakerPlayer!
        let alertPlayer: AVAudioPlayer!
        var locationManager: CLLocationManager!
        var locationTimer: Timer?
        
        override init() {
            let alertURL = Bundle.main.url(forResource: "need_tracking_alert", withExtension: "mp3", subdirectory: "sounds")!
            self.alertPlayer = try! AVAudioPlayer(contentsOf: alertURL)
            alertPlayer.volume = 0.75
            super.init()

            // Initialize location manager
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        var speakers: [Speaker] = []
        // TODO - do we still need to track this visualEntities?
        var visualEntities: [String: AnchorEntity] = [:]
        var positionedEntities: Set<String> = []
        var audioStartedSpeakers: Set<String> = []
        var lastAudioCheckTime: TimeInterval = 0
        var unpositionedAnchors: Set<String> = []
        var positionedAnchors: Set<String> = []
        
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
                // Clear all tracking sets for fresh restart
                audioStartedSpeakers.removeAll()
                unpositionedAnchors.removeAll()
                positionedAnchors.removeAll()
                print("***** SituWalk: Cleared all tracking sets for relocalization *****")
                alertPlayer.play()
            } else if geoTrackingStatus.state == .localized && !state.localized {
                print("***** SituWalk: Geotracking status LOCALIZED *****")
                state.localized = true

                // Test system audio after localization
                // TODO - remove me when happy with audio later
                AudioServicesPlaySystemSound(1256) // Pop sound - definitely works, playful
                print("***** SituWalk: Playing test pop sound after localization *****")
                
                // Test non-spatial audio playback to verify files work
                // TODO - remove me (and implementation) when happy with audio later
                self.testNonSpatialAudio()
                
                // Clear and repopulate tracking sets
                unpositionedAnchors.removeAll()
                positionedAnchors.removeAll()

                for (speaker) in self.speakers {
                    print("***** SituWalk: Adding geo anchor for speaker: \(speaker.name) *****")
                    arView.session.add(anchor: speaker.geoAnchor)
                    unpositionedAnchors.insert(speaker.name)
                    print("***** SituWalk: Audio for \(speaker.name) will start when anchor is positioned *****")
                    print("***** SituWalk: Creating visual entity for speaker: \(speaker.name) *****")
                    arView.scene.addAnchor(
                        SpeakerVisualiser.createEntity(for: speaker)
                    )
                    print("***** SituWalk: Added visual entity to scene for speaker: \(speaker.name) *****")
                }

                print("***** SituWalk: Re-localization complete - audio will restart when anchors repositioned *****")
            } else if geoTrackingStatus.state == .notAvailable {
                print("***** SituWalk: Geo tracking NOT AVAILABLE at this location *****")
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let name = anchor.name {
                    // Always update position for spatial audio
                    player.updateAnchorPosition(for: name, position: anchor.transform)

                    // Check if this anchor just got positioned for the first time
                    if unpositionedAnchors.contains(name) && anchor.transform != matrix_identity_float4x4 {
                        // Move from unpositioned to positioned
                        unpositionedAnchors.remove(name)
                        positionedAnchors.insert(name)

                        // Start audio for this newly positioned anchor
                        if let speaker = speakers.first(where: { $0.name == name }) {
                            print("***** SituWalk: Anchor positioned (\(positionedAnchors.count)/\(speakers.count)) - starting audio for: \(name) *****")
                            player.play(speaker)
                            audioStartedSpeakers.insert(name)
                        }
                    }
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
            audioStartedSpeakers.removeAll()
            unpositionedAnchors.removeAll()
            positionedAnchors.removeAll()
            print("***** SituWalk: Cleared all tracking sets for session reset *****")
            self.checkLocationAndStartSession(arView: self.arView)
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

        // MARK: - Location checking methods
        func checkLocationAndStartSession(arView: ARView) {
            print("***** SituWalk: Checking location and starting session *****")

            // Request location permission if needed
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return
            case .denied, .restricted:
                print("***** SituWalk: Location permission denied *****")
                DispatchQueue.main.async {
                    self.state.page = .outsideGeoTrackingArea
                }
                return
            case .authorizedWhenInUse, .authorizedAlways:
                break
            @unknown default:
                break
            }

            // Request current location with timeout
            locationManager.requestLocation()

            // Start timeout timer (15 seconds)
            locationTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                DispatchQueue.main.async {
                    print("***** SituWalk: Location request timed out *****")
                    self.state.page = .locationTimeout
                }
            }
        }

        // MARK: - CLLocationManagerDelegate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }

            print("***** SituWalk: Got location: \(location.coordinate.latitude), \(location.coordinate.longitude) *****")

            // Cancel timeout timer
            locationTimer?.invalidate()
            locationTimer = nil

            // Check if user is within play zone boundary
            if ARViewContainer.isInsidePlayZone(location.coordinate) {
                print("***** SituWalk: User is inside play zone - checking ARKit availability *****")
                DispatchQueue.main.async {
                    self.state.insidePlayZone = true
                }
                checkARKitAvailability()
            } else {
                print("***** SituWalk: User is outside play zone boundary *****")
                DispatchQueue.main.async {
                    self.state.insidePlayZone = false
                    self.state.page = .outsideGeoTrackingArea
                }
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("***** SituWalk: Location error: \(error.localizedDescription) *****")

            // Cancel timeout timer
            locationTimer?.invalidate()
            locationTimer = nil

            DispatchQueue.main.async {
                self.state.page = .locationTimeout
            }
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.requestLocation()
            } else if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                    self.state.page = .outsideGeoTrackingArea
                }
            }
        }

        private func checkARKitAvailability() {
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
                        self.state.locationCheckPassed = true

                        // Transition to experience view if we're currently checking location
                        if self.state.page == .checkingLocation {
                            self.state.page = .experience
                        }

                        let geoTrackingConfig = ARGeoTrackingConfiguration()
                        geoTrackingConfig.planeDetection = [.horizontal]
                        self.arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
                        self.arView.scene.anchors.removeAll()
                        self.state.geoTrackingStatus = "Starting..."
                    }
                }
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
        context.coordinator.checkLocationAndStartSession(arView: arView)
        
        UIApplication.shared.isIdleTimerDisabled = true

        // Prevent proximity sensor from turning off screen when against chest
        UIDevice.current.isProximityMonitoringEnabled = false
        
        return arView
    }
    
    static func dismantleUIView(_ arView: ARView, coordinator: Coordinator) {
        print("***** SituWalk: Dismantling view *****")
        arView.session.pause()
        arView.removeFromSuperview()
        coordinator.player.teardown()
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.isProximityMonitoringEnabled = true  // Re-enable for normal phone usage
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    

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
