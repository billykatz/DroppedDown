//
//  TestHelpers.swift
//  DownFallTests
//
//  Created by William Katz on 10/31/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import Shift_Shaft
 

func toTileStructs(tileTypes: [[TileType]]) -> [[Tile]] {
    var newTiles: [[Tile]] = []
    let tiles = tileTypes.flatMap { $0 }
    let boardSize = tileTypes.count
    for i in 0..<boardSize {
        let row = tiles[boardSize*i..<boardSize*(i+1)]
        var newRow: [Tile] = []
        for type in row {
            newRow.append(Tile(type: type))
        }
        newTiles.append(newRow)
    }
    return newTiles
}

extension Level {
    static var test: Level {
        
        
        let tileChances = TileTypeChanceModel(chances: [.rock(color: .blue, holdsGem: false, groupCount: 0):5, .rock(color: .red, holdsGem: false, groupCount: 0): 5])
        return Level(depth: 0, monsterTypeRatio: LevelConstructor.monsterTypes(depth: 0), monsterCountStart: 2, maxMonsterOnBoardRatio: 0.7, boardSize: 4, tileTypeChances: tileChances, maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, gemsSpawned: 0, monsterSpawnTurnTimer: 0, startingUnlockables: [], otherUnlockables: [], randomSeed: 0, isTutorial: false, runModel: nil)
        
    }
}
