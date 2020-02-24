//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//


struct Level {
    let type: LevelType
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxGems: Int
    let maxTime: Int
    let boardSize: Int
    let abilities: [AnyAbility]
    let goldMultiplier: Int
    let rocksRatio: [TileType: RangeModel]
    let maxSpecialRocks = 5
    let pillarCoordinates: [(TileType, TileCoord)]
    
    var tutorialData: TutorialData?
    
    var isTutorial: Bool {
        return tutorialData != nil
    }
        
    static let zero = Level(type: .first, monsterTypeRatio: [:], monsterCountStart: 0, maxGems: 0, maxTime: 0, boardSize: 0, abilities: [], goldMultiplier: 1, rocksRatio: [:], pillarCoordinates: [], tutorialData: nil)
}
