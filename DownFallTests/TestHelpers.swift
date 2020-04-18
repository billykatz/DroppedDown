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
        return Level(type: .first, monsterTypeRatio: LevelConstructor.monsterTypes(per: .first, difficulty: .easy), monsterCountStart: 2, maxMonsterOnBoardRatio: 0.07, maxGems: 1, maxTime: Int(30.0), boardSize: 4, abilities: [], goldMultiplier: 2, rocksRatio: LevelConstructor.availableRocksPerLevel(.first, difficulty: .easy), pillarCoordinates: [], threatLevelController: ThreatLevelController(), goals: [], numberOfGoalsNeedToUnlockExit: 0, maxSpawnGems: 0, tutorialData: nil)
    }
}
