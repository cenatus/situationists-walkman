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
            ARViewContainer()
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
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView()
    }
}
