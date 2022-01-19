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
        
        //- MARK: ARSessionDelegate
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            if geoTrackingStatus.state == .localized {
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
            self.container.restartSession(arView: self.arView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let speakerConfig = SpeakerConfig("speakers-config");
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        arView.automaticallyConfigureSession = false
        var player : SpeakerPlayer
        if(speakerConfig.engine == "phase") {
            print("**** using PHASE Audio Engine ***")
            player = SpeakerPHASEPlayer(config: speakerConfig)
        } else {
            print("**** using Reality Kit Audio Engine ***")
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
        arView.session.pause()
        arView.removeFromSuperview()
        coordinator.player.teardown()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func restartSession(arView : ARView) {
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
