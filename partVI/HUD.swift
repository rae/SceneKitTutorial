//
//  HUD.swift
//
//  Part 6 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 11.11.17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//

import SpriteKit
import RBSceneUIKit

class HUD {
    private(set) var scene: SKScene!
    private let pointsNode = SKLabelNode(text: "")
    private let ringsNode = SKLabelNode(text: "")
    private let missedRingsNode = SKLabelNode(text: "")
    private let message = SKLabelNode(text: "")
    private let info = SKLabelNode(text: "")

    // MARK: - Properties

    var points = 0 {
        didSet {
            pointsNode.text = String(format: "%04d", points)
        }
    }

    var rings = 0 {
        didSet {
            if rings == 1 {
                ringsNode.text = String(format: "%d RING", rings)
            }
            else {
                ringsNode.text = String(format: "%d RINGS", rings)
            }

            // New in Part 4: Animated HUD informations (check RB+SKAction.swift for details)
            let scaling: CGFloat = 3
            let action = SKAction.zoomWithNode(ringsNode, amount: CGPoint.make(scaling, scaling), oscillations: 1, duration: 0.5)
            ringsNode.run(action)
        }
    }

    var missedRings = 0 {
        didSet {
            missedRingsNode.text = String(format: "%d MISSED", missedRings)

            if missedRings > 0 {
                missedRingsNode.isHidden = false
                missedRingsNode.fontColor = UIColor.red
            }
            else {
                missedRingsNode.isHidden = true
            }

            let scaling: CGFloat = 3
            let action = SKAction.zoomWithNode(missedRingsNode, amount: CGPoint.make(scaling, scaling), oscillations: 1, duration: 0.5)
            missedRingsNode.run(action)
        }
    }

    // MARK: - Points handling

    private func changePoints(_ pointsToAdd: Int, total: Int, count: Int) {
        points += pointsToAdd

        let scaling: CGFloat = 1.5

        let action = SKAction.zoomWithNode(pointsNode, amount: CGPoint.make(scaling, scaling), oscillations: 1, duration: 0.01)
        pointsNode.run(action)

        if count < total {
            Run.after(0.01) {
                self.changePoints(1, total: total, count: count+1)
            }
        }
    }

    func addPoints(_ points: Int) {
        self.changePoints(1, total: points, count: 1)
    }

    // MARK: - Message handling

    func message(_ str: String, information: String? = nil) {
        // New in Part 4: Used for game over and win messages
        message.text = str
        message.isHidden = false

        let scaling: CGFloat = 10
        let action = SKAction.zoomWithNode(message, amount: CGPoint.make(scaling, scaling), oscillations: 1, duration: 0.5)
        message.run(action)

        if information != nil {
            info(information!)
        }
    }

    func info(_ str: String) {
        // New in Part 4: Uses for additional info when show messages

        info.text = str
        info.isHidden = false

        let scaling: CGFloat = 2
        let action = SKAction.zoomWithNode(info, amount: CGPoint.make(scaling, scaling), oscillations: 1, duration: 0.5)
        info.run(action)
    }

    func reset() {
        // New in Part 4: Reset is needed whenever start the level
        message.text = ""
        message.isHidden = true

        info.text = ""
        info.isHidden = true

        rings = 0
        missedRings = 0
        points = 0
    }

    // MARK: - Initialisation

    init(size: CGSize) {
        scene = SKScene(size: size)

        pointsNode.position = CGPoint(x: size.width/2, y: size.height-50)
        pointsNode.horizontalAlignmentMode = .center
        pointsNode.fontName = "MarkerFelt-Wide"
        pointsNode.fontSize = 30
        pointsNode.fontColor = UIColor.white
        scene.addChild(pointsNode)

        ringsNode.position = CGPoint(x: 40, y: size.height-50)
        ringsNode.horizontalAlignmentMode = .left
        ringsNode.fontName = "MarkerFelt-Wide"
        ringsNode.fontSize = 30
        ringsNode.fontColor = UIColor.white
        scene.addChild(ringsNode)

        missedRingsNode.position = CGPoint(x: size.width-40, y: size.height-50)
        missedRingsNode.horizontalAlignmentMode = .right
        missedRingsNode.fontName = "MarkerFelt-Wide"
        missedRingsNode.fontSize = 30
        missedRingsNode.fontColor = UIColor.white
        scene.addChild(missedRingsNode)

        message.position = CGPoint(x: size.width/2, y: size.height/2)
        message.horizontalAlignmentMode = .center
        message.fontName = "MarkerFelt-Wide"
        message.fontSize = 60
        message.fontColor = UIColor.white
        message.isHidden = true
        scene.addChild(message)

        info.position = CGPoint(x: size.width/2, y: size.height/2-40)
        info.horizontalAlignmentMode = .center
        info.fontName = "MarkerFelt-Wide"
        info.fontSize = 20
        info.fontColor = UIColor.white
        info.isHidden = true
        scene.addChild(info)

        reset()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) not implemented")
    }
}
