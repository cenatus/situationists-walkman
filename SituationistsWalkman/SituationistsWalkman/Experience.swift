//
//  Experience.swift
//  SituationistsWalkman
//
//  Created by msp on 14/01/2022.
//

import Foundation
import PHASE
import CoreMotion


struct Experience {
    static let PLAYER_CONFIG_FILE_NAME = "sounds"
    static let phasePlayer = PHASEPlayer(PLAYER_CONFIG_FILE_NAME)
//    static let debugRenderer : PHASEPlayerDebugRenderer!

    static func setup() {
        phasePlayer.setup()
//        debugRenderer = PHASEPlayerDebugRenderer(arView.scene)
    }
    
    static func start() {
        // pulseplayer.addAndPlayAllSoundsAtLocations() // TODO write this one.
        // TODO: something to render the debug spheres
    }

    static func end() {
    }
}

