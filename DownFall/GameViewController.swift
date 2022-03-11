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
    
    struct Constants {
        static let tag = String(describing: GameViewController.self)
    }
    
    private var entities: EntitiesModel?
    private var loadingSceneNode: LoadingScene!
    
    /// coordinators
    private var levelCoordinator: LevelCoordinating?
    private var menuCoordinator: MenuCoordinator?
    
    private var tutorialConductor: TutorialConductor?
    private var ftueMetagameConductor: FTUEConductor?
    
    private var profileHasLoaded: Bool = false
    
    public var profile: Profile? = nil {
        didSet {
            guard let profile = profile else {
                return
            }
            profileHasLoaded = true
            loadingSceneNode?.fadeOut {
                let hasLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaults.hasLaunchedBeforeKey)
                self.menuCoordinator?.loadedProfile(profile, hasLaunchedBefore: hasLaunchedBefore)
                
                if !hasLaunchedBefore {
                    // let's see if turning off sounds by defaults helps with crashes
                    UserDefaults.standard.setValue(true, forKey: UserDefaults.muteSoundKey)
                    
                    UserDefaults.standard.setValue(true, forKey: UserDefaults.hasLaunchedBeforeKey)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameLogger.shared.log(prefix: Constants.tag, message: "View did load start")
        
        /// Needed when we stopped using a storyboard
        view = SKView(frame: view.bounds)
        
        /// Show the loading screeen
        let view = view as! SKView
        loadingSceneNode = GKScene(fileNamed: "LoadingScene")!.rootNode as? LoadingScene
        loadingSceneNode.scaleMode = .aspectFill
        view.presentScene(loadingSceneNode)
        
        // create the entities array from the local json file
        do {
            guard let entityData = try Data.data(from: "entities") else {
                return GameLogger.shared.fatalLog(prefix: Constants.tag, message: "Crashing here is okay because we failed to parse our entity json file")
            }
            entities = try JSONDecoder().decode(EntitiesModel.self, from: entityData)
        }
        catch(let error) {
            return GameLogger.shared.fatalLog(prefix: Constants.tag, message: "Crashing due to \(error) while trying to parse json entity file")
        }
        
        /// Init the coordinators
        guard let gameScene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
              let entities = entities,
              let view = self.view as? SKView
        else {
            return GameLogger.shared.fatalLog(prefix: Constants.tag, message: "Lack of necessary information to init coordinators")
        }
        
        /// set up the tutorial conductor
        let tutorialConductor = TutorialConductor()
        self.tutorialConductor = tutorialConductor
        
        // other FTUE conductor
        let ftueMetagameConductor = FTUEConductor()
        self.ftueMetagameConductor = ftueMetagameConductor
        
        /// setup the coordinators
        let levelCoordinator = LevelCoordinator(gameSceneNode: gameScene, entities: entities, tutorialConductor: tutorialConductor, view: view)
        let codexCoordinator = CodexCoordinator(viewController: self.navigationController!, delegate: levelCoordinator)
        let settingsCoordinator = SettingsCoordinator(viewController: self.navigationController!)
        let creditsCoordinator = CreditsCoordinator(viewController: self.navigationController!)
        
        self.menuCoordinator = MenuCoordinator(levelCoordinator: levelCoordinator, codexCoordinator: codexCoordinator, settingsCoordinator: settingsCoordinator, tutorialConductor: tutorialConductor, creditsCoordinator: creditsCoordinator,  view: view)
        self.levelCoordinator = levelCoordinator
        self.levelCoordinator?.delegate = menuCoordinator
        
        GameLogger.shared.log(prefix: Constants.tag, message: "View did load finished")
    }
    
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return false
        } else {
            return true
        }
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
    func applicationDidEnterBackground() -> Profile? {
        guard profileHasLoaded else { return nil }
        
        GameLogger.shared.log(prefix: Constants.tag, message: "Saving the profile")
        
        guard var profile = menuCoordinator?.profileViewModel?.profile else {
            GameLogger.shared.fatalLog(prefix: Constants.tag, message: "Cannot continue without the profile")
            fatalError()
        }

        
        /// If we are able to update the run model, then update our profile
        if let runModel = levelCoordinator?.saveAllState() {
            GameLogger.shared.log(prefix: Constants.tag, message: "Run model updated")
            profile = profile.updateRunModel(runModel)
        }
        
        
        GameLogger.shared.log(prefix: Constants.tag, message: "Returning profile")
        return profile
    }
}
