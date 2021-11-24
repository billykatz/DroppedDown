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
    case destroyBoss
}

struct LevelGoal: Codable, Hashable {
    let type: LevelGoalType
    let tileType: TileType
    let targetAmount: Int
    let minimumGroupSize: Int
    let grouped: Bool
    
    static func bossGoal() -> LevelGoal {
        return LevelGoal(type: .destroyBoss, tileType: .empty, targetAmount: 1, minimumGroupSize: 1, grouped: false)
    }
    
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

class Level: Codable, Hashable {
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
    var savedBossPhase: BossPhase?
    let potentialItems: [StoreOffer]
    var gemsSpawned: Int
    var monsterSpawnTurnTimer: Int
    
    init(
        depth: Depth,
        monsterTypeRatio: [EntityModel.EntityType: RangeModel],
        monsterCountStart: Int,
        maxMonsterOnBoardRatio: Double,
        boardSize: Int,
        tileTypeChances: TileTypeChanceModel,
        pillarCoordinates: [PillarCoorindates],
        goals: [LevelGoal],
        maxSpawnGems: Int,
        goalProgress: [GoalTracking],
        savedBossPhase: BossPhase?,
        potentialItems: [StoreOffer],
        gemsSpawned: Int,
        monsterSpawnTurnTimer: Int
    ) {
        self.depth = depth
        self.monsterTypeRatio = monsterTypeRatio
        self.monsterCountStart = monsterCountStart
        self.maxMonsterOnBoardRatio = maxMonsterOnBoardRatio
        self.boardSize = boardSize
        self.tileTypeChances = tileTypeChances
        self.pillarCoordinates = pillarCoordinates
        self.goals = goals
        self.maxSpawnGems = maxSpawnGems
        self.goalProgress = goalProgress
        self.savedBossPhase = savedBossPhase
        self.potentialItems = potentialItems
        self.gemsSpawned = gemsSpawned
        self.monsterSpawnTurnTimer = monsterSpawnTurnTimer
    }
    
    static func ==(_ lhs: Level, _ rhs: Level) -> Bool {
        return lhs.depth == rhs.depth
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(depth)
    }
    
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
    
    var numberOfIndividualColumns: Int {
        return 3*pillarCoordinates.count
    }
    
    func monsterChanceOfShowingUp(tilesSinceMonsterKilled: Int) -> Int {
        switch depth {
        case 0,1:
            if tilesSinceMonsterKilled < 20 {
                return -1
            } else if tilesSinceMonsterKilled < 50 {
                return 3
            } else {
                return 10
            }
            
        case 2,3,4:
            if tilesSinceMonsterKilled < 20 {
                return -1
            } else if tilesSinceMonsterKilled < 45 {
                return 4
            } else {
                return 15
            }
            
        case 5, 6:
            if tilesSinceMonsterKilled < 25 {
                return -1
            } else if tilesSinceMonsterKilled < 40 {
                return 4
            } else {
                return 17
            }
            
        case 7,8:
            if tilesSinceMonsterKilled < 25 {
                return -1
            } else if tilesSinceMonsterKilled < 40 {
                return 4
            } else {
                return 20
            }

        case bossLevelDepthNumber:
            return -1
            
        default:
            return -1
        }
    }
        
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), pillarCoordinates: [], goals: [LevelGoal(type: .unlockExit, tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, potentialItems: [], gemsSpawned: 0, monsterSpawnTurnTimer: 0)
}
