//
//  SpeakerVisualiser.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import ARKit
import RealityKit

struct SpeakerVisualiser {
    
    static func run(for geoAnchor: ARAnchor, color : UIColor, soundRadius : Float ) -> AnchorEntity {
        let speakerResource = MeshResource.generateBox(size: 0.4)
        let speakerMaterial = SimpleMaterial(color: UIColor.black, isMetallic: true)
        let speakerEntity = ModelEntity(mesh: speakerResource, materials: [speakerMaterial])
        
        let sphereResource = MeshResource.generateSphere(radius: soundRadius)
        let spehereMaterial = SimpleMaterial(color: color, roughness: 0, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereResource, materials: [spehereMaterial])
        
        let textResource = MeshResource.generateText(geoAnchor.name ?? "????",
                                                     extrusionDepth: 0.01,
                                                     font: .systemFont(ofSize: 0.25),
                                                     containerFrame: .zero,
                                                     alignment: .center,
                                                     lineBreakMode: .byWordWrapping)
        
        let textEntity = ModelEntity(mesh: textResource)
        textEntity.position.z += 0.5
        
        speakerEntity.addChild(textEntity)
        speakerEntity.addChild(sphereEntity)
        
        let anchorEntity = AnchorEntity(anchor: geoAnchor)
        anchorEntity.addChild(speakerEntity)
        
        return anchorEntity
    }
}
