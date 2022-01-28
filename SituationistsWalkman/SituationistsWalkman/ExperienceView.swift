//
//  ExperienceView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI
import ARKit
import RealityKit

struct ExperienceView: View {
    @EnvironmentObject var state : AppState
        
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            ARViewContainer()
            if(state.localized && !state.debugMode) {
                MessageView(
                    message: "start-experience",
                    buttonText: "Home"
                )
            }
        }
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
