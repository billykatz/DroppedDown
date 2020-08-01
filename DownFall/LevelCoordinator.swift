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
    var randomSource: GKLinearCongruentialRandomSource? { get }
    var delegate: MenuCoordinating? { get set }
    
    func presentStore(_ playerData: EntityModel)
    func presentNextLevel(_ playerData: EntityModel?)
    func startGame(profile: Profile)
    func loadRun(_ runModel: RunModel?, profile: Profile)
}

class LevelCoordinator: LevelCoordinating {
    
    weak var delegate: MenuCoordinating?
    var gameSceneNode: GameScene?
    var entities: EntitiesModel?
    let view: SKView
    var randomSource: GKLinearCongruentialRandomSource?
    var runModel: RunModel = RunModel(player: .zero, depth: 0)
        
    init(gameSceneNode: GameScene, entities: EntitiesModel, levelIndex: Int, view: SKView, randomSource: GKLinearCongruentialRandomSource) {
        self.gameSceneNode = gameSceneNode
        self.entities = entities
        self.view = view
        self.randomSource = randomSource
        
    }
    
    func presentStore(_ playerData: EntityModel) {
        view.presentScene(nil)
        let currentLevel = runModel.currentLevel()
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
            let level = runModel.currentLevel()
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
    
    /// Loads up a model or creates a new one
    func loadRun(_ runModel: RunModel?, profile: Profile) {
        let freshRunModel = RunModel(player: profile.player, depth: 0)
        
        self.runModel = runModel ?? freshRunModel
        presentStore(profile.player)
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
            self.delegate?.finishGame(playerData: playerData)
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
        runModel.depth += 1
        
        /// attached how many goals we completed so the store knows which offers to unlock
        var level = runModel.currentLevel()
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


