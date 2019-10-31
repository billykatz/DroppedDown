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


