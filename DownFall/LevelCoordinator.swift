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

protocol LevelCoordinating: GameSceneCoordinatingDelegate {
    var profileViewModel: ProfileViewModel? { get set }
    var gameSceneNode: GameScene? { get set }
    var entities: EntitiesModel? { get set }
    var delegate: MenuCoordinating? { get set }
    func presentNextLevel(_ level: Level, playerData: EntityModel?, savedTiles: [[Tile]]?)
    func loadRun(_ runModel: RunModel?, profile: Profile)
    func saveAllState(didWin: Bool) -> RunModel
    
    // Exposed so that we can save the current run
    var runModel: RunModel { get }
}

class LevelCoordinator: LevelCoordinating {
    
    struct Constants {
        static let tag = String(describing: LevelCoordinator.self)
    }

    weak var delegate: MenuCoordinating?
    var gameSceneNode: GameScene?
    var entities: EntitiesModel?
    let tutorialConductor: TutorialConductor
    let view: SKView
    
    var profileViewModel: ProfileViewModel?
    
    /// Set default so we dont have to deal with optionality
    private(set) var runModel: RunModel = .zero
    
    init(gameSceneNode: GameScene, entities: EntitiesModel, tutorialConductor: TutorialConductor, view: SKView) {
        self.gameSceneNode = gameSceneNode
        self.entities = entities
        self.tutorialConductor = tutorialConductor
        self.view = view
        
    }
    
    func presentNextLevel(_ level: Level, playerData: EntityModel?, savedTiles: [[Tile]]? = []) {
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
                                      randomSource: runModel.randomSource,
                                      stats: runModel.stats,
                                      loadedTiles: savedTiles,
                                      tutorialConductor: tutorialConductor,
                                      profileViewModel: profileViewModel,
                                      numberOfPreviousBossWins: profileViewModel?.profile.bossWins ?? 0)
            
            view.presentScene(gameSceneNode)
            view.ignoresSiblingOrder = true
            
            //Debug settings
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
            
        }
    }
    
    /// Creates a run and loads it if no current run is available
    func loadRun(_ runModel: RunModel?, profile: Profile) {
        let seed = UInt64.random(in: .min ... .max)
        
        // no saved tiles for fresh run
        var playerData = profile.runPlayer
        #if DEBUG
        playerData = ProfileViewModel.runPlayer(playerData: playerData)
        #endif
        let freshRunModel = RunModel(player: playerData, seed: seed, savedTiles: nil, areas: [], goalTracking: [], stats: [], startingUnlockables: profile.startingUnlockbles, isTutorial: { return tutorialConductor.isTutorial }, didWin: false)
        
        self.runModel = runModel ?? freshRunModel
        RunScope.deepestDepth = profile.stats.filter( { $0.statType == .lowestDepthReached }).map { $0.amount }.first ?? 0
        presentCurrentArea(updatedPlayerData: playerData)
    }
    
    /// This should be used when you want load the run from the last part
    func presentCurrentArea(updatedPlayerData: EntityModel) {
        guard let unlockables = profileViewModel?.profile.unlockables else { fatalError() }
        let nextArea = runModel.currentArea(updatedPlayerData: updatedPlayerData, unlockables: unlockables)
        switch nextArea.type {
        case .level(let level):
            presentNextLevel(level, playerData: runModel.player, savedTiles: runModel.savedTiles)
        }
    }
    
    /// This should be used most of the the time.  When ever you want to proceed in the run, you should call this function.
    func presentNextArea(updatedPlayerData: EntityModel, isTutorial: Bool) {
        guard let unlockables = profileViewModel?.profile.unlockables else { fatalError() }
        let nextArea = runModel.nextArea(updatedPlayerData: updatedPlayerData, unlockables: unlockables)
        switch nextArea.type {
        case .level(let level):
            presentNextLevel(level, playerData: runModel.player)
        }
    }
    
    func addRuneSlotIfNeeded(_ entityData: EntityModel, nextArea: Area) -> EntityModel {
        var newEntityData = entityData
        let currentRuneSlots = entityData.runeSlots ?? 0
        if (currentRuneSlots * 2 - 1) <= nextArea.depth && nextArea.depth % 2 == 0 {
            newEntityData = entityData.addRuneSlot()
        }
        
        runModel.player = newEntityData
        
        return newEntityData
        
    }
    
    
    // MARK: - GameSceneCoordinatingDelegate
    func navigateToMainMenu(_ scene: SKScene, playerData: EntityModel, didWin: Bool) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.runModel = self.saveAllState(didWin: didWin)
            self.delegate?.finishGame(playerData: playerData, currentRun: self.runModel)
        }
        
    }
    
    func navigateToTheStore(_ scene: SKScene, playerData: EntityModel, didWin: Bool) {
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.75)
        let remove = SKAction.removeFromParent()
        scene.run(SKAction.group([fadeOut, remove])) { [weak self] in
            guard let self = self else { return }
            self.runModel = self.saveAllState(didWin: didWin)
            self.delegate?.finishGameAndGoToStore(playerData: playerData, currentRun: self.runModel)
        }

    }
    
    
    
    // removes the current game scene and then triggers presentation of the next area
    func goToNextArea(updatedPlayerData: EntityModel) {
        view.presentScene(nil)
        gameSceneNode?.removeFromParent()
        
        // this code path never executes during the tutorial UX
        presentNextArea(updatedPlayerData: updatedPlayerData, isTutorial: false)
    }
    
    func saveState(didWin: Bool) {
        _ = self.saveAllState(didWin: didWin)
    }
    
    // MARK: Saving game state
    
    func saveAllState(didWin: Bool) -> RunModel {
        guard let (data, goalTracking, tiles, updatedStats, bossPhase) = self.gameSceneNode?.saveAllState() else {
            GameLogger.shared.log(prefix: Constants.tag, message: "Unable to save all state")
            return self.runModel
        }
        
        
        runModel.didWin = didWin
        runModel.stats = updatedStats
        runModel.saveGoalTracking(goalTracking)
        runModel.saveBossPhase(bossPhase)
        runModel.player = data
        runModel = saveTiles(tiles)
        
        return runModel
    }
    
    
    
    // MARK: Utility functions
    fileprivate func saveTiles(_ savedTiles: [[Tile]]) -> RunModel {
        return RunModel(player: runModel.player, seed: runModel.seed, savedTiles: savedTiles, areas: runModel.areas, goalTracking: runModel.goalTracking, stats: runModel.stats, startingUnlockables: runModel.startingUnlockables, isTutorial: { runModel.isTutorial }, didWin: runModel.didWin)
    }
    
}

