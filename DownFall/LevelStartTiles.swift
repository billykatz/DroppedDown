//
//  LevelStartTiles.swift
//  DownFall
//
//  Created by Billy on 3/1/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

struct LevelFeatures: Codable, Hashable {
    let encasements: [LevelStartTiles]
    let pillars: [LevelStartTiles]
    
    var levelStartTiles: [LevelStartTiles] {
        var all = encasements
        all.append(contentsOf: pillars)
        return all
    }
    
}

struct LevelStartTiles: Codable, Hashable {
    let tileType: TileType
    let tileCoord: TileCoord
    
    init(tileType: TileType, tileCoord: TileCoord) {
        self.tileType = tileType
        self.tileCoord = tileCoord
    }
}

struct EncasementCoords: Equatable, Hashable {
    let middleTile: TileCoord
    let outerTiles: [TileCoord]
    
    var allCoords: [TileCoord] {
        var allTiles = outerTiles
        allTiles.append(middleTile)
        return allTiles
    }
}

