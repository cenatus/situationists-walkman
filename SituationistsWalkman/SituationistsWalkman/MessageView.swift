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
            
            // Debug overlay for field testing - same as ExperienceView
            if state.debugMode {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Coverage: \(state.geoTrackingAvailable)")
                                .foregroundColor(state.geoTrackingAvailable.contains("✅") ? .green : .red)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            Text("Status: \(state.geoTrackingStatus)")
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            Text("Speakers: \(state.speakerCount)")
                                .foregroundColor(.green)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                            if !state.geoTrackingReason.isEmpty {
                                Text("Reason: \(state.geoTrackingReason)")
                                    .foregroundColor(.yellow)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                            }
                            if !state.geoTrackingError.isEmpty {
                                Text("Error: \(state.geoTrackingError)")
                                    .foregroundColor(.red)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: "This is a test message.")
    }
}
