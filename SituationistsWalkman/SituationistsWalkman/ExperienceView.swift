//
//  ExperienceView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI

// TODO: integrate CMHeadphoneMotionManager and implement its delegate folowing exmpl in Tim's spike, IFF supported (this could even be made part of the PhasePlayer itself tbh).

struct ExperienceView: View, ARViewContainerDelegate {
    @EnvironmentObject var state : AppState
 
    var body: some View {
        ZStack {
            ARViewContainer(delegate: self)
            VStack {
                Spacer()
                Spacer()
                Button("Home") {
                    self.state.page = .intro
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white).opacity(0.7))
            }
        }
    }
    
    // MARK: - ARViewContainerDelegate
    
    func didCompleteARKitGeoCoaching() {
        print("***** LOCALIZED!!! ***")
        Experience.setup()
        
        Experience.start()
    }
    func didFailARKitGeoCoaching() {
        state.page = .outsideGeoTrackingArea
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
