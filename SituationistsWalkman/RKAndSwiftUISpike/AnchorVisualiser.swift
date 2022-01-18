//
//  AnchorVisualiser.swift
//  RKAndSwiftUISpike
//
//  Created by msp on 18/01/2022.
//

import ARKit
import RealityKit

struct AnchorVisualiser {
    
    static func run(for geoAnchor: ARAnchor, color : UIColor ) -> AnchorEntity {
        let sphereResource = MeshResource.generateSphere(radius: 1.5)
        let spehereMaterial = SimpleMaterial(color: color, roughness: 0, isMetallic: true)
        let sphereEntity = ModelEntity(mesh: sphereResource, materials: [spehereMaterial])

        let anchorEntity = AnchorEntity(anchor: geoAnchor)
        anchorEntity.addChild(sphereEntity)
        
        return anchorEntity
    }
}
