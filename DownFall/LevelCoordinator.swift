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
    
    func presentStoreOffers(_ storeOffers: [StoreOffer], depth: Int, levelGoalProgress: [GoalTracking], playerData: EntityModel)
    func presentNextLevel(_ level: Level, playerData: EntityModel?)
    func loadRun(_ runModel: RunModel?, profile: Profile)
    
    // Exposed so that we can save the current run
    var runModel: RunModel { get }
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
    
    func presentStoreOffers(_ storeOffers: [StoreOffer], depth: Int, levelGoalProgress: [GoalTracking], playerData: EntityModel) {
        view.presentScene(nil)
        let storeScene = StoreScene(size: .universalSize,
                                    playerData: playerData,
                                    levelGoalProgress: levelGoalProgress,
                                    storeOffers: storeOffers,
                                    levelDepth: depth,
                                    viewModel: StoreSceneViewModel(offers: storeOffers, goalTracking: levelGoalProgress))

        storeScene.scaleMode = .aspectFill
        storeScene.storeSceneDelegate = self
        view.presentScene(storeScene)
    }
    
    func presentNextLevel(_ level: Level, playerData: EntityModel?) {
        gameSceneNode?.prepareForReuse()
        if let scene = GKScene(fileNamed: "GameScene")?.rootNode as? GameScene,
            let entities = entities {
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
        presentCurrentArea(profile.player)
    }
    
    /// This should be used when you want load the run from the last part
    func presentCurrentArea(_ entityData: EntityModel) {
        let nextArea = runModel.currentArea()
        switch nextArea.type {
        case .level(let level):
            presentNextLevel(level, playerData: entityData)
        case .store(let offers):
            presentStoreOffers(offers, depth: nextArea.depth, levelGoalProgress: runModel.goalTracking, playerData: entityData)
        }
    }
    
    /// This should be used most of the the time.  When ever you want to proceed in the run, you should call this function.
    func presentNextArea(_ entityData: EntityModel) {
        let nextArea = runModel.nextArea()
        switch nextArea.type {
        case .level(let level):
            presentNextLevel(level, playerData: entityData)
        case .store(let offers):
            presentStoreOffers(offers, depth: nextArea.depth, levelGoalProgress: runModel.goalTracking, playerData: entityData)
        }

    }
    
    
    // MARK: - StoreSceneDelegate
    
    func leave(_ storeScene: StoreScene, updatedPlayerData: EntityModel) {
        view.presentScene(nil)
        presentNextArea(updatedPlayerData)
    }
    
    // MARK: - GameSceneCoordinatingDelegate
    func navigateToMainMenu(_ scene: SKScene, playerData: EntityModel) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.delegate?.finishGame(playerData: playerData, currentRun: self.runModel)
        }

    }
    
    func reset(_ scene: SKScene, playerData: EntityModel ) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.presentNextArea(playerData.revive())
        }
    }
    
    func visitStore(_ playerData: EntityModel, _ goalTracking: [GoalTracking]) {
        view.presentScene(nil)
        gameSceneNode?.removeFromParent()
        runModel.saveGoalTracking(goalTracking)
        presentNextArea(playerData)
    }
}


