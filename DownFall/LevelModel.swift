//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

enum LevelGoalType: Hashable {
    case unlockExit
}

enum LevelGoalReward: Hashable {
    case gem(Int)
    
    var currency: Currency{
        switch self {
        case .gem:
            return .gem
        }
    }
    
    var amount: Int {
        switch self {
        case .gem(let amt): return amt
        }
    }
}

struct LevelGoal: Hashable {
    let type: LevelGoalType
    let reward: LevelGoalReward
    let tileType: TileType
    let targetAmount: Int
    let minimumGroupSize: Int
    let grouped: Bool
}

struct Level {
    let type: LevelType
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let maxGems: Int
    let maxTime: Int
    let boardSize: Int
    let abilities: [AnyAbility]
    let goldMultiplier: Int
    let rocksRatio: [TileType: RangeModel]
    let maxSpecialRocks = 5
    let pillarCoordinates: [(TileType, TileCoord)]
    let threatLevelController:  ThreatLevelController
    let goals: [LevelGoal]
    let numberOfGoalsNeedToUnlockExit: Int
    let maxSpawnGems: Int
    let storeOffering: [StoreOffer]
    var goalProgress: [GoalTracking] = []
    
    var tutorialData: TutorialData?
    
    var isTutorial: Bool {
        return tutorialData != nil
    }
    
    var hasExit: Bool {
        return type != .boss
    }
    
    var spawnsMonsters: Bool {
        return type != .boss
    }
        
    static let zero = Level(type: .first, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, maxGems: 0, maxTime: 0, boardSize: 0, abilities: [], goldMultiplier: 1, rocksRatio: [:], pillarCoordinates: [], threatLevelController:  ThreatLevelController(), goals: [LevelGoal(type: .unlockExit, reward: .gem(0), tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], numberOfGoalsNeedToUnlockExit: 0, maxSpawnGems: 0, storeOffering: [], tutorialData: nil)
}
