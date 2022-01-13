//
//  IntroView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var state : AppState
    
    var body: some View {
        Button("Switch to ARView") {
            self.state.page = .experience
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
