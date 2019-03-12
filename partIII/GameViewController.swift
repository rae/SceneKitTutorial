//
//  GameViewController.swift
//
//  Part 3 of the SceneKit Tutorial Series 'From Zero to Hero' at:
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

    // MARK: - Swipe gestures

    @objc private func handleSwipe(_ gestureRecognize: UISwipeGestureRecognizer) {
        if (gestureRecognize.direction == .left) {
            level!.swipeLeft()
        }
        else if (gestureRecognize.direction == .right) {
            level!.swipeRight()
        }
    }

    // MARK: - ViewController life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Part 3: HUD is created and assigned to view and game level
        let hud = HUD(size: self.view.bounds.size)
        level.hud = hud
        sceneView.overlaySKScene = hud.scene
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        level = GameLevel()
        level.create()

        sceneView = SCNView()
        sceneView.scene = level
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        self.view = sceneView

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        sceneView!.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        sceneView!.addGestureRecognizer(swipeRightGesture)
    }
}
