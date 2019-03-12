//
//  GameLevel.swift
//
//  Part 2 of the SceneKit Tutorial Series 'From Zero to Hero' at:
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
    private let levelLength = 320

    private var terrain: RBTerrain?
    private var player: Player?

    // MARK: - Input handling

    func swipeLeft() {
        player!.moveLeft()
    }

    func swipeRight() {
        player!.moveRight()
    }

    // MARK: - Place objects

    private func addPlayer() {
        player = Player()
        player!.position = SCNVector3(160, 3, 0)
        self.rootNode.addChildNode(player!)

        let moveAction = SCNAction.moveBy(x: 0, y: 0, z: 200, duration: 20)
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
    }

    override init() {
        super.init()
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }

}
