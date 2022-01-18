//
//  ContentView.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        print("makeUIView..........................................")

        let arView = ARView(frame: .zero)
        restartSession(arView: arView)
                
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        print("updateUIView..........................................")

        let speakers = SpeakerConfigLoader.run("speakers-config")
                
        sleep(1) // Hack to simluate a ready env. This should all likely be in a callback.
        
//        var isGeoTrackingLocalized: Bool {
//            if let status = uiView.session.currentFrame?.geoTrackingStatus, status.state == .localized {
//                return true
//            }
//            return false
//        }
//         Don't add a geo anchor if Core Location isn't sure yet where the user is.
//        guard isGeoTrackingLocalized else {
//            print("******************************************** Unable to add geo anchor because geotracking has not yet localized.")
//            return
//        }
                
        for speaker in speakers {
            uiView.session.add(anchor: speaker.geoAnchor)

            uiView.scene.addAnchor(
                SpeakerVisualiser.run(for: speaker)
            )
        }
    }
    
    func  restartSession(arView : ARView) {
        // Check geo-tracking location-based availability.
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                let errorDescription = error?.localizedDescription ?? ""
                let recommendation = "Please try again in an area where geotracking is supported."
                
//                let restartSession = UIAlertAction(title: "Restart Session", style: .default) { (_) in
//                    self.restartSession()
//                }
                print("********************************** Geotracking unavailable: \(errorDescription)\n\(recommendation)")
//                self.alertUser(withTitle: "Geotracking unavailable",
//                               message: "\(errorDescription)\n\(recommendation)",
//                               actions: [restartSession])
            }
        }
        
        // Re-run the ARKit session.
        let geoTrackingConfig = ARGeoTrackingConfiguration()
        geoTrackingConfig.planeDetection = [.horizontal]
        arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)

        arView.scene.anchors.removeAll()
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
