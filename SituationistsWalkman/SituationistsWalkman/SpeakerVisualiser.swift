//
//  SpeakerVisualiser.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import ARKit
import RealityKit

struct SpeakerVisualiser {
    
    static func createEntity(for speaker: Speaker) -> AnchorEntity {
        // Speaker box - use original design but make it visible
        let speakerResource = MeshResource.generateBox(size: 0.8)
        let speakerMaterial = SimpleMaterial(color: UIColor.black, isMetallic: true)
        let speakerEntity = ModelEntity(mesh: speakerResource, materials: [speakerMaterial])
        
        // Sphere using speaker's color and cullDistance for radius
        let sphereResource = MeshResource.generateSphere(radius: Float(speaker.cullDistance))
        let sphereMaterial = SimpleMaterial(color: speaker.color, roughness: 0, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereResource, materials: [sphereMaterial])
        
        // Text showing speaker name
        let textResource = MeshResource.generateText(speaker.name,
                                                     extrusionDepth: 0.01,
                                                     font: .systemFont(ofSize: 0.25),
                                                     containerFrame: .zero,
                                                     alignment: .center,
                                                     lineBreakMode: .byWordWrapping)
        
        let textEntity = ModelEntity(mesh: textResource)
        textEntity.position.z += 0.5
        
        speakerEntity.addChild(textEntity)
        speakerEntity.addChild(sphereEntity)
        
        #if targetEnvironment(simulator)
        // Simulator fallback - create a world anchor at origin since AR doesn't work
        let anchorEntity = AnchorEntity(.world(transform: matrix_identity_float4x4))
        #else
        // Device - use the actual geo anchor
        let anchorEntity = AnchorEntity(.anchor(identifier: speaker.geoAnchor.identifier))
        #endif
        anchorEntity.addChild(speakerEntity)
        
        return anchorEntity
    }
}
