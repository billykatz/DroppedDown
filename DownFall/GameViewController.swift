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

    private var gameSceneNode: GameScene?
    private var tutorialSceneNode: TutorialScene?
    private var boardSize = 8
    private var entities: [EntityModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            guard let entityData = try Data.data(from: "entities") else { fatalError("Crashing here is okay because we failed to parse our entity json file") }
            entities = try JSONDecoder().decode(EntitiesModel.self, from: entityData).entities
            visitStore(entities![0])
        }
        catch(let error) {
            fatalError("Crashing due to \(error) while trying to parse json entity file")
        }
        
        //MARK: Set default difficulty
        GameScope.shared.difficulty = .tutorial1
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
    private func levelSelect() {
        if let levelSelectScene = GKScene(fileNamed: "LevelSelect")?.rootNode as? LevelSelect {
            levelSelectScene.scaleMode = .aspectFill
            levelSelectScene.levelSelectDelegate = self
            
            if let view = self.view as! SKView? {
                view.presentScene(levelSelectScene)
                view.ignoresSiblingOrder = true
            }
            
        }
    }
    
    private func startLevel(_ updatedPlayerData: EntityModel? = nil) {
        
        //TODO: this needs to be coordinated in an intelligent way
        if true {
            startTutorial(updatedPlayerData)
        } else {
            gameSceneNode?.prepareForReuse()
            if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
                let entities = entities {
                gameSceneNode = scene
                gameSceneNode!.scaleMode = .aspectFill
                gameSceneNode!.gameSceneDelegate = self
                gameSceneNode!.commonInit(boardSize: boardSize,
                                          entities: entities,
                                          difficulty: GameScope.shared.difficulty,
                                          updatedEntity: updatedPlayerData)

                if let view = self.view as! SKView? {
                    view.presentScene(gameSceneNode)
                    view.ignoresSiblingOrder = true

                    //Debug settings
                    #if DEBUG
                    view.showsFPS = true
                    view.showsNodeCount = true
                    #endif

                }
            }
        }
    }
    
    private func startTutorial(_ updatedPlayerData: EntityModel? = nil) {
        tutorialSceneNode?.prepareForReuse()
        if let scene = GKScene(fileNamed: "TutorialScene")?.rootNode as? TutorialScene,
            let entities = entities {
            tutorialSceneNode = scene
            tutorialSceneNode!.gameSceneDelegate = self
            tutorialSceneNode!.scaleMode = .aspectFill
            tutorialSceneNode!.commonInit(boardSize: 4,
                                          entities: entities,
                                          difficulty: GameScope.shared.difficulty,
                                          updatedEntity: nil)

            if let view = self.view as! SKView? {
                view.presentScene(tutorialSceneNode)
                view.ignoresSiblingOrder = true

                #if DEBUG
                view.showsFPS = true
                view.showsNodeCount = true
                #endif
            }
        }

    }
}

extension GameViewController: LevelSelectDelegate {
    func didSelect(_ difficulty: Difficulty) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            GameScope.shared.difficulty = difficulty
            startLevel()
        }
    }
}

extension GameViewController: StoreSceneDelegate {
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            startLevel(updatedPlayerData)
        }

    }
}


extension GameViewController: GameSceneCoordinatingDelegate {
    func selectLevel() {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            levelSelect()
        }

    }
    
    func visitStore(_ playerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            gameSceneNode?.removeFromParent()
            
            
            let storeScene = StoreScene(size: self.view!.frame.size,
                                        playerData: playerData,
                                        inventory: StoreInventory())
            storeScene.storeSceneDelegate = self
            view.presentScene(storeScene)
        }
        
    }
    
    func reset(_ scene: SKScene) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            self?.startLevel()
        }
    }
    
   
}
