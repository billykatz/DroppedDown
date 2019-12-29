//
//  TestHelpers.swift
//  DownFallTests
//
//  Created by William Katz on 10/31/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
@testable import DownFall
 

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
        return Level(type: .first, monsterRatio: LevelConstructor.monstersPerLevel(.first, difficulty: .easy), maxMonstersTotal: 10, maxMonstersOnScreen: 5, maxGems: 1, maxTime: 30, boardSize: 4, abilities: [], goldMultiplier: 2, rocksRatio: LevelConstructor.availableRocksPerLevel(.first, difficulty: .easy), tutorialData: nil)
    }
}
