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
}

enum BossStateType: String, Codable {
    case targetEat
    case eats
    case targetAttack
    case rests
}

struct BossTargets: Codable, Hashable {
    var whatToEat: [TileCoord]?
    var eats: [TileCoord]?
    var whatToAttack: [BossAttackType: [TileCoord]]?
}

struct BossState: Codable, Hashable {
    let stateType: BossStateType
    let turnsLeftInState: Int
    var targets: BossTargets
    var attackType: [BossAttackType]?
    
    func advance(tiles: [[Tile]], turnsInState: Int) -> BossState {
        if turnsLeftInState <= 0 {
            let nextStateType = nextStateType()
            let eatenRockCoords = self.targets.eats
            return BossState(
                stateType: nextStateType,
                turnsLeftInState: turnsInState,
                targets: BossTargets(),
                attackType: attack(basedOnRocks: eatenRockCoords, in: tiles)
            )
        } else {
            return BossState(
                stateType: self.stateType,
                turnsLeftInState: self.turnsLeftInState - 1,
                targets: targets,
                attackType: attackType
            )
        }
    }
    
    
    mutating func enter(tiles: [[Tile]], oldState: BossState) {
        switch self.stateType {
        case .targetEat:
            self.targets = BossTargets(whatToEat: targetsToEat(in: tiles), eats: nil)
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
            return .rests
        case .rests:
            return .targetEat
        }
    }
    
    private func targetsToEat(in tiles: [[Tile]]) -> [TileCoord] {
        return targetRocksToEat(in: tiles, numberRocksToEat: 2)
    }
    
    private func targetsToAttack(in tiles: [[Tile]], with attacks: [BossAttackType]?) -> [BossAttackType: [TileCoord]] {
        guard let attacks = attacks else { return [:] }
        return attacked(tiles: tiles, by: attacks)
        
    }
    
    
}

enum BossPhaseType: String, Codable {
    case first
}

struct BossPhase: Codable, Hashable {
    var bossState: BossState
    let bossPhaseType: BossPhaseType
    
    mutating func advance(tiles: [[Tile]]) -> (BossPhase, Bool) {
        let oldBossState = bossState
        let nextStateTurns = turnsInState(bossState.nextStateType())
        
        // this sets the next state's number of turns.  If the state doesnt advnace then it is ignored
        var nextBossState = bossState.advance(tiles: tiles, turnsInState: nextStateTurns)
        var sendInput = false
        if nextBossState.stateType != oldBossState.stateType {
            // there has been a change so update the bossState
            nextBossState.enter(tiles: tiles, oldState: oldBossState)
            sendInput = true
        }
        
        return (BossPhase(bossState: nextBossState, bossPhaseType: self.bossPhaseType), sendInput)
    }
    
    private func turnsInState(_ state: BossStateType) -> Int {
        switch state {
        case .targetEat:
            return 2
        case .eats:
            return 1
        case .targetAttack:
            return 0
        case .rests:
            return 2
        }
    }
}

class BossController {
    
    let level: Level
    
    // Debug so we can test easily
    let bossLevelNumber = 9
    
    var phase: BossPhase
    var tiles: [[Tile]]?
    
    
    var isBossLevel: Bool {
        // 9 is actually "10"
        return level.depth == bossLevelNumber
    }
    
    init(level: Level) {
        let bossState = BossState(stateType: .rests, turnsLeftInState: 2, targets: BossTargets())
        self.phase = BossPhase(bossState: bossState, bossPhaseType: .first)
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
}


// MARK: - Boss helpers


// It's definitely possible, if not improbable, that the number of rocks to eat is less than the n umber of rocks on the board.  We could run into an infinite loop when calling this function.  Food for thought
func targetRocksToEat(in tiles: [[Tile]], numberRocksToEat: Int) -> [TileCoord] {
    var targets: [TileCoord] = []
    var notTargetable = notTargetableTiles(in: tiles)
    for _ in 0..<numberRocksToEat {
        
        let newTarget = randomCoord(in: tiles, notIn: notTargetable)
        // do not target this tile in the next loop
        notTargetable.insert(newTarget)
        
        // add this target to the running list of targets
        targets.append(newTarget)
    }
    return targets
}

private func notTargetableTiles(in tiles: [[Tile]]) -> Set<TileCoord> {
    var set = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            switch tiles[row][col].type {
            case .rock(color: _, holdsGem: false, groupCount: _):
                // target all rocks except for ones that are holding a gem
                ()
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


func attacked(tiles: [[Tile]], by attacks: [BossAttackType]) -> [BossAttackType: [TileCoord]] {
    //TODO: can be optimized
    var columnsAttacked = Set<Int>()
    //         var rowsAttacked = Set<Int>()
    //         var monstersSpawned = Set<TileCoord>()
    var bombsSpawned = Set<TileCoord>()
    for attack in attacks {
        switch attack {
        case .dynamite:
            bombsSpawned.insert(randomCoord(in: tiles, notIn: bombsSpawned))
        case .poison:
            columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
            columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
        //             case .row:
        //                 rowsAttacked.insert(Int.random(tiles.count, notInSet: rowsAttacked))
        //             case .spawn:
        //                 monstersSpawned.insert(randomCoord(notIn: monstersSpawned))
        }
    }
    
    var columnCoords: [TileCoord] = []
    //         var rowCoords = Set<TileCoord>()
    for row in 0..<tiles.count {
        for col in 0..<tiles.count {
            if columnsAttacked.contains(col) {
                columnCoords.append(TileCoord(row, col))
            }
            //                 if rowsAttacked.contains(row) {
            //                     rowCoords.insert(TileCoord(row, col))
            //                 }
        }
    }
    
    //        return  Array(bombsSpawned)
    
    var result: [BossAttackType: [TileCoord]] = [:]
    if !columnCoords.isEmpty {
        result[.poison] = columnCoords
    }
    //         if !rowCoords.isEmpty {
    //             result[.row] = rowCoords
    //         }
    if !bombsSpawned.isEmpty {
        result[.dynamite] = Array(bombsSpawned)
    }
    //         if !monstersSpawned.isEmpty {
    //             result[.spawn] = monstersSpawned
    //         }
    return result
    
}
