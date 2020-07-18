//
//  AppDelegate.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //TODO: Consider init the GameViewController here and injecting everything it needs to function
        // Use this as a resource https://medium.com/ios-os-x-development/ios-start-an-app-without-storyboard-5f57e3251a25
        window = UIWindow(frame: UIScreen.main.bounds)
        let gameViewController = GameViewController(nibName: nil, bundle: nil)
        window!.rootViewController = gameViewController
        window!.makeKeyAndVisible()
        
        // Start the authentication process
        GameScope.shared.profileManager.start(gameViewController)
        
        return true
    }

}

