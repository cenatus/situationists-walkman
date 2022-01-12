//
//  UnsupportedView.swift
//  SituationistsWalkman
//
//  Created by Tim on 12/1/22.
//

import Foundation
import SwiftUI

struct UnsupportedView: View {
    var body: some View {
        Text("Sorry, your device is not supported!")
            .padding()
    }
}

struct UnsupportedView_Previews: PreviewProvider {
    static var previews: some View {
        UnsupportedView()
    }
}
