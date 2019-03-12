//
//  Handicap.swift
//
//  Part 4 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 13/12/17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//
//  New in Part 4: So far we just had rings to fly trough. Now we introduce
//  handicaps which the plane should not touch. Otherwise it crashes and the
// game is over.

import SceneKit
import RBSceneUIKit

class Handicap : GameObject {
    private var node: SCNNode!

    // MARK: - Propertiues

    override var description: String {
        get {
            return "handicap \(self.id)"
        }
    }

    private(set) var height: CGFloat = 0

    // MARK: - Actions

    override func hit() {
        if self.state != .alive {
            return
        }

        self.state = .died

        let action1 = SCNAction.moveBy(x: 0, y: -3, z: 0, duration: 0.15)
        node.runAction(action1)

        let action2 = SCNAction.rotateBy(x: degreesToRadians(value: 30), y: 0, z: degreesToRadians(value: 15), duration: 0.3)
        node.runAction(action2)

        if let emitter = SCNParticleSystem(named: "art.scnassets/fire.scnp", inDirectory: nil) {
            self.addParticleSystem(emitter)
        }
    }

    // MARK: - Initialisation

    override init() {
        super.init()

        // Use some randomness in height, width and color
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.random(list: UIGreenColorList)

        let width = RBRandom.cgFloat(4.0, 9.0)
        height = RBRandom.cgFloat(15.0, 25)

        var geometry: SCNGeometry!
        let rnd = RBRandom.integer(1, 3)
        if rnd == 1 {
            geometry = SCNBox(width: width, height: height, length: 2.0, chamferRadius: 0.0)
        }
        else if rnd == 2 {
            geometry = SCNCylinder(radius: width, height: height)
        }
        else {
            geometry = SCNCone(topRadius: 0.0, bottomRadius: width, height: height)
        }

        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node.name = "handicap"
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        node.physicsBody?.categoryBitMask = Game.Physics.Categories.enemy
        self.addChildNode(node)

        self.state = .alive
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }

}

