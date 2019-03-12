//
//  Player.swift
//
//  Part 1 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import SceneKit
import RBSceneUIKit

class Player : SCNNode {
    private let lookAtForwardPosition = SCNVector3Make(0.0, 0.0, 1.0)
    private let cameraFowardPosition = SCNVector3(x: 0.8, y: 1, z: -0.5)

    private var lookAtNode: SCNNode?
    private var cameraNode: SCNNode?
    private var playerNode: SCNNode?

    // MARK: - Initialisation

    override init() {
        super.init()

        // Create player node
        let cubeGeometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.0)
        playerNode = SCNNode(geometry: cubeGeometry)
        playerNode?.isHidden = true
        addChildNode(playerNode!)

        let colorMaterial = SCNMaterial()
        cubeGeometry.materials = [colorMaterial]

        // Look at Node
        lookAtNode = SCNNode()
        lookAtNode!.position = lookAtForwardPosition
        addChildNode(lookAtNode!)

        // Camera Node
        cameraNode = SCNNode()
        cameraNode!.camera = SCNCamera()
        cameraNode!.position = cameraFowardPosition
        cameraNode!.camera!.zNear = 0.1
        cameraNode!.camera!.zFar = 200
        self.addChildNode(cameraNode!)

        // Link them
        let constraint1 = SCNLookAtConstraint(target: lookAtNode)
        constraint1.isGimbalLockEnabled = true
        cameraNode!.constraints = [constraint1]

        // Create a spotlight at the player
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.spotInnerAngle = 40.0
        spotLight.spotOuterAngle = 80.0
        spotLight.castsShadow = true
        spotLight.color = UIColor.white
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        spotLightNode.position = SCNVector3(x: 1.0, y: 5.0, z: -2.0)
        self.addChildNode(spotLightNode)

        // Linnk it
        let constraint2 = SCNLookAtConstraint(target: self)
        constraint2.isGimbalLockEnabled = true
        spotLightNode.constraints = [constraint2]

        // Create additional omni light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.light!.color = UIColor.darkGray
        lightNode.position = SCNVector3(x: 0, y: 10.00, z: -2)
        self.addChildNode(lightNode)
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }
}
