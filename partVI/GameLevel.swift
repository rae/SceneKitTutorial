//
//  GameLevel.swift
//
//  Part 6 of the SceneKit Tutorial Series 'From Zero to Hero' at:
//  https://rogerboesch.github.io/
//
//  Created by Roger Boesch on 12/10/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit
import SceneKit
import RBSceneUIKit

enum GameState {
    case initialized, ready, play, win, loose, stopped
}

class GameLevel: SCNScene, SCNPhysicsContactDelegate {
    // New in Part 4: A list of all game objects
    private var gameObjects = Array<GameObject>()

    // New in Part 6: A list of all bullets
    private var bullets = Array<Bullet>()

    private var terrain: RBTerrain?

    private var touchedRings = 0

    // New in Part 4: We catch now also the number of missed rings
    private var missedRings = 0

    // MARK: - Properties

    var hud: HUD?

    var state = GameState.initialized {
        didSet {
            rbDebug("State of level changed from \(oldValue) to \(state)")
        }
    }

    private(set) var player: Player?

    // MARK: - New in Part 5: Motion handling

    func motionMoveUp() {
        player!.moveUp()
    }

    func motionMoveDown() {
        player!.moveDown()
    }

    func motionStopMovingUpDown() {
        player!.stopMovingUpDown()
    }

    func motionMoveLeft() {
        player!.moveLeft()
    }

    func motionMoveRight() {
        player!.moveRight()
    }

    func motionStopMovingLeftRight() {
        player!.stopMovingLeftRight()
    }

    // MARK: - Input handling

    func swipeLeft() {
        player!.moveLeft()
    }

    func swipeRight() {
        player!.moveRight()
    }

    func swipeDown() {
        player!.moveDown()
    }

    func swipeUp() {
        player!.moveUp()
    }

    func fire() {
        player!.fire(self)
    }

    // MARK: - Points system

    func addPoints(_ points: Int) {
        hud?.addPoints(points)
    }

    func fireBullet(enemy: Bool, position: SCNVector3, sideDistance: CGFloat = 0, fallDistance: CGFloat = 0) -> Bullet {
        let direction : PlaneDirection = enemy ? .down : .up

        // Search in list if we have an unused bullet
        for bullet in bullets {
            if (bullet.state == .died && bullet.enemy == enemy) {
                // Ok, use this
                bullet.isHidden = false
                bullet.state = .initialized

                bullet.position = position
                bullet.fire(direction: direction, sideDistance: sideDistance, fallDistance: fallDistance, speed: 3.0)

                rbDebug("Reuse bullet \(bullet)")
                return bullet
            }
        }

        // No bullets free, so create one
        let bullet = Bullet(enemy: enemy)
        bullets.append(bullet)
        self.rootNode.addChildNode(bullet)

        bullet.position = position
        bullet.fire(direction: direction, sideDistance: sideDistance, fallDistance: fallDistance, speed: 3.0)

        return bullet
    }

    func flyTrough(_ ring: Ring) {
        touchedRings += 1
        hud?.rings = touchedRings

        self.addPoints(ring.points)
    }

    func touchedHandicap(_ handicap: Handicap) {
        hud?.message("GAME OVER", information: "- Touch to restart - ")

        self.state = .loose
    }

    func crashed() {
        hud?.message("GAME OVER", information: "- Touch to restart - ")

        self.state = .loose
    }

    // MARK: - Game loop

    func update(atTime time: TimeInterval) {
        // New in Part 4: The game loop (see tutorial)
        if self.state != .play {
            return
        }

        var missedRings = 0

        for object in gameObjects {
            object.update(atTime: time, level: self)

            // Check which rings are behind the player but still 'alive'
            if let ring = object as? Ring {
                if (ring.presentation.position.z + 5.0) < player!.presentation.position.z {
                    if ring.state == .alive {
                        missedRings += 1
                    }
                }
            }
        }

        if missedRings > self.missedRings {
            self.missedRings = missedRings
            hud?.missedRings = missedRings
        }

        // Test for end of game
        if missedRings + touchedRings == Game.Level.numberOfRings {
            if missedRings < 3 {
                hud?.message("YOU WIN", information: "- Touch to restart - ")
            }
            else {
                hud?.message("TRY TO IMPROVE", information: "- Touch to restart - ")
            }

            self.state = .win
            player!.stop()
        }
    }

