//
//  AppDelegate.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    struct Constants {
        static let tag = String(describing: AppDelegate.self)
    }

    var window: UIWindow?
    private var disposables = Set<AnyCancellable>()
    private var gameViewController: GameViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GameLogger.shared.log(prefix: Constants.tag, message: "Application did finish launching with options start")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let gameViewController = GameViewController(nibName: nil, bundle: nil)
        self.gameViewController = gameViewController
        
        GameScope
            .shared
            .profileManager
            .loadedProfile
            .sink(receiveCompletion: { _ in }) { (profile) in
                GameLogger.shared.log(prefix: Constants.tag, message: "Profile loaded")
                gameViewController.profile = profile
            }.store(in: &disposables)
        
        // Start the authentication process
        GameLogger.shared.log(prefix: Constants.tag, message: "Start the authentication process")
        GameScope.shared.profileManager.start(gameViewController, showGCSignIn: false)
        
        // window
        window!.rootViewController = gameViewController
        window!.makeKeyAndVisible()
        
        GameLogger.shared.log(prefix: Constants.tag, message: "Application did finish launching with options exit")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard let profile = gameViewController?.applicationDidEnterBackground() else {
            GameLogger.shared.log(prefix: Constants.tag, message: "Failed to retrieve profile from GameViewController")
            return
        }
        
        GameLogger.shared.log(prefix: Constants.tag, message: "Attempting to save profile")
        
        GameScope.shared.profileManager.saveProfile(profile)
        
        GameLogger.shared.log(prefix: Constants.tag, message: "applicationWillResignActive exit")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
}

