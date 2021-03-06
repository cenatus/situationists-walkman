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
            HStack {
                VStack(alignment: .leading) {
                    Text("app-title")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color(highlightColor))
                    Spacer()
                }.padding(.trailing)
                VStack(alignment: .center){
                    Text("quote-one")
                        .italic()
                        .foregroundColor(Color(textColor))
                        .padding(.bottom, -1.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("quote-one-attribution")
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(Color(textColor))
                    Text("quote-two")
                        .italic()
                        .foregroundColor(Color(textColor))
                        .padding(.bottom, -1.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("quote-two-attribution")
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(Color(textColor))
                    Text("blurb")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    Text("cta")
                        .foregroundColor(Color(textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }.padding(.trailing)
                VStack(alignment: .trailing) {
                    Spacer()
                    Button("Start") {
                        self.state.page = .experience
                    }
                    .padding(.all)
                    .frame(maxWidth: .infinity)
                    .background(Color(highlightColor))
                    .foregroundColor((Color(backgroundColor)))
                    Button("Credits") {
                        self.state.page = .credits
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

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
