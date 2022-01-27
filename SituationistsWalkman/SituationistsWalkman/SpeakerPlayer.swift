//
//  SpeakerPlayer.swift
//  SituationistsWalkman
//
//  Created by Tim on 19/1/22.
//

import Foundation
import simd

protocol SpeakerPlayer {
        func setup()
        func prepare(_ speaker : Speaker)
        func play(_ speaker : Speaker)
        func mute()
        func unMute()
        func teardown()
        func updateDevicePosition(_ position : float4x4)
        func updateAnchorPosition(for name : String, position : float4x4)
}
