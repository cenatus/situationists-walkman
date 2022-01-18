//
//  SpeakerConfigLoader.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import Foundation

struct SpeakerConfigLoader {
    struct Config: Codable {
        let reverb_preset: String
        let sounds : [Speaker.Config]
    }

    static var sounds: [Speaker] = []

    static func run(_ configFileName : String) -> [Speaker] {
        let path = Bundle.main.path(forResource: configFileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let config = try! decoder.decode(Config.self, from: data)

        for soundConfig in config.sounds {
            sounds.append(Speaker(config: soundConfig))
        }
        
        return sounds
    }
}


