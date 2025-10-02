//
//  ContentView.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import SwiftUI



// MARK - ContentView

struct ContentView: View {
    @StateObject var state = AppState()
    
    var body: some View {
        VStack {
            switch state.page {
            case .intro:
                IntroView()
            case .checkingLocation:
                CheckingLocationView()
            case .locationTimeout:
                MessageView(
                    message: "location-timeout-error",
                    buttonText: "Try Again"
                )
            case .experience:
                ExperienceView()
            case .unsupportedDevice:
                MessageView(
                    message: "unsupported-device-error",
                    buttonText: "Home"
                )
            case .outsideGeoTrackingArea:
                MessageView(
                    message: "out-of-range-error",
                    buttonText: "Try again"
                )

            case .credits:
                CreditsView()
            }
        }.environmentObject(state)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
