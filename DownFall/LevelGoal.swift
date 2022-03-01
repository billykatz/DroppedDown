//
//  LevelGoal.swift
//  DownFall
//
//  Created by Billy on 3/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
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
