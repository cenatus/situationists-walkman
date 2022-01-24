//
//  SpeakerConfigLoader.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import Foundation

// TODO Delete me!
struct SpeakerConfig {
    
    let speakers : [Speaker]
    let reverbPreset : String
    let engine : String
    
    struct Config: Codable {
        let engine : String
        let reverb_preset: String
        //let sounds : [Speaker.Config]
        let sounds : [String]
    }
    
    init(_ configFileName : String) {
        let path = Bundle.main.path(forResource: configFileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let config = try! decoder.decode(Config.self, from: data)
        
         
//        self.speakers = config.sounds.map { Speaker(config: $0 )}
        self.speakers = []
        self.reverbPreset = config.reverb_preset
        self.engine = config.engine
    }
}


