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

protocol LevelCoordinating: StoreSceneDelegate, GameSceneCoordinatingDelegate {
    var gameSceneNode: GameScene? { get set }
    var entities: EntitiesModel? { get set }
    var levelIndex: Int { get set }
    var randomSource: GKLinearCongruentialRandomSource? { get }
    var delegate: MenuCoordinating? { get set }
    
    func presentStore(_ playerData: EntityModel)
    func presentNextLevel(_ playerData: EntityModel?)
    func startGame(profile: Profile)
}

class LevelCoordinator: LevelCoordinating {
    
    weak var delegate: MenuCoordinating?
    var gameSceneNode: GameScene?
    var entities: EntitiesModel?
    var levelIndex: Int = 0
    let view: SKView
    var randomSource: GKLinearCongruentialRandomSource?
    
    init(gameSceneNode: GameScene, entities: EntitiesModel, levelIndex: Int, view: SKView, randomSource: GKLinearCongruentialRandomSource) {
        self.gameSceneNode = gameSceneNode
        self.entities = entities
        self.levelIndex = levelIndex
        self.view = view
        self.randomSource = randomSource
    }
    
    func presentStore(_ playerData: EntityModel) {
        view.presentScene(nil)
        let currentLevel = LevelConstructor.buildLevel(depth: levelIndex)
        let storeScene = StoreScene(size: .universalSize,
                                    playerData: playerData,
                                    level: currentLevel,
                                    viewModel: StoreSceneViewModel(offers: currentLevel.storeOffering, goalTracking: currentLevel.goalProgress))
        storeScene.scaleMode = .aspectFill
        storeScene.storeSceneDelegate = self
        view.presentScene(storeScene)
    }
    
    func presentNextLevel(_ playerData: EntityModel?) {
        gameSceneNode?.prepareForReuse()
        if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
            let entities = entities {
            let level = LevelConstructor.buildLevel(depth: levelIndex)
            gameSceneNode = scene
            gameSceneNode!.scaleMode = .aspectFill
            gameSceneNode!.gameSceneDelegate = self
            gameSceneNode!.commonInit(boardSize: level.boardSize,
                                      entities: entities,
                                      difficulty: GameScope.shared.difficulty,
                                      updatedEntity: playerData,
                                      level: level,
                                      randomSource: randomSource)
            
            view.presentScene(gameSceneNode)
            view.ignoresSiblingOrder = true
            
            //Debug settings
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
                
        }
    }
    
    /// Kicks off the process of starting a new game
    func startGame(profile: Profile) {
        /// Present the store to give the player the option to take a Rune
        let player = profile.player
        presentStore(player)
    }
    
    
    // MARK: - StoreSceneDelegate
    
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel) {
        view.presentScene(nil)
        presentNextLevel(updatedPlayerData)
    }
    
    // MARK: - GameSceneCoordinatingDelegate
    func resetToMain(_ scene: SKScene, playerData: EntityModel) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.delegate?.levelSelect(playerData)
        }

    }
    
    func reset(_ scene: SKScene, playerData: EntityModel ) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.presentNextLevel(playerData.revive())
        }
    }
    
    func visitStore(_ playerData: EntityModel, _ goalTracking: [GoalTracking]) {
        view.presentScene(nil)
        gameSceneNode?.removeFromParent()
        
        
        // Increment the level index before we visit the store
        // there might/is be a better place to do this
        levelIndex = levelIndex + 1
        
        /// attached how many goals we completed so the store knows which offers to unlock
        var level = LevelConstructor.buildLevel(depth: levelIndex)
        level.goalProgress = goalTracking
        
        
        let storeScene = StoreScene(size: .universalSize,
                                    playerData: playerData,
                                    level: level,
                                    viewModel: StoreSceneViewModel(offers: level.storeOffering, goalTracking: level.goalProgress))
        storeScene.scaleMode = .aspectFill
        storeScene.storeSceneDelegate = self
        view.presentScene(storeScene)
    }
}


