//
//  ARView.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI

// MARK: - ARViewContainer

struct ARViewContainer: UIViewControllerRepresentable {
    
    let delegate: ARViewContainerDelegate
    
    typealias UIViewControllerType = ARViewController
    
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        controller.delegate = delegate
        return controller
    }
    
    func updateUIViewController(_ uiViewController:
                                ARViewContainer.UIViewControllerType, context:
                                UIViewControllerRepresentableContext<ARViewContainer>) { }
}

// MARK: - ARViewController

class ARViewController: UIViewController {
    
    let coachingOverlay = ARCoachingOverlayView()
    
    var delegate : ARViewContainerDelegate!
    
    var arView: ARView {
        return self.view as! ARView
    }
    
    override func loadView() {
        self.view = ARView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        setupCoachingOverlay()
        arView.automaticallyConfigureSession = false
        restartSession()
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    func restartSession() {
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                DispatchQueue.main.async { self.delegate.didFailARKitGeoCoaching() }
            } else {
                DispatchQueue.main.async {
                    let geoTrackingConfig = ARGeoTrackingConfiguration()
                    geoTrackingConfig.planeDetection = [.horizontal]
                    self.arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
                    self.arView.scene.anchors.removeAll()
                }
            }
        }
        
    }
    
    func setupCoachingOverlay() {
        coachingOverlay.delegate = self
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


// MARK: - ARViewDelegate

protocol ARViewContainerDelegate {
    func didCompleteARKitGeoCoaching(session: ARSession)
    func didUpdateListenerPosition(position: float4x4)
    func didFailARKitGeoCoaching()
}

//- MARK: ARSessionDelegate

extension ARViewController : ARSessionDelegate {
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        if geoTrackingStatus.state == .localized {
            DispatchQueue.main.async { self.delegate.didCompleteARKitGeoCoaching(session: self.arView.session) }
        }
    }
    
    func session(_ session: ARSession, didUpdate  frame: ARFrame) {
        DispatchQueue.main.async { self.delegate.didUpdateListenerPosition(position: frame.camera.transform) }
    }
}

// MARK: - ARCoachingOverlayViewDelegate

extension ARViewController : ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        DispatchQueue.main.async { self.restartSession() }
    }
}
