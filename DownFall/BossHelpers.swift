//
//  BossHelpers.swift
//  DownFall
//
//  Created by Billy on 11/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit


// MARK: - Boss helpers


// It's definitely possible, if not improbable, that the number of rocks to eat is less than the number of rocks on the board.  We could run into an infinite loop when calling this function.  Food for thought
func targetRocksToEat(in tiles: [[Tile]], numberRocksToEat: Int) -> [TileCoord] {
    var targets: [TileCoord] = []
    var notTargetable = unedibleTiles(in: tiles)
    let edibleRockColors: [ShiftShaft_Color] = [.red, .blue, .purple]
    var eatenColors: [ShiftShaft_Color] = []
    var numberOfRocksEaten = 0
    while numberOfRocksEaten < numberRocksToEat {
        
        let newTarget = randomCoord(in: tiles, notIn: notTargetable)
        
        if case TileType.rock(color: let color, _, _) = tiles[newTarget].type {
            // reset array of rocks the boss can eat
            if eatenColors.count == edibleRockColors.count { eatenColors = [] }
            
            // make sure we only eat red, purple and brown rocks
            guard edibleRockColors.contains(color) else { continue }
            
            // eat the rock if we havent eaten this type of rock already
            if !eatenColors.contains(color) {
                eatenColors.append(color)
                // do not target this tile in the next loop
                notTargetable.insert(newTarget)
                
                // add this target to the running list of targets
                targets.append(newTarget)
                
                numberOfRocksEaten += 1
            }
        }
        
    }
    return targets
}

