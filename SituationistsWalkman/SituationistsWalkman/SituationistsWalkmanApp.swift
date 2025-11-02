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

        let shouldBlock = !isSupported

        // Debug logging for App Store review
        let _ = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let modelIdentifier = String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? "Unknown"

            print("========================================")
            print("🔍 ARKit Debug Info:")
            print("   Device: \(deviceModel)")
            print("   Model ID: \(modelIdentifier)")
            print("   iOS/iPadOS: \(systemVersion)")
            print("   ARGeoTrackingConfiguration.isSupported: \(isSupported)")
            print("   Blocking Access: \(shouldBlock)")
            print("========================================")
        }()

        if shouldBlock {
            MessageView(message: "unsupported-device-error", buttonText: "Try again")
        } else {
            ContentView()
        }
    }
}
