//
//  ContentView.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import SwiftUI

// MARK - ContentView

struct ContentView: View {
    @State var page = "Home"
    
    var body: some View {
        VStack {
            if page == "Home" {
                Button("Switch to ARView") {
                    self.page = "ARView"
                }
            } else if page == "ARView" {
                ZStack {
                    ARView()
                    VStack {
                        Spacer()
                        Spacer()
                        Button("Home") {
                            self.page = "Home"
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color.white).opacity(0.7))
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
