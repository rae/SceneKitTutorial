//
//  AppDelegate.swift
//
//  Created by Roger Boesch on 12/07/16.
//  Copyright © 2016 Roger Boesch. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var window: UIWindow?
    private var gameViewController: GameViewController?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        gameViewController = GameViewController()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = gameViewController
        window?.makeKeyAndVisible()
    }
}

