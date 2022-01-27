//
//  ExperienceOverlayView.swift
//  SituationistsWalkman
//
//  Created by Tim on 27/1/22.
//

import SwiftUI

struct ExperienceOverlayView: View {
    @EnvironmentObject var state : AppState
    
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            Text("LOL")
                .padding()
            if(!self.state.started) {
                Button("START") {
                    self.state.started = true
                }
                .padding(.all)
                .background(Color(textColor))
                .foregroundColor((Color(backgroundColor)))
            }
        }
    }
}

struct ExperienceOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
