//
//  LevelStartTiles.swift
//  DownFall
//
//  Created by Billy on 3/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

struct LevelStartTiles: Codable, Hashable {
    let tileType: TileType
    let tileCoord: TileCoord
    
    init(tileType: TileType, tileCoord: TileCoord) {
        self.tileType = tileType
        self.tileCoord = tileCoord
    }
}

struct EncasementCoords: Equatable {
    let middleTile: TileCoord
    let outerTiles: [TileCoord]
}

