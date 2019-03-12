//
//  GameObject.swift
//
//  Part 4 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 31.10.17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//
//  New in Part 4: This is a bigger change. While the game becomes more and more
//  various game objects, it's common to encapsulate general things
//  in a base class.
//  The most important is the state which is described in detail in the tutorial.

import SceneKit
import RBSceneUIKit

enum GameObjecState {
    case initialized, alive, died, stopped
}

class GameObject : SCNNode {
    private static var count = 0
    static var level: GameLevel?

    private var internalID = 0
    var tag = 0

    // MARK: - Properties

    override var description: String {
        get {
            return "game object \(self.id)"
        }
    }

    var id: Int {
        return internalID
    }

    var state: GameObjecState = GameObjecState.initialized {
        didSet {
            rbDebug("State of \(self) changed from \(oldValue) to \(state)")
        }
    }

    // MARK: - Actions

    func hit() {}       // Object get hit by another object

    func stop() {
         // Stop object (release all)
        self.state = .stopped
        stopAllActions(self)
    }

    // MARK: - Game loop

    func update(atTime time: TimeInterval, level: GameLevel) {}

    // MARK: - Collision handling

    func collision(with object: GameObject, level: GameLevel) {}

    // MARK: - Helper methods

    func stopAllActions(_ node: SCNNode) {
        // It's important to stop all actions before we remove a game object
        // Otherwise they continue to run and result in difficult side effects.
        node.removeAllActions()

        for child in node.childNodes {
            child.removeAllActions()
            stopAllActions(child)
        }
    }

    // MARK: - Initialisation

    override init() {
        super.init()

        GameObject.count += 1
        internalID = GameObject.count
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder aDecoder: NSCoder) is not implemented")
    }

}

