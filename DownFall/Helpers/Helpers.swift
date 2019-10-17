//
//  Helpers.swift
//  DownFall
//
//  Created by William Katz on 6/13/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

func typeCount(for tiles: [[Tile]], of type: TileType) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            tiles[i][j].type == type ? tileCoords.append(TileCoord(i, j)) : ()
        }
    }
    return tileCoords
}
