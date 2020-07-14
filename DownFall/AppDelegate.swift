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
        
//        GameScope.shared.profileManager.authenticate(gameViewController) { result in
//            print("App Delegat result handler")
//            switch result {
//                case .success(let successful):
//                    print("success \(successful)")
//                case .failure(.fileWithNameAlreadyExists):
//                    print("file already exists, overwrite?")
//                case .failure(.saveError(let err)):
//                    print(err)
//                case .failure(.failedToLoadProfile):
//                    print("Failed to load profile")
//                case .failure(.failedToLoadLocalProfile):
//                    print("Failed to load local profile")
//                case .failure(.failedToSaveLocalProfile(let error)):
//                    print("Failed to save local profile \(error)")
//
//            }
//        }
//
        return true
    }

}

