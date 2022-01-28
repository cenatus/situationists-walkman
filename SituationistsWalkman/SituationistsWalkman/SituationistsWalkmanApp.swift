//
//  SituationistsWalkmanApp.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import SwiftUI
import ARKit

@main
struct SituationistsWalkmanApp: App {
    var body: some Scene {
        WindowGroup {
            if !ARGeoTrackingConfiguration.isSupported {
                MessageView(message: "unsupported-device-error", buttonText: "Try again")
            } else {
                ContentView()
            }
        }
    }
}
