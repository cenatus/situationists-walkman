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
            ContentViewWrapper()
                .environmentObject(appState)
        }
    }
}

struct ContentViewWrapper: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let isSupported = ARGeoTrackingConfiguration.isSupported
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion

        // Block iPadOS 26.x due to ARKit geo-tracking system bug until Apple fixes
        let isiPadOS26 = systemVersion.hasPrefix("26.")
        let shouldBlock = !isSupported || isiPadOS26

        // Debug logging for App Store review
        let _ = {
            print("========================================")
            print("🔍 ARKit Debug Info:")
            print("   Device: \(deviceModel)")
            print("   iOS/iPadOS: \(systemVersion)")
            print("   ARGeoTrackingConfiguration.isSupported: \(isSupported)")
            print("   iPadOS 26.x Detected: \(isiPadOS26)")
            print("   Blocking Access: \(shouldBlock)")
            print("========================================")
        }()

        if shouldBlock {
            // Show specific message for iPadOS 26.x vs general unsupported device
            if isiPadOS26 {
                MessageView(message: "ipados26-error", buttonText: "Try again")
            } else {
                MessageView(message: "unsupported-device-error", buttonText: "Try again")
            }
        } else {
            ContentView()
        }
    }
}
