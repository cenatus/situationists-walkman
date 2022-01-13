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

class ARViewController: UIViewController, ARSessionDelegate {
    
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
        //locationManager.delegate = self
        arView.automaticallyConfigureSession = false
        restartSession()
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
        //locationManager.stopUpdatingLocation()
    }
    
    func restartSession() {
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                self.delegate.didFailARKitGeoCoaching()
            }
        }
    }

    
    // MARK: - ARSessionDelegate
}


// MARK: - ARViewDelegate
protocol ARViewContainerDelegate {
    func didCompleteARKitGeoCoaching()
    func didFailARKitGeoCoaching()
}
