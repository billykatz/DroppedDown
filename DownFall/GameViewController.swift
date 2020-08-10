//
//  GameViewController.swift
//  DownFall
//
//  Created by William Katz on 5/9/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    internal var gameSceneNode: GameScene?
    internal var entities: EntitiesModel?
    var loadingSceneNode: LoadingScene?
    
    /// coordinators
    var levelCoordinator: LevelCoordinating?
    var menuCoordinator: MenuCoordinating?
    
    public var profile: Profile? = nil {
        didSet {
            guard let profile = profile else { return }
            loadingSceneNode?.fadeOut {
                self.menuCoordinator?.loadedProfile(profile)
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Needed when we stopped using a storyboard
        view = SKView(frame: view.bounds)
        
        /// Show the loading screeen
        if let view = view as? SKView,
           let loadingScene = GKScene(fileNamed: "LoadingScene")?.rootNode as? LoadingScene {
           loadingScene.scaleMode = .aspectFill
           view.presentScene(loadingScene)
           loadingSceneNode = loadingScene
        }
        
        do {
            guard let entityData = try Data.data(from: "entities") else { fatalError("Crashing here is okay because we failed to parse our entity json file") }
            entities = try JSONDecoder().decode(EntitiesModel.self, from: entityData)
        }
        catch(let error) {
            fatalError("Crashing due to \(error) while trying to parse json entity file")
        }
        
        /// Init the coordinators
        guard let gameScene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene, let entities = entities,
            let view = self.view as? SKView
        else { fatalError() }
        
        let levelCoordinator = LevelCoordinator(gameSceneNode: gameScene, entities: entities, levelIndex: 0, view: view)
        self.menuCoordinator = MenuCoordinator(levelCoordinator: levelCoordinator, view: view)
        self.levelCoordinator = levelCoordinator
        self.levelCoordinator?.delegate = menuCoordinator
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [.portrait]
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // save the current run if there is one
    // add it to the profile then returns the profile
    func applicationDidEnterBackground() -> Profile {
        guard var profile = menuCoordinator?.profile else {
            fatalError("Cannot continue without the profile")
        }
        if let runModel = levelCoordinator?.runModel {
            profile = profile.updateRunModel(runModel)
        }
        
        return profile
    }
}
