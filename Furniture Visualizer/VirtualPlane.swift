//
//  VirtualPlane.swift
//  Furniture Visualizer
//
//  Created by Vineet Joshi on 12/5/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation
import ARKit

class VirtualPlane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        // (1) initialize anchor and geometry, set color for plane
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        // (2) create the SceneKit plane node. As planes in SceneKit are vertical, we need to initialize the y coordinate to 0,
        // use the z coordinate, and rotate it 90º.
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        
        // (3) update the material representation for this plane
        updatePlaneMaterialDimensions()
        
        // (4) add this node to our hierarchy.
        self.addChildNode(planeNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.50)
        return material
    }
    
    func updatePlaneMaterialDimensions() {
        // get material or recreate
        let material = self.planeGeometry.materials.first!
        
        // scale material to width and height of the updated plane
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        // first, we update the extent of the plane, because it might have changed
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        // now we should update the position (remember the transform applied)
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // update the material representation for this plane
        updatePlaneMaterialDimensions()
    }
    
}
