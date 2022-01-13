//
//  AppState.swift
//  SituationistsWalkman
//
//  Created by Tim on 13/1/22.
//

import Foundation

enum NavState {
    case intro
    case experience
    case unsupportedDevice
    case outsideGeoTrackingArea
}

class AppState: ObservableObject {
    @Published var page = NavState.intro
}
