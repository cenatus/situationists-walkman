//
//  ErrorView.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import SwiftUI

struct ErrorView: View {
    let message : String
    
    var body: some View {
        Text(message)
            .padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Sorry, your device is not supported!")
    }
}
