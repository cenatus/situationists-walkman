//
//  ARViewContainer.swift
//  SituationistsWalkman
//
//  Created by Tim on 19/1/22.
//
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var state : AppState
    
    class Coordinator : NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate {
        var arView : ARView!
        var container : ARViewContainer!
        var speakerConfig : SpeakerConfig!
        var player: SpeakerPlayer!
        private var alreadyLocalized = false;
        
        //- MARK: ARSessionDelegate
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            print("***** SituWalk: Geotracking status changed: \(geoTrackingStatus.state.rawValue) *****")
            if geoTrackingStatus.state == .localized && !alreadyLocalized {
                print("***** SituWalk: Geotracking status LOCALIZED: \(geoTrackingStatus.state.rawValue) *****")
                alreadyLocalized = true
                for speaker in speakerConfig.speakers {
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
                print("***** SituWalk: Anchor udpated: \(anchor.name ?? "unnamed") at transform: \(anchor.transform) *****")
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
            self.container.restartSession(arView: self.arView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        print("***** SituWalk: Creating view *****")
        let speakerConfig = SpeakerConfig("speakers-config");
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        arView.automaticallyConfigureSession = false
        var player : SpeakerPlayer
        if(speakerConfig.engine == "phase") {
            print("**** SituWalk: using PHASE Audio Engine ***")
            player = SpeakerPHASEPlayer(config: speakerConfig)
        } else {
            print("**** SituWalk: using Reality Kit Audio Engine ***")
            player = SpeakerRealityKitPlayer(view: arView)
        }
        
        player.setup()

        setupCoachingOverlay(arView: arView, context: context)

        context.coordinator.arView = arView
        context.coordinator.container = self
        context.coordinator.player = player
        context.coordinator.speakerConfig = speakerConfig
        
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
