//
//  LevelCoordinator.swift
//  DownFall
//
//  Created by William Katz on 12/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit



enum LevelType: Int, Codable, CaseIterable {
    case first
    case second
    case third
    case boss
    case tutorial1
    case tutorial2
    
    static var gameCases: [LevelType] = [.first, .second, .third]
    static var tutorialCases: [LevelType] = [.tutorial1, .tutorial2]
}

struct Level {
    let type: LevelType
    let monsterRatio: [EntityModel.EntityType: RangeModel]
    let maxMonstersTotal: Int
    let maxMonstersOnScreen: Int
    let maxGems: Int
    let maxTime: Int
    let boardSize: Int
    let abilities: [AnyAbility]
    let goldMultiplier: Int
    let rocksRatio: [TileType: RangeModel]
    let maxSpecialRocks = 5
    
    var tutorialData: TutorialData?
    
    var isTutorial: Bool {
        return tutorialData != nil
    }
        
    static let zero = Level(type: .boss, monsterRatio: [:], maxMonstersTotal: 0, maxMonstersOnScreen: 0, maxGems: 0, maxTime: 0, boardSize: 0, abilities: [], goldMultiplier: 1, rocksRatio: [:], tutorialData: nil)
}

protocol LevelCoordinating: StoreSceneDelegate, GameSceneCoordinatingDelegate {
    var gameSceneNode: GameScene? { get set }
    var tutorialSceneNode: TutorialScene? { get set }
    var entities: EntitiesModel? { get set }
    var levels: [Level]? { get set }
    var levelIndex: Int { get set }
    
    func presentStore(_ playerData: EntityModel)
    func presentNextLevel(_ playerData: EntityModel?)
    func difficultySelected(_ difficulty: Difficulty)
}

extension LevelCoordinating where Self: UIViewController {
    
    var currentLevel: Level {
        guard let levels = levels else { fatalError("No levels") }
        return levels[levelIndex]
    }
    
    func presentStore(_ playerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            let storeScene = StoreScene(size: self.view!.frame.size,
                                        playerData: playerData,
                                        inventory: StoreInventory(),
                                        level: currentLevel)
            storeScene.storeSceneDelegate = self
            view.presentScene(storeScene)
        }
    }
    
    func presentNextLevel(_ playerData: EntityModel?) {
        switch currentLevel.type {
        case .tutorial2, .tutorial1:
            tutorialSceneNode?.prepareForReuse()
            if let scene = GKScene(fileNamed: "TutorialScene")?.rootNode as? TutorialScene,
                let entities = entities,
                let level = levels?[levelIndex] {
                tutorialSceneNode = scene
                tutorialSceneNode!.gameSceneDelegate = self
                tutorialSceneNode!.scaleMode = .aspectFill
                tutorialSceneNode!.commonInit(boardSize: level.boardSize,
                                              entities: entities,
                                              difficulty: GameScope.shared.difficulty,
                                              updatedEntity: nil,
                                              level: level)
                
                if let view = self.view as! SKView? {
                    view.presentScene(tutorialSceneNode)
                    view.ignoresSiblingOrder = true
                    
                    #if DEBUG
                    view.showsFPS = true
                    view.showsNodeCount = true
                    #endif
                }
            }
        case .first, .second, .third, .boss:
            gameSceneNode?.prepareForReuse()
            if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
                let entities = entities,
                let level = levels?[levelIndex] {
                gameSceneNode = scene
                gameSceneNode!.scaleMode = .aspectFill
                gameSceneNode!.gameSceneDelegate = self
                gameSceneNode!.commonInit(boardSize: level.boardSize,
                                          entities: entities,
                                          difficulty: GameScope.shared.difficulty,
                                          updatedEntity: playerData,
                                          level: level)
                
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
    
    func difficultySelected(_ difficulty: Difficulty) {
        levels = LevelConstructor.buildLevels(difficulty)
        levelIndex = 0
        
    }
    
    
    // MARK: - StoreSceneDelegate
    
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            presentNextLevel(updatedPlayerData)
        }
    }
    
    // MARK: - GameSceneCoordinatingDelegate
    
    func reset(_ scene: SKScene, playerData: EntityModel ) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.presentNextLevel(playerData.revive())
        }
        
    }
    
    func visitStore(_ playerData: EntityModel) {
        if let view = self.view as! SKView?, let levels = levels {
            view.presentScene(nil)
            gameSceneNode?.removeFromParent()
            
            
            let storeScene = StoreScene(size: self.view!.frame.size,
                                        playerData: playerData,
                                        inventory: StoreInventory(),
                                        level: levels[levelIndex])
            storeScene.storeSceneDelegate = self
            view.presentScene(storeScene)
            
            // Increment the level index after we visit the store
            // there might/is be a better place to do this
            levelIndex = min(levels.count - 1, levelIndex + 1)
        }
    }
}


