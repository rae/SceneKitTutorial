//
//  GameViewController.swift
//
//  Part 4 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import RBSceneUIKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    private var level: GameLevel!

    // MARK: - Properties

    private(set) var sceneView: SCNView!

    private(set) var hud: HUD!

    // MARK: - Render delegate (New in Part 4)

    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        if level != nil {
            level.update(atTime: time)
        }

        renderer.loops = true
    }

    // MARK: - Gesture recognoizers

    @objc private func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        // New in Part 4: A tap is used to restart the level (see tutorial)
        if level.state == .lose || level.state == .win {
            level.stop()
            level = nil

            DispatchQueue.main.async {
                // Create things in main thread

                let level = GameLevel()
                level.create()

                level.hud = self.hud
                self.hud.reset()

                self.sceneView.scene = level
                self.level = level
            }

        }
    }

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
        hud = HUD(size: view.bounds.size)
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
        sceneView.showsStatistics = false
        sceneView.backgroundColor = UIColor.black
        sceneView.delegate = self

        view = sceneView

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView!.addGestureRecognizer(tapGesture)

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        sceneView!.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        sceneView!.addGestureRecognizer(swipeRightGesture)
    }
}
