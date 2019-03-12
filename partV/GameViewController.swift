//
//  GameViewController.swift
//
//  Part 5 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import CoreMotion
import GameController
import RBSceneUIKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    private var level: GameLevel!

    // New in Part 5: Use CoreMotion to fly the plane
    private var motionManager = CMMotionManager()
    private var startAttitude: CMAttitude?             // Start attitude
    private var currentAttitude: CMAttitude?           // Current attitude

    // MARK: - Properties

    private(set) var sceneView: SCNView!

    private(set) var hud: HUD!

    // MARK: - Render delegate (New in Part 4)

    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        guard level != nil else { return }

        level.update(atTime: time)
        renderer.loops = true
    }

    // MARK: - Gesture recognoizers

    @objc private func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        // New in Part 4: A tap is used to restart the level (see tutorial)
        if level.state == .loose || level.state == .win {
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

                self.hud.message("READY?", information: "- Touch screen to start -")
            }
        }
        // New in Part 5: A tap is used to start the level (see tutorial)
        else if level.state == .ready {
            startAttitude = currentAttitude
            level.start()
        }
    }

    @objc private func handleSwipe(_ gestureRecognize: UISwipeGestureRecognizer) {
        if level.state != .play {
            return
        }

        if (gestureRecognize.direction == .left) {
            level!.swipeLeft()
        }
        else if (gestureRecognize.direction == .right) {
            level!.swipeRight()
        }
        else if (gestureRecognize.direction == .down) {
            level!.swipeDown()
        }
        else if (gestureRecognize.direction == .up) {
            level!.swipeUp()
        }
    }

    // MARK: - Motion handling

    private func motionDidChange(data: CMDeviceMotion) {
        currentAttitude = data.attitude

        guard level != nil, level?.state == .play else { return }

        // Up/Down
        let diff1 = startAttitude!.roll - currentAttitude!.roll

        if (diff1 >= Game.Motion.threshold) {
            level!.motionMoveUp()
        }
        else if (diff1 <= -Game.Motion.threshold) {
            level!.motionMoveDown()
        }
        else {
            level!.motionStopMovingUpDown()
        }

        let diff2 = startAttitude!.pitch - currentAttitude!.pitch

        if (diff2 >= Game.Motion.threshold) {
            level!.motionMoveLeft()
        }
        else if (diff2 <= -Game.Motion.threshold) {
            level!.motionMoveRight()
        }
        else {
            level!.motionStopMovingLeftRight()
        }
    }

    private func setupMotionHandler() {
        if (GCController.controllers().count == 0 && motionManager.isAccelerometerAvailable) {
            motionManager.accelerometerUpdateInterval = 1/60.0

            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {(data, error) in
                self.motionDidChange(data: data!)
            })
        }
    }

    // MARK: - ViewController life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Part 3: HUD is created and assigned to view and game level
        hud = HUD(size: self.view.bounds.size)
        level.hud = hud
        sceneView.overlaySKScene = hud.scene

        self.hud.message("READY?", information: "- Touch screen to start -")
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

        self.view = sceneView

        setupMotionHandler()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView!.addGestureRecognizer(tapGesture)

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        sceneView!.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        sceneView!.addGestureRecognizer(swipeRightGesture)

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDownGesture.direction = .down
        sceneView!.addGestureRecognizer(swipeDownGesture)

        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpGesture.direction = .up
        sceneView!.addGestureRecognizer(swipeUpGesture)
    }
}
