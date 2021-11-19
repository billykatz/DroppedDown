//
//  BossController.swift
//  DownFall
//
//  Created by Billy on 11/16/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum BossAttackType: String, Codable {
    case dynamite
    case poison
    case spawnSpider
}

enum BossStateType: String, Codable {
    case targetEat
    case eats
    case targetAttack
    case attack
    case rests
}

struct BossTargets: Codable, Hashable {
    var whatToEat: [TileCoord]?
    var eats: [TileCoord]?
    var whatToAttack: [BossAttackType: [TileCoord]]?
    var attack: [BossAttackType: [TileCoord]]?
}

struct BossState: Codable, Hashable {
    let stateType: BossStateType
    let turnsLeftInState: Int
    var targets: BossTargets
    
    public var poisonAttackColumns: [Int]? {
        let thingsToAttack = targets.whatToAttack ?? targets.attack ?? nil
        guard let attacks = thingsToAttack, let poisonTargets = attacks[.poison] else { return nil }
        
        var poisonColumns = Set<Int>()
        for target in poisonTargets {
            poisonColumns.insert(target.column)
        }
        return Array(poisonColumns)
        
    }
    
    func advance(tiles: [[Tile]], turnsInState: Int, nummberOfRocksToEat: Int) -> BossState {
        if turnsLeftInState <= 0 {
            let nextStateType = nextStateType()
            var nextBossState = BossState(
                stateType: nextStateType,
                turnsLeftInState: turnsInState,
                targets: BossTargets()
            )
            nextBossState.enter(tiles: tiles, oldState: self, numberOfRocksToEat: nummberOfRocksToEat)
            return nextBossState
        } else {
            return BossState(
                stateType: self.stateType,
                turnsLeftInState: self.turnsLeftInState - 1,
                targets: targets
            )
        }
    }
    
    
    // This function is called when we enter a new boss state
    // It is primarily responsible for initializing the BossTargets
    mutating func enter(tiles: [[Tile]], oldState: BossState, numberOfRocksToEat: Int) {
        switch self.stateType {
        case .targetEat:
            self.targets = BossTargets(whatToEat: targetsToEat(in: tiles, numberOfRocksToEat: numberOfRocksToEat), eats: nil)
        case .eats:
            let eatenRockCoords = eats(in: tiles)
            let whatToAttack = attack(basedOnRocks: eatenRockCoords, in: tiles)
            self.targets =
                BossTargets(whatToEat: nil,
                            eats: eatenRockCoords,
                            whatToAttack: targetsToAttack(in: tiles, with: whatToAttack)
                )
        case .targetAttack:
            self.targets = BossTargets(
                whatToEat: nil,
                eats: nil,
                whatToAttack: oldState.targets.whatToAttack
            )
        case .attack:
            self.targets = BossTargets(
                whatToEat: nil,
                eats: nil,
                whatToAttack: nil,
                attack: validateAndUpdatePlannedAttacks(in: tiles, plannedAttacks: oldState.targets.whatToAttack)
            )
        case .rests:
            break
        }
    }
    
    func nextStateType() -> BossStateType {
        switch self.stateType {
        case .targetEat:
            return .eats
        case .eats:
            if (targets.eats ?? []).isEmpty {
                return .rests
            } else {
                return .targetAttack
            }
        case .targetAttack:
            return .attack
        case .attack:
            return .rests
        case .rests:
            return .targetEat
        }
    }
    
    private func targetsToEat(in tiles: [[Tile]], numberOfRocksToEat: Int) -> [TileCoord] {
        return targetRocksToEat(in: tiles, numberRocksToEat: numberOfRocksToEat)
    }
    
    private func targetsToAttack(in tiles: [[Tile]], with attacks: [BossAttackType]?) -> [BossAttackType: [TileCoord]] {
        guard let attacks = attacks else { return [:] }
        return attacked(tiles: tiles, by: attacks)
        
    }
    
    
    
    
}

enum BossPhaseType: String, Codable {
    case first
    case second
    case third
    case dead
}

struct BossPhase: Codable, Hashable {
    private(set) var bossState: BossState
    public let bossPhaseType: BossPhaseType
    
    public init() {
        let initialState = BossState(stateType: .rests, turnsLeftInState: turnsInState(.rests), targets: BossTargets())
        self.init(bossState: initialState, bossPhaseType: .first)
    }
    
