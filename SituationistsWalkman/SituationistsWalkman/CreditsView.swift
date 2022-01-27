//
//  IntroView.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var state : AppState
    
    var body: some View {
        ZStack {
            Color(backgroundColor).edgesIgnoringSafeArea(.all)
            HStack {
                VStack(alignment: .leading) {
                    Text("app-title")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color(highlightColor))
                    Spacer()
                }.padding(.trailing)
                VStack(alignment: .center) {
                    Text("app-credits")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    Text("artist-credits")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    Text("production-credits")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    Text("funding-credits")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }.padding(.trailing)
                VStack(alignment: .trailing) {
                    Spacer()
                    Button("Back") {
                        self.state.page = .intro
                    }
                    .padding(.all)
                    .frame(maxWidth: .infinity)
                    .background(Color(textColor))
                    .foregroundColor((Color(backgroundColor)))
                    
                }.frame(maxWidth: .infinity)
            }.padding(.all)
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
