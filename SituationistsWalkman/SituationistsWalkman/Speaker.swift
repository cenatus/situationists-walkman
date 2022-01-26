//
//  Speaker.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 21/01/2022.
//

import Foundation
import UIKit
import PHASE
import ARKit

class Speaker {
    let name : String
    
    let lat: Double
    let lon: Double
    let ele: Double
    
    let audioFile: String
    let color: UIColor
    let geoAnchor : ARGeoAnchor
    

    let sourceRadius: Float!
    let cullDistance: Double!
    let rolloffFactor: Double!
    let reverbSendLevel: Double!
    let referenceLevel: Double!
                
    init(_ config: [String: String]) {
        self.name = config["name"]!
        self.lat = Double(config["lat"]!)!
        self.lon = Double(config["lon"]!)!
        self.ele = Double(config["ele"]!)!
        self.audioFile = config["audiofile"] ?? "msp-cb.mp3"
        
        self.color = UIColor(red:   Double(config["r"] ?? "0.0")!,
                             green: Double(config["g"] ?? "0.0")!,
                             blue:  Double(config["b"] ?? "1.0")!,
                             alpha: Double(config["a"] ?? "0.7")!
        )
        
        self.geoAnchor = ARGeoAnchor(
            name: name,
            coordinate: CLLocationCoordinate2D(
                latitude: self.lat,
                longitude: self.lon),
            altitude: CLLocationDistance(self.ele)
        )
        
        self.sourceRadius = Float(config["sourceradius"] ?? "1.0")
        self.cullDistance = Double(config["culldistance"] ?? "1")
        self.rolloffFactor = Double(config["rollofffactor"] ?? "1.0")
        self.reverbSendLevel = Double(config["reverbsendLevel"] ?? "0")
        self.referenceLevel = Double(config["referencelevel"] ?? "0.4")
    }
    
    static func hardcoded() -> Speaker {
        var defaultConfig: [String:String] = [:]

        defaultConfig["name"] = "hardcoded-bandstand"
        defaultConfig["lat"] = "51.526060"
        defaultConfig["lon"] = "-0.074908"
        defaultConfig["ele"] = "0.1"

        return Speaker(defaultConfig)

    }
}

