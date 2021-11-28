//
//  RunManaging.swift
//  DownFall
//
//  Created by Katz, Billy on 8/1/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import GameKit


class RunModel: Codable, Equatable {
    static func == (lhs: RunModel, rhs: RunModel) -> Bool {
        return lhs.seed == rhs.seed
    }
    
    static let zero = RunModel(player: .zero, seed: 0, savedTiles: nil, areas: [], goalTracking: [], stats: [], unlockables: [], startingUnlockables: [], isTutorial: { false })
    
    let seed: UInt64
    var player: EntityModel
    // save the tiles
    var savedTiles: [[Tile]]?
    
    /// Keep track of areas
    var areas: [Area] = []
    
    var goalTracking: [GoalTracking] = []
    
    var stats: [Statistics] = []
    
    var unlockables: [Unlockable]
    var startingUnlockables: [Unlockable]
    
    //tutorial
    let isTutorial: Bool
    
    lazy var randomSource: GKLinearCongruentialRandomSource = {
        return GKLinearCongruentialRandomSource(seed: seed)
    }()
    
    var depth: Int {
        return areas.last?.depth ?? 0
    }
    
    
    init(player: EntityModel, seed: UInt64, savedTiles: [[Tile]]?, areas: [Area], goalTracking: [GoalTracking], stats: [Statistics], unlockables: [Unlockable], startingUnlockables: [Unlockable], isTutorial: () -> Bool) {
        self.player = player
        self.seed = seed
        self.savedTiles = savedTiles
        self.areas = areas
        self.goalTracking = goalTracking
        self.stats = stats
        self.unlockables = unlockables
        self.startingUnlockables = startingUnlockables
        self.isTutorial = isTutorial()
    }
    
    func saveGoalTracking(_ goalTracking: [GoalTracking]) {
        self.goalTracking = goalTracking
        
        /// update the last area with the goal tracking
        if let lastArea = areas.last,
           let lastAreaIndex = areas.lastIndex(of: lastArea),
           case var AreaType.level(level) = lastArea.type {
            
            /// save the goal progress
            level.goalProgress = goalTracking
            
            // wrap it in a AreaType
            let newAreaType = AreaType.level(level)
            
            /// replace it with one with saved goal tracking
            areas[lastAreaIndex] = Area(depth: lastArea.depth, type: newAreaType)
            
        }
    }
    
    func saveBossPhase(_ phase: BossPhase) {
        /// update the last area with the goal tracking
        if let lastArea = areas.last,
           let lastAreaIndex = areas.lastIndex(of: lastArea),
           case var AreaType.level(level) = lastArea.type {
            
            /// save the goal progress
            level.savedBossPhase = phase
            
            // wrap it in a AreaType
            let newAreaType = AreaType.level(level)
            
            /// replace it with one with saved goal tracking
            areas[lastAreaIndex] = Area(depth: lastArea.depth, type: newAreaType)
            
        }
    }
    
    /// Return the level that corresponds with the depth
    /// If that level has not been built yet, then build it, append it to our private level store, and return the newly built level
    func currentArea(updatedPlayerData: EntityModel) -> Area {
        self.player = updatedPlayerData
        guard areas.count > 0, let currentArea = areas.last else {
            return nextArea(updatedPlayerData: updatedPlayerData)
        }
        return currentArea
    }
    
    
    /// Creates a new area and appends to the internal array of Areas
    /// There is no more store so this always returns a level
    /// If there was no last level, it is a fresh run, so we return a store, for now.
    func nextArea(updatedPlayerData: EntityModel) -> Area {
        self.player = updatedPlayerData
        let nextDepth: Int
        #warning("Debugging boss level")
        if let last = areas.last { nextDepth = last.depth + 1 }
        else { nextDepth = 0 }
//        else { nextDepth = bossLevelDepthNumber }
//        else { nextDepth = testLevelDepthNumber }
        let nextLevel = LevelConstructor.buildLevel(depth: nextDepth, randomSource: randomSource, playerData: player, unlockables: unlockables, startingUnlockables: startingUnlockables, isTutorial: isTutorial)
        let nextArea = Area(depth: nextDepth, type: .level(nextLevel))
        areas.append(nextArea)
        return nextArea
    }
}
