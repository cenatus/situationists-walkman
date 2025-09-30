//
//  IntroView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var state : AppState
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                QuotesView()
                    .environmentObject(state)
                    .tag(0)
                
                
                VideoPlaceholderView(currentPage: $currentPage)
                    .environmentObject(state)
                    .tag(1)

                BlurbView()
                    .environmentObject(state)
                    .tag(2)

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

