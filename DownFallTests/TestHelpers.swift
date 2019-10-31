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
