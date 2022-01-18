//
//  Speaker.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import Foundation
import UIKit
import ARKit

class Speaker {
    struct LocationConfig: Codable {
        let lat: Double
        let lng: Double
        let ele: Double
    }
    
    struct ColorConfig: Codable {
        let r: Double
        let g: Double
        let b: Double
        let a: Double
    }
    
    struct Config: Codable {
        let anchor_name: String
        let audio_file: String
        let color: ColorConfig
        let source_radius: Float
        let cull_distance: Double
        let rolloff_factor: Double
        let reverb_send_level: Double
        let reference_level: Double
        let location: LocationConfig
    }
    
    let config : Config!
    let geoAnchor : ARGeoAnchor
    
    
    let anchorName : String!
    let audioFile: String!
    let color: UIColor!
    let sourceRadius: Float!
    let cullDistance: Double!
    let rolloffFactor: Double!
    let reverbSendLevel: Double!
    let referenceLevel: Double!
    
    let lat: Double!
    let lng: Double!
    let ele: Double!
    
    init(config: Config) {
        self.config = config
        
        self.anchorName = config.anchor_name
        self.audioFile = config.audio_file
        self.sourceRadius = config.source_radius
        self.cullDistance = config.cull_distance
        self.rolloffFactor = config.rolloff_factor
        self.reverbSendLevel = config.reverb_send_level
        self.referenceLevel = config.reference_level
        self.lat = config.location.lat
        self.lng = config.location.lng
        self.ele = config.location.ele
        
        self.color = UIColor(red: config.color.r,
                             green: config.color.g,
                             blue: config.color.b,
                             alpha: config.color.a)
        
        self.geoAnchor = ARGeoAnchor(
            name: self.anchorName,
            coordinate: CLLocationCoordinate2D(
                latitude: self.lat,
                longitude: self.lng)
        )
    }
}
