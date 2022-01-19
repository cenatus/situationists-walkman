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
    
    
    let  speakerConfig = SpeakerConfig("speakers-config");
    //var player : SpeakerPlayer { return SpeakerPlayer(speakerConfig) }
    
    class Coordinator : NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate {
        var arView : ARView!
        var container : ARViewContainer!
        //var player: SpeakerPlayer!
        
        //- MARK: ARSessionDelegate
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            if geoTrackingStatus.state == .localized {
                // FYI MSP here's the entry point to the speaker adding stuff
                for speaker in container.speakerConfig.speakers {
                    arView.session.add(anchor: speaker.geoAnchor)
                    //player.play(speaker)
                    arView.scene.addAnchor(
                        SpeakerVisualiser.createEntity(for: speaker)
                    )
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            //let position = frame.camera.transform
            //container.player.devicePosition = position
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
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        setupCoachingOverlay(arView: arView, context: context)
        arView.automaticallyConfigureSession = false
        context.coordinator.arView = arView
        context.coordinator.container = self
        //context.coordinator.player = player
        restartSession(arView: arView)
        //player.setup()
        UIApplication.shared.isIdleTimerDisabled = true
        return arView
    }
    
    static func dismantleUIView(_ arView: ARView, coordinator: Coordinator) {
        arView.session.pause()
        // this is a static method so we have to get the ref from the coordinator
        // as we don't have access to self. TODO factor this better.
        //coordinator.player.teardown()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // FYI MSP - this all now goes in the callback where it needs to be to
        // not have to do the sleep(1)
    }
    
    func  restartSession(arView : ARView) {
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
