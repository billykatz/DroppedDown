//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

enum LevelGoalType: String {
    case unlockExit
}

struct LevelGoal: Equatable, Hashable {
    let typeAmounts: [TileType: Int]
    let type: LevelGoalType
    
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
        
    static let zero = Level(type: .first, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, maxGems: 0, maxTime: 0, boardSize: 0, abilities: [], goldMultiplier: 1, rocksRatio: [:], pillarCoordinates: [], threatLevelController:  ThreatLevelController(), goals: [LevelGoal(typeAmounts: [:], type: .unlockExit)], tutorialData: nil)
}
