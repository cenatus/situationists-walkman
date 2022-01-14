//
//  PHASEPlayerDebugRenderer.swift
//  TestARKitObjectDetection
//
//  Created by Tim on 12/1/22.
//

import Foundation
import SceneKit
import UIKit

class PHASEPlayerDebugRenderer {
    
    let SEGMENT_COUNT : Int = 48

    let COLORS : [String : UIColor] = Dictionary.init(uniqueKeysWithValues: [
        ("blue", UIColor.systemBlue),
        ("red", UIColor.systemRed),
        ("cyan", UIColor.systemCyan),
        ("yellow", UIColor.systemYellow),
        ("gray", UIColor.systemGray),
        ("mint", UIColor.systemMint),
        ("pink", UIColor.systemPink),
        ("teal", UIColor.systemTeal),
        ("brown", UIColor.systemBrown),
        ("green", UIColor.systemGreen),
        ("indigo", UIColor.systemIndigo),
        ("orange", UIColor.systemOrange),
        ("purple", UIColor.systemPurple)
    ])
    
    let scene: SCNScene!

    init(_ scene: SCNScene) {
        self.scene = scene
    }
    
    func displaySoundSource(_ sound : PHASEPlayerSound) {
        let innerSphereGeometry = SCNSphere(radius: CGFloat(sound.sourceRadius))
        innerSphereGeometry.isGeodesic = true
        innerSphereGeometry.segmentCount = SEGMENT_COUNT
        
        let outerSphereGeometry = SCNSphere(radius: CGFloat(sound.cullDistance))
        outerSphereGeometry.isGeodesic = true
        outerSphereGeometry.segmentCount = SEGMENT_COUNT
        
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = COLORS[sound.debugColor]
        material.fillMode = .lines
                
        innerSphereGeometry.firstMaterial = material
        outerSphereGeometry.firstMaterial = material
        
        let innerSphereNode = SCNNode(geometry: innerSphereGeometry)
        let outerSphereNode = SCNNode(geometry: outerSphereGeometry)
        
        innerSphereNode.transform = SCNMatrix4(sound.position)
        outerSphereNode.transform = SCNMatrix4(sound.position)
        
        scene.rootNode.addChildNode(innerSphereNode)
        scene.rootNode.addChildNode(outerSphereNode)
    }
}
