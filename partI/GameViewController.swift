//
//  GameViewController.swift
//
//  Part 1 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit
import SceneKit
import RBSceneUIKit

class GameViewController: UIViewController {
    private var sceneView: SCNView!
    private var level: GameLevel!

    // MARK: - ViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        level = GameLevel()
        level.create()

        sceneView = SCNView()
        sceneView.scene = level
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        sceneView!.debugOptions = .showWireframe
        self.view = sceneView
    }
}
