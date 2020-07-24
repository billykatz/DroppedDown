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
    
    var randomSource: GKLinearCongruentialRandomSource?

    internal var gameSceneNode: GameScene?
    internal var tutorialSceneNode: TutorialScene?
    internal var entities: EntitiesModel?
    internal var levelIndex: Int = 1
    internal var levels: [Level]?
    var loadingSceneNode: LoadingScene?
    
    /// coordinators
    var levelCoordinator: LevelCoordinating?
    var menuCoordinator: MenuCoordinating?
    
    public var profile: Profile? = nil {
        didSet {
            guard let profile = profile else { return }
            loadingSceneNode?.fadeOut {
                self.menuCoordinator?.newGame(profile: profile)
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Needed when we stopped using a storyboard
        view = SKView(frame: view.bounds)
        
        do {
            guard let entityData = try Data.data(from: "entities") else { fatalError("Crashing here is okay because we failed to parse our entity json file") }
            entities = try JSONDecoder().decode(EntitiesModel.self, from: entityData)
            
            //TODO: add the actual seed to this source
            randomSource = GKLinearCongruentialRandomSource()
            
            /// Show the loading screeen
            if let view = view as? SKView,
                let loadingScene = GKScene(fileNamed: "LoadingScene")?.rootNode as? LoadingScene {
                loadingScene.scaleMode = .aspectFill
                view.presentScene(loadingScene)
                loadingSceneNode = loadingScene
            }
        }
        catch(let error) {
            fatalError("Crashing due to \(error) while trying to parse json entity file")
        }
        
        guard let gameScene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene, let entities = entities, let randomSource = randomSource else { fatalError() }
        let levelCoordinator = LevelCoordinator.init(gameSceneNode: gameScene, entities: entities, levelIndex: 0, view: view as! SKView, randomSource: randomSource)
        self.menuCoordinator = MenuCoordinator(levelCoordinator: levelCoordinator)
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
    
    func setFrame() {
        view.frame = CGRect(x: view.frame.origin.x,
                            y: view.frame.origin.y,
                            width: self.view.frame.width,
                            height: self.view.safeAreaLayoutGuide.layoutFrame.height)
    }
}
