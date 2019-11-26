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

struct GameScope {
    static var shared: GameScope = GameScope(difficulty: .normal)
    var difficulty: Difficulty
    
    static let tutorialOne = TutorialData(sections:
        [
            TutorialSection(steps:
                [
                    TutorialStep(dialog: "Welcome to the Mine! You're a coal minter with extraordinary powers",
                                 highlightType: [.player(.zero)],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "This is a rare gem, let's collect it!",
                                 highlightType: [.gold],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "These are rocks, you can destory them with a tap of your finger",
                                 highlightType: TileType.rockCases,
                                 inputToContinue: InputType.touch(.zero, .empty))
                ]
            ),
            TutorialSection(steps:
                [
                    TutorialStep(dialog: "You're very close to the gem, but you can only move down",
                                 highlightType: [.gold],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "Fear not! You can use your powers to rotate the board and fall on to the gem",
                                 highlightType: [],
                                 tapToContinue: true,
                                 inputToContinue: InputType.tutorial(.zero)),
                    TutorialStep(dialog: "Rotate to collect the gem",
                                            highlightType: [],
                                            showClockwiseRotate: true,
                                            inputToContinue: InputType.rotateCounterClockwise)
                ]
            )
        ]
    )
}

class GameViewController: UIViewController {

    private var gameSceneNode: GameScene?
    private var tutorialSceneNode: TutorialScene?
    private var boardSize = 8
    private var entities: [EntityModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: handle failure more gracefully. ie redownload or retry
        let entityData = try! Data.data(from: "entities")!
        entities = try! JSONDecoder().decode(EntitiesModel.self, from: entityData).entities
        visitStore(entities![0])
        
        
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
                    //TODO: remove for release
                    view.showsFPS = true
                    view.showsNodeCount = true

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
            tutorialSceneNode!.commonInit(boardSize: 4, //FIXME: dont hardcode 
                                      entities: entities,
                                      difficulty: GameScope.shared.difficulty,
                                      updatedEntity: nil)

            if let view = self.view as! SKView? {
                view.presentScene(tutorialSceneNode)
                view.ignoresSiblingOrder = true

                //Debug settings
                //TODO: remove for release
                view.showsFPS = true
                view.showsNodeCount = true

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


extension GameViewController: GameSceneDelegate {
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
