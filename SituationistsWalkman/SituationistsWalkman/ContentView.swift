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
            case .experience:
                ExperienceView()
            case .unsupportedDevice:
                MessageView(message: "Sorry, your device is not supported!", buttonText: "Home")
            case .outsideGeoTrackingArea:
                MessageView(message: "Sorry, Geographic AR is not supported where you are.", buttonText: "Try again")
                
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
