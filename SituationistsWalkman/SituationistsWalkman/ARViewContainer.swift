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

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var state : AppState
    
    class Coordinator : NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate, GPXParserDelegate {
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
        
        
        private var alreadyLocalized = false;
        
        var speakers: [Speaker] = []
        
        //- MARK: ARSessionDelegate
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            print("***** SituWalk: Geotracking status changed: \(geoTrackingStatus.state.rawValue) *****")
            if geoTrackingStatus.state == .localized && !alreadyLocalized {
                print("***** SituWalk: Geotracking status LOCALIZED: \(geoTrackingStatus.state.rawValue) *****")
                alreadyLocalized = true

                for (speaker) in self.speakers {
                    arView.session.add(anchor: speaker.geoAnchor)
                    player.play(speaker)
                    arView.scene.addAnchor(
                        SpeakerVisualiser.createEntity(for: speaker)
                    )
                }
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
            let position = frame.camera.transform
            player.updateDevicePosition(position)
        }
                
        // MARK: - ARCoachingOverlayViewDelegate
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            print("***** SituWalk: Coaching overlay requested session reset *****")
            alertPlayer.play()
            self.container.restartSession(arView: self.arView)
        }
                
        // MARK: - GPXParserDelegate
        func parser(_ parser: GPXParser, didFinishParsingFileWithAnchors speakers: [Speaker]) {
            if speakers.isEmpty {
                print("GPX file does not contain anchors or is invalid.")
                return
            }
            
            self.speakers = speakers
                        
            print("\(speakers.count) speakers(s) added.")
        }
        
        func parseGPXFile(with url: URL) {
            guard let parser = GPXParser(contentsOf: url) else {
                print("Unable to open GPX file !!!!!!!!!!!!!!!!!!!!!!!!")
                return
            }
            
            parser.delegate = self
            parser.parse()
        }
    } // end Coordinator class
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        print("***** SituWalk: Creating view *****")
       
        let url = Bundle.main.url(forResource: "speakers", withExtension: "gpx")!
        context.coordinator.parseGPXFile(with: url)
        
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        arView.automaticallyConfigureSession = false
        
        var player : SpeakerPlayer
        player = SpeakerPHASEPlayer()
        player.setup()

        setupCoachingOverlay(arView: arView, context: context)

        context.coordinator.arView = arView
        context.coordinator.container = self
        context.coordinator.player = player
        
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
            if !available {
                self.state.page = .outsideGeoTrackingArea
            } else {
                let geoTrackingConfig = ARGeoTrackingConfiguration()
                geoTrackingConfig.planeDetection = [.horizontal]
                arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
                arView.scene.anchors.removeAll()
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
