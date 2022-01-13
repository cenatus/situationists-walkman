//
//  ARView+CoachingOverlay.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import Foundation
import ARKit

extension ARViewController: ARCoachingOverlayViewDelegate {
    func setupCoachingOverlay() {
        print("***** in the coaching overlay setup");
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
    
    // MARK: - ARCoachingOverlayViewDelegate
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if available {
                self.delegate.didCompleteARKitGeoCoaching()
            }
            
        }
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        restartSession()
    }
}
