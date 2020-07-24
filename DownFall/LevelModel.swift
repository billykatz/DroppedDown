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
    case useRune
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
    
    static func gemGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .gem, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func killMonsterGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .monster(.zeroedEntity(type: .rat)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func pillarGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .pillar(PillarData(color: .blue, health: 1)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func useRuneGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .useRune, reward: .gem(1), tileType: .empty, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
}

struct Level {
    let type: LevelType
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
    let maxSpecialRocks = 5
    let pillarCoordinates: [(TileType, TileCoord)]
    let goals: [LevelGoal]
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
        
    static let zero = Level(type: .first, depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), pillarCoordinates: [], goals: [LevelGoal(type: .unlockExit, reward: .gem(0), tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], maxSpawnGems: 0, storeOffering: [], tutorialData: nil)
}
