//
//  BossHelpers.swift
//  DownFall
//
//  Created by Billy on 11/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit


// MARK: - Boss helpers


// It's definitely possible, if not improbable, that the number of rocks to eat is less than the n umber of rocks on the board.  We could run into an infinite loop when calling this function.  Food for thought
func targetRocksToEat(in tiles: [[Tile]], numberRocksToEat: Int) -> [TileCoord] {
    var targets: [TileCoord] = []
    var notTargetable = unedibleTiles(in: tiles)
    for _ in 0..<numberRocksToEat {
        
        let newTarget = randomCoord(in: tiles, notIn: notTargetable)
        // do not target this tile in the next loop
        notTargetable.insert(newTarget)
        
        // add this target to the running list of targets
        targets.append(newTarget)
    }
    return targets
}

func unedibleTiles(in tiles: [[Tile]]) -> Set<TileCoord> {
    var set = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            switch tiles[row][col].type {
            case .rock(color: _, holdsGem: false, groupCount: _):
                // target all rocks except for ones that are holding a gem
                break
            default:
                set.insert(TileCoord(row: row, column: col))
            }
        }
    }
    return set
}

func randomCoord(in tiles: [[Tile]]?, notIn set: Set<TileCoord>) -> TileCoord {
    guard let boardSize = tiles?.count else { preconditionFailure("We need a board size to continue") }
    let upperbound = boardSize
    
    var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
    while set.contains(tileCoord) {
        tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
    }
    return tileCoord
}

func attack(basedOnRocks rocksEaten: [TileCoord]?, in tiles: [[Tile]]) -> [BossAttackType]? {
    guard let rocksEaten = rocksEaten else { return nil }
    var tileTypes: [TileType] = []
    for row in 0..<tiles.count {
        for col in 0..<tiles[row].count {
            if (rocksEaten.contains(TileCoord(row, col))) {
                tileTypes.append(tiles[row][col].type)
            }
        }
    }
    
    return tileTypes.map {
        switch $0.color {
        case .red:
            return .dynamite
        case .blue:
            return .poison
        case .purple:
            return .spawnSpider
        default:
            return .dynamite
        }
    }
}

func eats(in tiles: [[Tile]]) -> [TileCoord]? {
    var tilesToEat: [TileCoord] = []
    for row in 0..<tiles.count {
        for col in 0..<tiles[row].count {
            if tiles[row][col].bossTargetedToEat ?? false {
                tilesToEat.append(TileCoord(row, col))
            }
        }
    }
    if tilesToEat.isEmpty { return nil }
    return tilesToEat
}

/// Returns all "growable" tiles when the boss wants to create a pillar
func nonGrowableCoords(tiles: [[Tile]]) -> Set<TileCoord> {
    var reservedCoords = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            let coord = TileCoord(row, col)
            switch tiles[row][col].type {
            case .monster, .player, .pillar, .dynamite, .gem:
                reservedCoords.insert(coord)
            default:
                break
            }
        }
    }
    return reservedCoords
}

/// Returns all "attackable" tiles when the boss wants to throw dyamite or spawn a minion
func nonAttackableCoords(tiles: [[Tile]]) -> Set<TileCoord> {
    var reservedCoords = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            let coord = TileCoord(row, col)
            switch tiles[row][col].type {
            case .monster, .player, .pillar:
                reservedCoords.insert(coord)
            default:
                break
            }
        }
    }
    return reservedCoords
}