func unedibleTiles(in tiles: [[Tile]]) -> Set<TileCoord> {
    var set = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            switch tiles[row][col].type {
            case .rock(color: let color, holdsGem: false, groupCount: _):
                
                // dont eat brown or green rocks
                if color == .brown || color == .green {
                    set.insert(TileCoord(row: row, column: col))
                }
                
                // target all rocks except for ones that are holding a gem
                else {
                    break
                }
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

func randomCoordNearPlayerOrRotated(in tiles: [[Tile]], notIn: Set<TileCoord>) -> TileCoord {
    guard let pp = getTilePosition(.player(.zero), tiles: tiles) else { return .zero }
    let rotatePp2 = pp.rotated(times: 1, boardSize: tiles.count)
    let rotatePp3 = pp.rotated(times: 2, boardSize: tiles.count)
    let rotatePp4 = pp.rotated(times: 3, boardSize: tiles.count)
    
    var rotatePositions = [pp, rotatePp2, rotatePp4, rotatePp3]
    var newCoord = pp
    
    while (notIn.contains(newCoord)) {
        if rotatePositions.isEmpty,
           let randomPosition = [pp, rotatePp2, rotatePp4, rotatePp3].randomElement()
        {
            newCoord = randomCoord(in: tiles, notIn: notIn, nearby: randomPosition, in: 0...1)
        } else {
            rotatePositions = Array(rotatePositions.dropFirst())
            if let next = rotatePositions.first {
                newCoord = next
            }
        }
    }
    return newCoord
}

// attamptes to find a random coord with the closed range of the target.
// if it fails after 30 attempts it increase the range and tries again.
func randomCoord(in tiles: [[Tile]]?, notIn set: Set<TileCoord>, nearby target: TileCoord, in range: ClosedRange<CGFloat>, specificTypeChecker: ((TileType) -> Bool)? = nil ) -> TileCoord {
    guard let tiles = tiles  else { preconditionFailure("We need tiles to continue") }
    let boardSize = tiles.count
    let upperbound = boardSize
    
    var newRange = range
    
    
    var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
    var maxTries = 30
    
    // defaults to true
    // if the types dont match, then we should continue choosing new tileCoords/
    // when they DO match, then we can stop
    var specificTypeCheck = specificTypeChecker?(tiles[tileCoord].type) ?? true

    
    // when the chosen coord is NOT in the reserved set
    // and
    // when the range DOES contain the distance from coord to target coord
    // and
    // when the specific type check evaluates to true (or defaults to true)
    // ----
    // THEN STOP THE LOOP. We are done and have a tile coord
    while !(!set.contains(tileCoord) && newRange.contains(tileCoord.distance(to: target)) && specificTypeCheck)  {
        tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
        specificTypeCheck = specificTypeChecker?(tiles[tileCoord].type) ?? true
        maxTries -= 1
        
        // we might need to try a slight wider range after trying for "too long"
        if maxTries <= 0 {
            maxTries = 30
            newRange = newRange.lowerBound-1...newRange.upperBound+1
        }
    }
    return tileCoord
}

// seems legit
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
    
    var shuffledMonsters = EntityModel.EntityType.monstersCases.shuffled()
    
    return tileTypes.map {
        switch $0.color {
        case .red:
            return .dynamite
        case .blue:
            return .poison
        case .purple:
            // TODO: Make it so that we choose a random monster based on other monsters we have chosen and the boss phase
            if shuffledMonsters.isEmpty {
                shuffledMonsters = EntityModel.EntityType.monstersCases.shuffled()
            }
            let (newArray, randomMonster) = shuffledMonsters.dropRandom()
            shuffledMonsters = newArray
            return .spawnMonster(withType: randomMonster!)
            
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

/// Returns all "targetable" tiles when the boss wants to throw dyamite or spawn a minion
func nonTargetableCoords(tiles: [[Tile]]) -> Set<TileCoord> {
    var reservedCoords = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            let coord = TileCoord(row, col)
            switch tiles[row][col].type {
            case .rock(color: let color, _, _):
                if color == .brown || color == .green {
                    reservedCoords.insert(coord)
                } else {
                    // purposefully left blank
                }
            case .monster, .pillar, .offer, .item, .dynamite:
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
            case .rock(color: let color, _, _):
                if color == .brown || color == .green {
                    reservedCoords.insert(coord)
                } else {
                    // purposefully left blank
                }
            case .monster, .player, .pillar, .offer, .item, .dynamite:
                reservedCoords.insert(coord)
            default:
                break
            }
        }
    }
    return reservedCoords
}

struct MonsterSpawned: Hashable {
    let monsterType: EntityModel.EntityType
    let coord: TileCoord
}

enum PoisonAttackType: String, Codable,  Hashable {
    case columnDown
    case rowLeftToRight
    
    static var random: PoisonAttackType {
        return [columnDown, rowLeftToRight].randomElement()!
    }
}

struct PoisonAttack: Codable, Hashable {
    let index: Int
    let attackType: PoisonAttackType
}

func numberOfAttacksTargetingPlayer(playerPosition: TileCoord, newPoisonAttacks: Set<PoisonAttack>) -> Int {
    var targetsPlayer = 0
    for attack in newPoisonAttacks {
        if attack.index == playerPosition.row || attack.index == playerPosition.col {
            targetsPlayer += 1
        }
    }
    return targetsPlayer
}


/// Returns a dictionary with BossAttackTypes as keys with an array of attack targets as the value.
func attacked(tiles: [[Tile]], by attacks: [BossAttackType]) -> [BossAttack: [TileCoord]] {
    
    let playerPosition = getTilePosition(.player(.zero), tiles: tiles) ?? .zero
    let untargetable: Set<TileCoord> = nonTargetableCoords(tiles: tiles)
    
    var posionAttacks = Set<PoisonAttack>()
    var monstersSpawned = Set<MonsterSpawned>()
    var bombsSpawned = Set<TileCoord>()
    

    for attack in attacks {
        let monstersSpawnedCoord = monstersSpawned.map { $0.coord }
        switch attack {
        case .dynamite:
            let nonTargetable = bombsSpawned.union(monstersSpawnedCoord).union(untargetable)
            let targetedTile = randomCoordNearPlayerOrRotated(in: tiles, notIn: nonTargetable)
            bombsSpawned.insert(targetedTile)
        case .poison:
            // each posion attack spawns two attacked columns, that's why we did this twice
            var newPoisonAttacks = Set<PoisonAttack>()
            var maxTries = 100
            while newPoisonAttacks.count < 3 && maxTries > 0 {
                if numberOfAttacksTargetingPlayer(playerPosition: playerPosition, newPoisonAttacks: posionAttacks.union(newPoisonAttacks)) < 2 {
                    // create an + patter on the player
                    let rowIdx = playerPosition.row
                    let rowDirection: PoisonAttackType =  .rowLeftToRight
                    let rowAttack: PoisonAttack = PoisonAttack(index: rowIdx, attackType: rowDirection)
                    let colIdx = playerPosition.col
                    let colDirection: PoisonAttackType = .columnDown
                    let colAttack: PoisonAttack = PoisonAttack(index: colIdx, attackType: colDirection)
                    newPoisonAttacks.insert(rowAttack)
                    newPoisonAttacks.insert(colAttack)
                    
                } else {
                    // choose random ones
                    let index = Int.random(tiles.count)
                    let direction = PoisonAttackType.random
                    
                    let attack = PoisonAttack(index: index, attackType: direction)
                    if !newPoisonAttacks.contains(attack) && !posionAttacks.contains(attack) {
                        newPoisonAttacks.insert(attack)
                    }
                }
                
                maxTries -= 1
            }
            
            posionAttacks = posionAttacks.union(newPoisonAttacks)
            
        case .spawnMonster(withType: let monsterType):
            let nonTargetable = bombsSpawned.union(monstersSpawnedCoord).union(untargetable)
            let randomCoord = randomCoord(in: tiles, notIn: nonTargetable)
            let monsterSpawned = MonsterSpawned(monsterType: monsterType, coord: randomCoord)
            monstersSpawned.insert(monsterSpawned)
        }
    }
    
    
    var poisonAttackCoords: [TileCoord] = []
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            for attack in posionAttacks {
                if attack.attackType == .columnDown {
                    if attack.index == col {
                        poisonAttackCoords.append(TileCoord(row, col))
                    }
                } else {
                    if attack.index == row {
                        poisonAttackCoords.append(TileCoord(row, col))
                    }
                }
            }
        }
    }
    
    
    var result: [BossAttack: [TileCoord]] = [:]
    if !poisonAttackCoords.isEmpty {
        let attackType = BossAttack(type: .poison, poisonAttacks: Array(posionAttacks))
        result[attackType] = poisonAttackCoords
    }
    if !bombsSpawned.isEmpty {
        let attackType = BossAttack(type: .dynamite)
        result[attackType] = Array(bombsSpawned)
    }
    if !monstersSpawned.isEmpty {
        // TODO: Make it so that we choose a random monster based on other monsters we have chosen and the boss phase
        for monstersSpawn in Array(monstersSpawned) {
            let bossAttackType = BossAttackType.spawnMonster(withType: monstersSpawn.monsterType)
            let bossAttack = BossAttack(type: bossAttackType)
            if var entry = result[bossAttack] {
                entry.append(monstersSpawn.coord)
                result[bossAttack] = entry
            } else {
                result[bossAttack] = [monstersSpawn.coord]
            }
        }
    }
    return result
    
}

func validateAndUpdatePlannedAttacks(in tiles: [[Tile]], plannedAttacks: [BossAttack: [TileCoord]]?) ->  [BossAttack: [TileCoord]]? {
    guard let plannedAttacks = plannedAttacks, let _ = getTilePosition(.player(.zero), tiles: tiles) else { return nil }
    var updatedAttacks = plannedAttacks

    var nonAttackable = nonAttackableCoords(tiles: tiles)
    for (plannedAttack, plannedCoords) in plannedAttacks {
        switch plannedAttack.type {
        case .poison:
            break
            
        case .dynamite, .spawnMonster:
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
    case .intro:
        return 1
    case .targetEat:
        return 1
    case .eats:
        return 0
    case .targetAttack:
        return 0
    case .attack:
        return 0
    case .rests:
        return 8
    case .phaseChange:
        return 1
    case .superAttack, .targetSuperAttack:
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
