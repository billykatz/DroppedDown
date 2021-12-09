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

func tileCoords(for sprites: [[DFTileSpriteNode]], of type: TileType) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in sprites.enumerated() {
        for (j, _) in sprites[i].enumerated() {
            sprites[i][j].type == type ? tileCoords.append(TileCoord(i, j)) : ()
        }
    }
    return tileCoords
}

func tileCoords(for tiles: [[Tile]], of types: [TileType]) -> [TileCoord] {
    var tileCoords: [TileCoord] = []
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            types.contains(where: { tiles[i][j].type == $0 }) ? tileCoords.append(TileCoord(i, j)) : ()
        }
    }
    return tileCoords
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

/// Return true if a neighbor coord is within the bounds of the board
/// within one tile in a cardinal direction of the currCoord
/// and not equal to the currCoord
func valid(neighbor: TileCoord?, for currCoord: TileCoord?, boardSize: Int) -> Bool {
    guard let (neighborRow, neighborCol) = neighbor?.tuple,
          let (tileRow, tileCol) = currCoord?.tuple else { return false }
    guard neighborRow >= 0, //lower bound
          neighborCol >= 0, // lower bound
          neighborRow < boardSize, // upper bound
          neighborCol < boardSize, // upper bound
          neighbor != currCoord // not the same coord
    else { return false }
    let tileSum = tileRow + tileCol
    let neighborSum = neighborRow + neighborCol
    let difference = abs(neighborSum - tileSum)
    guard difference <= 1 //tiles are within one of eachother
            && ((tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0)) // they are not diagonally touching
    else { return false }
    return true
}

/// Find all contiguous neighbors of the same color as the tile that was tapped
func findNeighbors(in tiles: [[Tile]], of coord: TileCoord, boardSize: Int, killMonsters: Bool = false) -> ([TileCoord], [TileCoord]) {
    let (x,y) = coord.tuple
    guard
        x >= 0,
        x < boardSize,
        y >= 0,
        y < boardSize else { return ([], []) }
    
    if case TileType.monster = tiles[x][y].type, !killMonsters { return ([],[]) }
    if case TileType.pillar = tiles[x][y].type { return ([],[]) }
    var queue = [TileCoord(x, y)]
//    if killMonsters {
//        if case TileType.monster = tiles[x][y].type {
//            queue.append(TileCoord(x, y))
//        }
//    } else {
//        queue.append(TileCoord(x, y))
//    }
    var tileCoordSet = Set(queue)
    var head = 0
    var pillars = Set<TileCoord>()
    
    while head < queue.count {
        let tileRow = queue[head].x
        let tileCol = queue[head].y
        let currTile = tiles[tileRow][tileCol]
        head += 1
        //add neighbors to queue
        for i in tileRow-1...tileRow+1 {
            for j in tileCol-1...tileCol+1 {
                //check that it is within bounds, that we havent visited it before, and it's the same type as us
                if killMonsters {
                    guard
                        valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol), boardSize: tiles.count),
                        !tileCoordSet.contains(TileCoord(i,j)) else { continue }
                    if case .monster = tiles[i][j].type,
                       case .monster = currTile.type {
                        queue.append(TileCoord(i,j))
                        tileCoordSet.insert(TileCoord(row: i, column: j))
                    }
                } else {
                    guard
                        valid(neighbor: TileCoord(i,j), for: TileCoord(tileRow, tileCol), boardSize: tiles.count),
                        !tileCoordSet.contains(TileCoord(i,j)),
                        let myColor = tiles[i][j].type.color,
                        let theirColor = currTile.type.color,
                        myColor == theirColor else { continue }
                    //valid neighbor within bounds
                    if case .pillar = tiles[i][j].type {
                        pillars.insert(TileCoord(i,j))
                    } else {
                        queue.append(TileCoord(i,j))
                        tileCoordSet.insert(TileCoord(i,j))
                    }
                }
            }
        }
    }
    return (queue, Array(pillars))
}
