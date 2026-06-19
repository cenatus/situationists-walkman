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
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            
            TabView(selection: $state.introTabIndex) {
                QuotesView()
                    .environmentObject(state)
                    .tag(0)
                
                
                VideoPlaceholderView(currentPage: $state.introTabIndex)
                    .environmentObject(state)
                    .tag(1)

                OrientationView(currentPage: $state.introTabIndex)
                    .environmentObject(state)
                    .tag(2)

                BlurbView()
                    .environmentObject(state)
                    .tag(3)

            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
            .environmentObject(AppState())
    }
}

