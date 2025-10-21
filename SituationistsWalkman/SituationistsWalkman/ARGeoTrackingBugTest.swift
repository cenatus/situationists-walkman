//
//  ARGeoTrackingBugTest.swift
//  Minimal test case for iPadOS 26.0.1 ARGeoTrackingConfiguration.isSupported bug
//
//  Issue: ARGeoTrackingConfiguration.isSupported incorrectly returns false
//  on supported iPad models running iPadOS 26.0.1
//

import SwiftUI
import ARKit

struct ARGeoTrackingBugTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ARGeoTrackingBugTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ARGeoTrackingConfiguration Bug Test")
                .font(.title)
                .padding()

            // Device info
            VStack(alignment: .leading, spacing: 8) {
                Text("Device: \(UIDevice.current.model)")
                Text("OS: \(UIDevice.current.systemVersion)")
                Text("Model: \(getModelIdentifier())")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            // ARKit support test
            VStack(spacing: 10) {
                Text("ARKit Support Test")
                    .font(.headline)

                HStack {
                    Text("ARGeoTrackingConfiguration.isSupported:")
                    Text(ARGeoTrackingConfiguration.isSupported ? "✅ TRUE" : "❌ FALSE")
                        .foregroundColor(ARGeoTrackingConfiguration.isSupported ? .green : .red)
                        .fontWeight(.bold)
                }

                Text("Expected: TRUE for iPad Pro/Air with A12+ chip")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            Spacer()

            Text("If you see FALSE on a supported iPad with iPadOS 26.x, this confirms the bug.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .onAppear {
            logDebugInfo()
        }
    }

    private func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? "Unknown"
    }

    private func logDebugInfo() {
        print("========================================")
        print("ARGeoTrackingConfiguration Bug Test")
        print("Device: \(UIDevice.current.model)")
        print("Model: \(getModelIdentifier())")
        print("OS: \(UIDevice.current.systemVersion)")
        print("ARGeoTrackingConfiguration.isSupported: \(ARGeoTrackingConfiguration.isSupported)")
        print("========================================")
    }
}

#Preview {
    ARGeoTrackingBugTestView()
}