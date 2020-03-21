//
//  TilesHelper.swift
//  DownFall
//
//  Created by William Katz on 4/2/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

func getTilePosition(_ type: TileType, tiles: [[Tile]]) -> TileCoord? {
    for i in 0..<tiles.count {
        for j in 0..<tiles[i].count {
            if tiles[i][j].type == type {
                return TileCoord(i,j)
            }
        }
    }
    return nil
}

func getTilePositions(_ type: TileType, tiles: [[Tile]]) -> Set<TileCoord>? {
    var coords = Set<TileCoord>()
    for i in 0..<tiles.count {
        for j in 0..<tiles[i].count {
            if tiles[i][j].type == type {
                coords.insert(TileCoord(i,j))
            }
        }
    }
    if !coords.isEmpty { return coords }
    return nil
}

func tileIndices(of type: TileType, in tiles: [[Tile]]) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            tiles[i][j].type == type ? tileCoords.append(TileCoord(i, j)) : ()
        }
    }
    return tileCoords
}