/// Returns a dictionary with BossAttackTypes as keys with an array of attack targets as the value.
func attacked(tiles: [[Tile]], by attacks: [BossAttackType]) -> [BossAttackType: [TileCoord]] {
    
    let untargetable: Set<TileCoord> = nonAttackableCoords(tiles: tiles)
    
    var columnsAttacked = Set<Int>()
    var monstersSpawned = Set<TileCoord>()
    var bombsSpawned = Set<TileCoord>()
    for attack in attacks {
        switch attack {
        case .dynamite:
            let nonTargetable = bombsSpawned.union(monstersSpawned).union(untargetable)
            bombsSpawned.insert(randomCoord(in: tiles, notIn: nonTargetable))
        case .poison:
            // each posion attack spawns two attacked columns, that's why we did this twice
            columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
            columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
        case .spawnSpider:
            let nonTargetable = bombsSpawned.union(monstersSpawned).union(untargetable)
            monstersSpawned.insert(randomCoord(in: tiles, notIn: nonTargetable))
        }
    }
    
    
    var columnCoords: [TileCoord] = []
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            if columnsAttacked.contains(col) {
                columnCoords.append(TileCoord(row, col))
            }
        }
    }
    
    
    var result: [BossAttackType: [TileCoord]] = [:]
    if !columnCoords.isEmpty {
        result[.poison] = columnCoords
    }
    if !bombsSpawned.isEmpty {
        result[.dynamite] = Array(bombsSpawned)
    }
    if !monstersSpawned.isEmpty {
        result[.spawnSpider] = Array(monstersSpawned)
    }
    return result
    
}

func validateAndUpdatePlannedAttacks(in tiles: [[Tile]], plannedAttacks: [BossAttackType: [TileCoord]]?) ->  [BossAttackType: [TileCoord]]? {
    guard let plannedAttacks = plannedAttacks else { return nil }
    var updatedAttacks = plannedAttacks
    var nonAttackable = nonAttackableCoords(tiles: tiles)
    for (plannedAttack, plannedCoords) in plannedAttacks {
        switch plannedAttack {
        case .poison:
            // poison will never target something illegally following the players turn
            break
        case .dynamite, .spawnSpider:
            // dyamite should only ever target a rock
            var newCoords: [TileCoord] = []
            for coord in plannedCoords {
                if nonAttackable.contains(coord) {
                    // we should choose a different coord close by
                    if let newCoord = newTarget(in: tiles, nearby: coord, nonAttackableCoords: nonAttackable) {
                        newCoords.append(newCoord)
                        nonAttackable.insert(newCoord)
                    } else {
                        // then no other legal targets were located 1 tile away from the original target.  Kudos to the player, they succesfully fizzled an attack
                    }
                } else {
                    newCoords.append(coord)
                }
            }
            
            // update the planned attack to point to new coords
            updatedAttacks[plannedAttack] = newCoords
        }
    }
    
    return updatedAttacks
}

/// Searches the tile's neighbors for a suitable
/// It tries ortho neighbors first then it tries diagonal neighbors
func newTarget(in tiles: [[Tile]], nearby: TileCoord, nonAttackableCoords: Set<TileCoord>) -> TileCoord? {
    var orthogonal = Array(nearby.orthogonalNeighbors).shuffled()
    let diagonal = Array(nearby.diagonalNeighbors).shuffled()
    orthogonal.append(contentsOf: diagonal)
    for neighbor in orthogonal {
        guard isWithinBounds(neighbor, within: tiles) else { continue }
        if !nonAttackableCoords.contains(neighbor) {
            return neighbor
        }
    }
    return nil
}

func turnsInState(_ state: BossStateType) -> Int {
    switch state {
    case .targetEat:
        return 1
    case .eats:
        return 0
    case .targetAttack:
        return 0
    case .attack:
        return 0
    case .rests:
        return 1
    case .phaseChange, .superAttack, .targetSuperAttack:
        return 0
    }
}


func pillarHealthCount(for tiles: [[Tile]]) -> Int {
    var pillarHealth = 0
    for (i, _) in tiles.enumerated() {
        for (j, _) in tiles[i].enumerated() {
            if case let TileType.pillar(pillarData) = tiles[i][j].type {
                pillarHealth += pillarData.health
            }
        }
    }
    return pillarHealth
}

let superAttackChargeNumber = 8

func superAttackIsCharged(eatenRocks: Int) -> Bool {
     return eatenRocks >= 8
}