    private init(bossState: BossState, bossPhaseType: BossPhaseType) {
        self.bossState = bossState
        self.bossPhaseType = bossPhaseType
    }
    
    
    mutating func advance(tiles: [[Tile]]) -> (BossPhase, Bool) {
        let oldBossState = bossState
        let nextStateTurns = turnsInState(bossState.nextStateType())
        
        // this sets the next state's number of turns.  If the state doesnt advnace then it is ignored
        let nextBossState = bossState.advance(tiles: tiles, turnsInState: nextStateTurns, nummberOfRocksToEat: rocksToEat)
        let sendInput = nextBossState.stateType != oldBossState.stateType
        
        // next boss phase might happen
        let nextBossPhase = nextPhase(tiles: tiles)
        
        return (BossPhase(bossState: nextBossState, bossPhaseType: nextBossPhase), sendInput)
    }
    
    var rocksToEat: Int {
        switch bossPhaseType {
        case .first: return 3
        case .second: return 4
        case .third: return 6
        case .dead: return 0
        }
    }
    
    func nextPhase(tiles: [[Tile]]) -> BossPhaseType {
        switch bossPhaseType {
        case .first:
            let healthLeft = pillarHealthCount(for: tiles)
            if healthLeft <= 18 {
                return .second
            } else {
                return .first
            }
        case .second:
            let healthLeft = pillarHealthCount(for: tiles)
            if healthLeft <= 9 {
                return .third
            } else {
                return .second
            }
        case .third:
            let healthLeft = pillarHealthCount(for: tiles)
            if healthLeft <= 0 {
                return .dead
            } else {
                return .third
            }
        case .dead:
            return .dead
        }
    }
}

class BossController {
    
    let level: Level
    
    var phase: BossPhase
    var tiles: [[Tile]]?
    
    
    var isBossLevel: Bool {
        // 9 is actually "10"
        return level.depth == bossLevelDepthNumber
    }
    
    init(level: Level) {
        
        self.phase = level.savedBossPhase ?? BossPhase()
        self.level = level
        // only listen for inputs if this is the boss level
        guard isBossLevel else { return }
        
        Dispatch.shared.register { [weak self] input in
            self?.handleInput(input)
        }
    }
    
    func handleInput(_ input: Input) {
        switch input.type {
        case .newTurn:
            tiles = input.endTilesStruct ?? []
            
            advanceBossState()
        case .boardBuilt, .boardLoaded:
            tiles = input.endTilesStruct ?? []
        default:
            // ignore for now
            break
        }
    }
    
    func advanceBossState() {
        guard let tiles = tiles else { return }
        let (newPhase, shouldSendInput) = phase.advance(tiles: tiles)
        self.phase = newPhase
        if (shouldSendInput) {
            InputQueue.append(Input(.bossTurnStart(newPhase)))
        }
    }
    
    public func saveState() -> BossPhase {
        return phase
    }
}


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

private func unedibleTiles(in tiles: [[Tile]]) -> Set<TileCoord> {
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

private func randomCoord(in tiles: [[Tile]]?, notIn set: Set<TileCoord>) -> TileCoord {
    guard let boardSize = tiles?.count else { preconditionFailure("We need a board size to continue") }
    let upperbound = boardSize
    
    var tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
    while set.contains(tileCoord) {
        tileCoord = TileCoord(row: Int.random(upperbound), column: Int.random(upperbound))
    }
    return tileCoord
}

private func attack(basedOnRocks rocksEaten: [TileCoord]?, in tiles: [[Tile]]) -> [BossAttackType]? {
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

private func eats(in tiles: [[Tile]]) -> [TileCoord]? {
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

/// Returns all "attackable" tiles when the boss wants to throw dyamite or spawn a minion
private func nonAttackableCoords(tiles: [[Tile]]) -> Set<TileCoord> {
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
private func attacked(tiles: [[Tile]], by attacks: [BossAttackType]) -> [BossAttackType: [TileCoord]] {
    
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

private func validateAndUpdatePlannedAttacks(in tiles: [[Tile]], plannedAttacks: [BossAttackType: [TileCoord]]?) ->  [BossAttackType: [TileCoord]]? {
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
private func newTarget(in tiles: [[Tile]], nearby: TileCoord, nonAttackableCoords: Set<TileCoord>) -> TileCoord? {
    var orthogonal = Array(nearby.orthogonalNeighbors).shuffled()
    let diagonal = Array(nearby.diagonalNeighbors).shuffled()
    orthogonal.append(contentsOf: diagonal)
    var newTarget: TileCoord?
    for neighbor in orthogonal {
        guard isWithinBounds(neighbor, within: tiles) else { continue }
        if !nonAttackableCoords.contains(neighbor) {
            newTarget = neighbor
        }
    }
    return newTarget
}

private func turnsInState(_ state: BossStateType) -> Int {
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
    }
}


private func pillarHealthCount(for tiles: [[Tile]]) -> Int {
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
