//
//  MessageView.swift
//  SituationistsWalkman
//
//  Created by Tim on 28/1/22.
//
import SwiftUI

struct MessageView: View {
    @EnvironmentObject var state : AppState
    
    let message : LocalizedStringKey
    var buttonText = "Back"
    
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
                    Spacer()
                    Text(message)
                        .foregroundColor(Color(textColor))
                    Spacer()
                    
                }.padding(.trailing)
                VStack(alignment: .trailing) {
                    Spacer()
                    Button(buttonText) {
                        self.state.page = .intro
                        self.state.localized = false
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

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: "This is a test message.")
    }
}
