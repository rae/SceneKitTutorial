//
//  Plane.swift
//
//  Part 6 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//
//  Part 6: Created a base class for planes
//

import SceneKit
import RBSceneUIKit

// New in Part 6: We control the plane direction
enum PlaneDirection {
    case none, down, left, up, right
}

class Plane : GameObject {
    private var speedDistance = Game.Plane.speedDistance      // The speed

    // MARK: - Propertiues

    override var description: String {
        get {
            return "plane \(self.id)"
        }
    }

    private(set) var leftRightDirection: PlaneDirection = .none

    private(set) var upDownDirection: PlaneDirection = .none

    private(set) var modelNode: SCNNode?
    private(set) var collissionNode: SCNNode?

    var flip = false {
        didSet {
            if flip {
                speedDistance = -1*Game.Plane.speedDistance
                modelNode?.eulerAngles = SCNVector3(0, degreesToRadians(value: 180.0), 0)
            }
            else {
                speedDistance = Game.Plane.speedDistance
                modelNode?.eulerAngles = SCNVector3(0, 0, 0)
            }
        }
    }

    var numberOfBullets = 0 {
        didSet {
            rbDebug("\(self) has \(numberOfBullets) bullets left")
        }
    }

    // MARK: - Game loop

    override func update(atTime time: TimeInterval, level: GameLevel) {
        var eulerX: CGFloat = 0
        var eulerY: CGFloat = 0
        var eulerZ: CGFloat = 0

        if self.flip {
            eulerY = -degreesToRadians(value: 180)
        }

        // New in Part 5: We control minimum/maximum height
        if (upDownDirection == .down) {
            if (self.position.y <= Game.Plane.minimumHeight) {
                stopMovingUpDown()
            }

            eulerX = degreesToRadians(value: Game.Plane.upDownAngle)
        }
        else if (upDownDirection == .up) {
            if (self.position.y >= Game.Plane.maximumHeight) {
                stopMovingUpDown()
            }

            eulerX = -degreesToRadians(value: Game.Plane.upDownAngle)
        }

        // New in Part 5: We control minimum/maximum left/right
        if (leftRightDirection == .left) {
            if (self.position.x >= Game.Plane.maximumLeft) {
                stopMovingLeftRight()
            }

            eulerZ = -degreesToRadians(value: Game.Plane.leftRightAngle)
        }
        else if (leftRightDirection == .right) {
            if (self.position.x <= Game.Plane.maximumRight) {
                stopMovingLeftRight()
            }

            eulerZ = degreesToRadians(value: Game.Plane.leftRightAngle)
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        modelNode?.eulerAngles = SCNVector3(eulerX, eulerY, eulerZ)

        SCNTransaction.commit()
    }

    // MARK: - Collision handling

    override func collision(with object: GameObject, level: GameLevel) {
    }

    // MARK: - Effects

    func die() {
        if self.state != .alive {
            return
        }

        self.state = .died
        modelNode?.isHidden = true

        self.removeAllActions()
        modelNode?.removeAllActions()

        if let emitter = SCNParticleSystem(named: "art.scnassets/smoke.scnp", inDirectory: nil) {
            self.addParticleSystem(emitter)
        }
    }

    // MARK: - New in Part 5: Move Actions

    func moveUp() {
        if upDownDirection == .none {
            let moveAction = SCNAction.moveBy(x: 0, y: Game.Plane.upDownMoveDistance, z: 0, duration: 0.5)
            self.runAction(SCNAction.repeatForever(moveAction), forKey: "upDownDirection")

            upDownDirection = .up
        }
        else if (upDownDirection == .down) {
            self.removeAction(forKey: "upDownDirection")

            upDownDirection = .none
        }
    }

    func moveDown() {
        if upDownDirection == .none {
            let moveAction = SCNAction.moveBy(x: 0, y: -Game.Plane.upDownMoveDistance, z: 0, duration: 0.5)
            self.runAction(SCNAction.repeatForever(moveAction), forKey: "upDownDirection")

            upDownDirection = .down
        }
        else if (upDownDirection == .up) {
            self.removeAction(forKey: "upDownDirection")

            upDownDirection = .none
        }
    }

    func stopMovingUpDown() {
        self.removeAction(forKey: "upDownDirection")
        upDownDirection = .none
    }

    func moveLeft() {
        if leftRightDirection == .none {
            let moveAction = SCNAction.moveBy(x: Game.Plane.leftRightMoveDistance, y: 0.0, z: 0, duration: 0.5)
            self.runAction(SCNAction.repeatForever(moveAction), forKey: "leftRightDirection")

            leftRightDirection = .left
        }
        else if (leftRightDirection == .right) {
            self.removeAction(forKey: "leftRightDirection")

            leftRightDirection = .none
        }
    }

    func moveRight() {
        if leftRightDirection == .none {
            let moveAction = SCNAction.moveBy(x: -Game.Plane.leftRightMoveDistance, y: 0.0, z: 0, duration: 0.5)
            self.runAction(SCNAction.repeatForever(moveAction), forKey: "leftRightDirection")

            leftRightDirection = .right
        }
        else if (leftRightDirection == .left) {
            self.removeAction(forKey: "leftRightDirection")

            leftRightDirection = .none
        }
    }

    func stopMovingLeftRight() {
        self.removeAction(forKey: "leftRightDirection")
        leftRightDirection = .none
    }

    override func start() {
        let moveAction = SCNAction.moveBy(x: 0, y: 0, z: speedDistance, duration: Game.Plane.actionTime)
        let action = SCNAction.repeatForever(moveAction)
        self.runAction(action, forKey: "fly")
    }

    // MARK: - Initialisation

    override init() {
        super.init()

        // Create player node
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        if (scene == nil) {
            fatalError("Scene not loaded")
        }

        modelNode = scene!.rootNode.childNode(withName: "ship", recursively: true)
        modelNode?.name = "plane"

        if (modelNode == nil) {
            fatalError("Model node not found")
        }

        modelNode!.scale = SCNVector3(x: 0.25, y: 0.25, z: 0.25)
        self.addChildNode(modelNode!)

        // Contact box
        // Part 3: Instead of use the plane itself we add a collision node to the player object
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)

        let box = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        box.materials = [boxMaterial]

        collissionNode = SCNNode(geometry: box)
        collissionNode!.name = "plane"
        collissionNode!.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        collissionNode!.physicsBody?.categoryBitMask = Game.Physics.Categories.player
        collissionNode!.physicsBody!.contactTestBitMask = Game.Physics.Categories.ring | Game.Physics.Categories.enemy
        self.addChildNode(collissionNode!)
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }
}
