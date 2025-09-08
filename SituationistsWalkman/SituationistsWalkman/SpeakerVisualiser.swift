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
        
        // Sphere using speaker's color and cullDistance for radius (clamped to reasonable size)
        let clampedRadius = Float(min(max(speaker.cullDistance, 0.5), 3.0)) // Between 0.5m and 3m
        let sphereResource = MeshResource.generateSphere(radius: clampedRadius)
        let sphereMaterial = SimpleMaterial(color: speaker.color, roughness: 0, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereResource, materials: [sphereMaterial])
        
        // Text showing speaker name - original design but larger
        let textResource = MeshResource.generateText(speaker.name,
                                                     extrusionDepth: 0.02,
                                                     font: .systemFont(ofSize: 0.4),
                                                     containerFrame: .zero,
                                                     alignment: .center,
                                                     lineBreakMode: .byWordWrapping)
        
        let textMaterial = SimpleMaterial(color: UIColor.white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textResource, materials: [textMaterial])
        textEntity.position.z += Float(clampedRadius + 0.5) // Position text outside the sphere
        
        speakerEntity.addChild(textEntity)
        speakerEntity.addChild(sphereEntity)
        
        // TODO - this used to be "anchor: speaker.geoAnchor", rather than "matrix_identity_float4x4"
        let anchorEntity = AnchorEntity(.world(transform: matrix_identity_float4x4))
        anchorEntity.addChild(speakerEntity)
        
        return anchorEntity
    }
}
