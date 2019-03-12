//
//  HUD.swift
//
//  Part 3 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 11.11.17.
//  Copyright © 2017 Roger Boesch. All rights reserved.
//
//  This class I have newly introduced in Part 3. It's purpose
//  is to show information, like points, time etc. to the user.
//  At the moment the number of catched rings.
//

import SpriteKit
import RBSceneUIKit

class HUD {
    private let pointsNode = SKLabelNode(text: "0 RINGS")

    // MARK: - Properties

    private(set) var scene: SKScene!

    var points = 0 {
        didSet {
            pointsNode.text = String(format: "%d RINGS", points)
        }
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) not implemented")
    }

}
