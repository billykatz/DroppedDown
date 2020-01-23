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


func isWithinBounds(_ tileCoord: TileCoord, within tiles: [[Tile]]?) -> Bool {
    guard let tiles = tiles else { return false }
    let (tileRow, tileCol) = tileCoord.tuple
    return tileRow >= 0 && //lower bound
        tileCol >= 0 && // lower bound
        tileRow < tiles.count && // upper bound
        tileCol < tiles.count
}

func playerData(in tiles: [[Tile]]) -> EntityModel? {
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            if case TileType.player(let data) = tiles[i][j].type {
                return data
            }
        }
    }
    return nil
}

