//
//  Helpers.swift
//  DownFall
//
//  Created by William Katz on 6/13/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

func tileTypesOf(_ type: TileType, in tiles: [[Tile]]) -> [TileType] {
    var tileType: [TileType] = []
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            tiles[i][j].type == type ? tileType.append(tiles[i][j].type) : ()
        }
    }
    return tileType
}

func tileCoords(for tiles: [[Tile]], of type: TileType) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            tiles[i][j].type == type ? tileCoords.append(TileCoord(i, j)) : ()
        }
    }
    return tileCoords
}

func typeCount(for tileTypes: [[TileType]], of type: TileType) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in tileTypes.enumerated() {
        for (j, _) in tileTypes[i].enumerated() {
            tileTypes[i][j] == type ? tileCoords.append(TileCoord(i, j)) : ()
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

func isWithinBounds(_ tileCoord: TileCoord, within boardSize: Int) -> Bool {
    let (tileRow, tileCol) = tileCoord.tuple
    return tileRow >= 0 && //lower bound
        tileCol >= 0 && // lower bound
        tileRow < boardSize && // upper bound
        tileCol < boardSize
}

func boardHasMoreMoves(tiles: [[Tile]]) -> Bool {
    var hasMoreMoves = false
    guard let playerCoord = getTilePosition(.player(.zero), tiles: tiles) else { return hasMoreMoves }
    for row in 0..<tiles.count {
        for col in 0..<tiles[row].count {
            let tileCoord = TileCoord(row, col)
            let tile = tiles[tileCoord]
            switch tile.type {
            case .empty, .dynamite:
                hasMoreMoves = true
                
            case .rock(_, _, let groupCount):
                if groupCount >= 3 {
                    hasMoreMoves = true
                }
                
            case .monster, .exit(blocked: false), .item, .offer:
                // the player can rotate and kill a monster
                // the player can rotate into the exit
                // the player can rotate and collect an item
                // the player can rotate and collect an offer
                if tileCoord.orthogonalNeighbors.contains(playerCoord) {
                    hasMoreMoves = true
                }
                
            case .player(let data):
                // the player can use their rune that is already charged
                if (data.pickaxe?.runes.filter({ $0.isCharged }).count ?? 0) >= 1 {
                    hasMoreMoves = true
                }
                
            default:
                break
                
            }
        }
    }
    
    return hasMoreMoves
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



extension Array where Element: Collection, Element.Index == Int {
    subscript(tileCoord: TileCoord) -> Element.Iterator.Element {
        return self[tileCoord.x][tileCoord.y]
    }
}

