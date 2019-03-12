//
//  Player.swift
//
//  Part 2 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import SceneKit
import RBSceneUIKit

class Player : SCNNode {
    private let lookAtForwardPosition = SCNVector3Make(0.0, -1.0, 6.0)
    private let cameraFowardPosition = SCNVector3(x: 5, y: 1.0, z: -5)

    private var lookAtNode: SCNNode?
    private var cameraNode: SCNNode?
    private var playerNode: SCNNode?

    // MARK: - Camera adjustment

    private func toggleCamera() {
        var position = cameraNode!.position

        if position.x < 0 {
            position.x = 5.0
        }
        else {
            position.x = -5.0
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        cameraNode?.position = position

        SCNTransaction.commit()
    }

    // MARK: - Plane movements

    func moveLeft() {
        let moveAction = SCNAction.moveBy(x: 2.0, y: 0.0, z: 0, duration: 0.5)
        self.runAction(moveAction, forKey: "moveLeftRight")

        let rotateAction1 = SCNAction.rotateBy(x: 0, y: 0, z: -degreesToRadians(value: 15.0), duration: 0.25)
        let rotateAction2 = SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(value: 15.0), duration: 0.25)

        playerNode!.runAction(SCNAction.sequence([rotateAction1, rotateAction2]))

        toggleCamera()
    }

    func moveRight() {
        let moveAction = SCNAction.moveBy(x: -2.0, y: 0.0, z: 0, duration: 0.5)
        self.runAction(moveAction, forKey: "moveLeftRight")

        let rotateAction1 = SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(value: 15.0), duration: 0.25)
        let rotateAction2 = SCNAction.rotateBy(x: 0, y: 0, z: -degreesToRadians(value: 15.0), duration: 0.25)

        playerNode!.runAction(SCNAction.sequence([rotateAction1, rotateAction2]))

        toggleCamera()
    }

    // MARK: - Initialisation

    override init() {
        super.init()

        // Create player node
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        if (scene == nil) {
            fatalError("Scene not loaded")
        }

        playerNode = scene!.rootNode.childNode(withName: "ship", recursively: true)
        if (playerNode == nil) {
            fatalError("Ship node not found")
        }

        playerNode!.scale = SCNVector3(x: 0.25, y: 0.25, z: 0.25)
        self.addChildNode(playerNode!)

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