    // MARK: - Physics delegate

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // Part 4: Call collision handler of the object (see GameObject)
        if let gameObjectA = contact.nodeA.parent as? GameObject, let gameObjectB = contact.nodeB.parent as? GameObject {
            gameObjectA.collision(with: gameObjectB, level: self)
            gameObjectB.collision(with: gameObjectA, level: self)
        }
    }

    // MARK: - Place objects

    private func addRings() {
        // Part 3: Add rings to the game level
        let space = Int(Game.Level.length-Game.Level.start) / Int(Game.Level.numberOfRings+1)

        for i in 1...Game.Level.numberOfRings {
            let ring = Ring(number: i)

            var x: CGFloat = Game.Level.width/2
            let rnd = RBRandom.integer(1, 3)
            if rnd == 1 {
                x = x - Game.Objects.offset
            }
            else if rnd == 3 {
                x = x + Game.Objects.offset
            }

            let height = RBRandom.integer(8, 20)

            ring.position = SCNVector3(Int(x), height, Int(Game.Level.start)+i*space)
            self.rootNode.addChildNode(ring)

            gameObjects.append(ring)
        }
    }

    private func addEnemies() {
        // Part 6: Add enemies to the game level
        let space = Int(Game.Level.length-Game.Level.start) / Int(Game.Level.numberOfEnemies+1)

        for i in 1...Game.Level.numberOfEnemies {
            let enemy = Enemy()

            var x: CGFloat = Game.Level.width/2
            let rnd = RBRandom.integer(1, 3)
            if rnd == 1 {
                x = x - Game.Objects.offset
            }
            else if rnd == 3 {
                x = x + Game.Objects.offset
            }

            enemy.position = SCNVector3(Int(x), Int(Game.Plane.minimumHeight), Int(Game.Level.length/3)+i*space)
            self.rootNode.addChildNode(enemy)

            gameObjects.append(enemy)
        }
    }

    private func addHandicap(x: CGFloat, z: CGFloat) {
        let handicap = Handicap()
        handicap.position = SCNVector3(x, handicap.height/2, z)
        self.rootNode.addChildNode(handicap)

        gameObjects.append(handicap)
    }

    private func addHandicaps() {
        // Part 4: Add handicaps to the game level
        let space = CGFloat(Game.Level.length-Game.Level.start) / CGFloat(Game.Level.numberOfRings+1)

        for i in 1...Game.Level.numberOfRings-1 {
            var x: CGFloat = Game.Level.width/2
            let rnd = RBRandom.integer(1, 3)

            if rnd == 1 {
                x = x - Game.Objects.offset

                addHandicap(x: x-RBRandom.cgFloat(10, 50), z: Game.Level.start+CGFloat(i)*space + space/2.0)
                addHandicap(x: x+Game.Objects.offset+RBRandom.cgFloat(10, 50), z: Game.Level.start+CGFloat(i)*space + space/2.0)
            }
            else if rnd == 3 {
                x = x + Game.Objects.offset

                addHandicap(x: x+RBRandom.cgFloat(10, 50), z: Game.Level.start+CGFloat(i)*space + space/2.0)
                addHandicap(x: x-Game.Objects.offset-RBRandom.cgFloat(10, 50), z: Game.Level.start+CGFloat(i)*space + space/2.0)
            }

            addHandicap(x: x, z: Game.Level.start+CGFloat(i)*space + space/2.0)
        }
    }

    private func addPlayer() {
        player = Player()

        player!.position = SCNVector3(Game.Level.width/2, CGFloat(Game.Plane.minimumHeight), Game.Level.start)
        self.rootNode.addChildNode(player!)

        gameObjects.append(player!)
    }

    private func addTerrain() {
        // Create terrain
        terrain = RBTerrain(width: Int(Game.Level.width), length: Int(Game.Level.length), scale: 96)

        let generator = RBPerlinNoiseGenerator(seed: nil)
        terrain?.formula = {(x: Int32, y: Int32) in
            return generator.valueFor(x: x, y: y)
        }

        terrain!.create(withImage: #imageLiteral(resourceName: "grass"))
        terrain!.position = SCNVector3Make(0, 0, 0)
        self.rootNode.addChildNode(terrain!)
    }

    private func addLights() {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(hex:"#444444")
        self.rootNode.addChildNode(ambientLightNode)
    }

    // MARK: - Stop

    func stop() {
        // New in Part 4: Stop all!
        for object in gameObjects {
            object.stop()
        }

        self.physicsWorld.contactDelegate = nil
        self.hud = nil
        self.state = .stopped
    }

    func start() {
        if self.state == .ready {
            self.state = .play
            hud?.reset()

            for object in gameObjects {
                object.start()
            }
        }
    }

    // MARK: - Initialisation

    func create() {
        // New in Part 4: A skybox is used to show a game's background
        self.background.contents = #imageLiteral(resourceName: "skybox")

        // New in Part 5: Add fog effect
        self.fogStartDistance = Game.Level.Fog.start
        self.fogEndDistance = Game.Level.Fog.end

        addLights()

        addTerrain()
        addRings()
        addHandicaps()
        addEnemies()
        addPlayer()

        self.state = .ready
    }

    override init() {
        super.init()

        self.physicsWorld.contactDelegate = self
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }
}
