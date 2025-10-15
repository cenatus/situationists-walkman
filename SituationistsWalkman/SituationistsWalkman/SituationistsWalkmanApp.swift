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
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if !ARGeoTrackingConfiguration.isSupported {
                MessageView(message: "unsupported-device-error", buttonText: "Try again")
                    .environmentObject(appState)
            } else {
                ContentView()
                    .environmentObject(appState)
            }
        }
    }
}
