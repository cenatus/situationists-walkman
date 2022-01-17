//
//  PHASESoundVisualiser.swift
//  SituationistsWalkman
//
//  Created by msp on 17/01/2022.
//

import ARKit
import RealityKit

struct PHASESoundVisualiser {
    
    static let blueSphere = ModelEntity(
        mesh: MeshResource.generateSphere(radius: 0.066),
        materials: [UnlitMaterial(color: #colorLiteral(red: 0, green: 0.3, blue: 1.4, alpha: 1))]
    )
    static let transparentSphere = ModelEntity(
        mesh: MeshResource.generateSphere(radius: 0.1),
        materials: [SimpleMaterial(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25), roughness: 0.3, isMetallic: true)]
    )

    static func placemarkEntity(for arAnchor: ARAnchor) -> AnchorEntity {
        let placemarkAnchor = AnchorEntity(anchor: arAnchor)
        
        let sphereIndicator = generateSphereIndicator(radius: 0.1)
        
        // Move the indicator up by half its height so that it doesn't intersect with the ground.
        let height = sphereIndicator.visualBounds(relativeTo: nil).extents.y
        sphereIndicator.position.y = height / 2
        
        // The move function animates the indicator to expand and rise up 3 meters from the ground like a balloon.
        // Elevated GeoAnchors are easier to see, and are high enough to stand under.
//        let distanceFromGround: Float = 3
//        sphereIndicator.move(by: [0, distanceFromGround, 0], scale: .one * 10, after: 0.5, duration: 5.0)
        placemarkAnchor.addChild(sphereIndicator)
        
        return placemarkAnchor
    }
    
    static func mspEntity(for geoAnchor: ARAnchor) -> AnchorEntity {
        let sphereResource = MeshResource.generateSphere(radius: 5)
        let spehereMaterial = SimpleMaterial(color: .blue, roughness: 0, isMetallic: true)
        let sphereEntity = ModelEntity(mesh: sphereResource, materials: [spehereMaterial])

        let anchorEntity = AnchorEntity(anchor: geoAnchor)
        anchorEntity.addChild(sphereEntity)
        
        return anchorEntity
    }
    
    static func generateSphereIndicator(radius: Float) -> Entity {
        let indicatorEntity = Entity()
        
        let innerSphere = blueSphere.clone(recursive: true)
        indicatorEntity.addChild(innerSphere)
        let outerSphere = transparentSphere.clone(recursive: true)
        indicatorEntity.addChild(outerSphere)
        
        return indicatorEntity
    }
    
//    func move(by translation: SIMD3<Float>, scale: SIMD3<Float>, after delay: TimeInterval, duration: TimeInterval) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            var transform: Transform = .identity
//            transform.translation = self.transform.translation + translation
//            transform.scale = self.transform.scale * scale
//            self.move(to: transform, relativeTo: self.parent, duration: duration, timingFunction: .easeInOut)
//        }
//    }
}
