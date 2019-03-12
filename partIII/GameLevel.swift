//
//  GameLevel.swift
//
//  Part 3 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/10/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit
import SceneKit
import RBSceneUIKit

class GameLevel: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    private let levelWidth = 320
    private let levelLength = 640

    private var terrain: RBTerrain?
    private var player: Player?

    // Part 3: Number od rings and touched rings saved here
    private let numberOfRings = 10
    private var touchedRings = 0

    // MARK: - Properties

    var hud: HUD?

    // MARK: - Input handling

    func swipeLeft() {
        player!.moveLeft()
    }

    func swipeRight() {
        player!.moveRight()
    }

    // MARK: - Physics delegate

    func collision(withRing ring: Ring) {
        // Part 3: Collision handling based on physics
        if ring.isHidden {
            return
        }

        debugPrint("Collision width \(ring)")

        ring.isHidden = true
        player!.roll()

        touchedRings += 1

        hud?.points = touchedRings
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // Part 3: Physics delegate get called when objects collide
        if let ring = contact.nodeB.parent as? Ring {
            collision(withRing: ring)
        }
    }

    // MARK: - Place objects

    private func addRings() {
        // Part 3: Add rings to the game level
        let space = levelLength / (numberOfRings+1)

        for i in 1...numberOfRings {
            let ring = Ring()

            var x: CGFloat = 160
            let rnd = RBRandom.integer(1, 3)
            if rnd == 1 {
                x = x - Player.moveOffset
            }
            else if rnd == 3 {
                x = x + Player.moveOffset
            }

            ring.position = SCNVector3(Int(x), 3, (i*space))
            self.rootNode.addChildNode(ring)
        }
    }

    private func addPlayer() {
        player = Player()
        player!.position = SCNVector3(160, 4, 0)
        self.rootNode.addChildNode(player!)

        let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(levelLength)-10, duration: 60)
        player!.runAction(moveAction)
    }

    private func addTerrain() {
        // Create terrain
        terrain = RBTerrain(width: levelWidth, length: levelLength, scale: 128)

        let generator = RBPerlinNoiseGenerator(seed: nil)
        terrain?.formula = {(x: Int32, y: Int32) in
            return generator.valueFor(x: x, y: y)
        }

        terrain!.create(withImage: #imageLiteral(resourceName: "grass"))
        terrain!.position = SCNVector3Make(0, 0, 0)
        self.rootNode.addChildNode(terrain!)
    }

    // MARK: - Initialisation

    func create() {
        addTerrain()
        addPlayer()
        addRings()
    }

    override init() {
        super.init()

        self.physicsWorld.contactDelegate = self
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }

}
