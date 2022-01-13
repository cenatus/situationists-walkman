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
                ErrorView(message: "Sorry, your device is not supported!")
            case .outsideGeoTrackingArea:
                ErrorView(message: "Sorry, Geographic AR is not supported where you are.")
            }
        }.environmentObject(state)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
