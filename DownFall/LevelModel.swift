//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

enum LevelGoalType: String, Codable, Hashable {
    case unlockExit
    case useRune
}

struct LevelGoal: Codable, Hashable {
    let type: LevelGoalType
    let tileType: TileType
    let targetAmount: Int
    let minimumGroupSize: Int
    let grouped: Bool
    
    static func gemGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .gem, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func killMonsterGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .monster(.zeroedEntity(type: .rat)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func pillarGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .pillar(PillarData(color: .blue, health: 1)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func useRuneGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .useRune, tileType: .empty, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
}

struct PillarCoorindates: Codable, Hashable {
    let pillar: TileType
    let coord: TileCoord
    
    init(_ tuple: (TileType, TileCoord)) {
        self.pillar = tuple.0
        self.coord = tuple.1
    }
    
}

struct Level: Codable, Hashable {
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
    let pillarCoordinates: [PillarCoorindates]
    let goals: [LevelGoal]
    let maxSpawnGems: Int
    var goalProgress: [GoalTracking]
    let potentialItems: [StoreOffer]
    
    var hasExit: Bool {
        return true
    }
    
    var spawnsMonsters: Bool {
        return true
    }
    
    var isBossLevel: Bool {
        return bossLevelDepthNumber == depth
    }
    
    var humanReadableDepth: String {
        return "\(depth + 1)"
    }
        
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), pillarCoordinates: [], goals: [LevelGoal(type: .unlockExit, tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], maxSpawnGems: 0, goalProgress: [], potentialItems: [])
}
