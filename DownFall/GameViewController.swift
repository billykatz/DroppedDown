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

class GameViewController: UIViewController, LevelCoordinating {
    

    internal var gameSceneNode: GameScene?
    internal var tutorialSceneNode: TutorialScene?
    internal var entities: EntitiesModel?
    internal var levelIndex: Int = 1
    internal var levels: [Level]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            guard let entityData = try Data.data(from: "entities") else { fatalError("Crashing here is okay because we failed to parse our entity json file") }
            entities = try JSONDecoder().decode(EntitiesModel.self, from: entityData)
            levelSelect(entities!.entities[0])
        }
        catch(let error) {
            fatalError("Crashing due to \(error) while trying to parse json entity file")
        }
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
}

extension GameViewController {
    
    func levelSelect(_ updatedPlayerData: EntityModel) {
        if let mainMenuScene = GKScene(fileNamed: Identifiers.mainMenuScene)?.rootNode as? MainMenu {
            mainMenuScene.scaleMode = .aspectFill
            mainMenuScene.mainMenuDelegate = self
            mainMenuScene.playerModel = updatedPlayerData

            if let view = self.view as! SKView? {
                view.presentScene(mainMenuScene)
                view.ignoresSiblingOrder = true
            }

        }
    }
}

extension GameViewController: MainMenuDelegate {
    func didSelectStartTutorial(_ playerModel: EntityModel?) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            levels = LevelConstructor.buildTutorialLevels()
            presentNextLevel(playerModel)
        }
    }
    
    func setFrame() {
        view.frame = CGRect(x: view.frame.origin.x,
                            y: view.frame.origin.y,
                            width: self.view.frame.width,
                            height: self.view.safeAreaLayoutGuide.layoutFrame.height)
    }
    
    func newGame(_ difficulty: Difficulty, _ playerModel: EntityModel?, level: LevelType) {
        if let view = self.view as! SKView?, let player = playerModel {
            view.presentScene(nil)
            startGame(player: player, difficulty: difficulty, level: level)
        }
    }
}
