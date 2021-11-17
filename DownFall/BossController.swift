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
    var whatToAttack: [TileCoord]?
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
    
    
    mutating func enter(tiles: [[Tile]]) {
        switch self.stateType {
        case .targetEat:
            self.targets = BossTargets(whatToEat: targetsToEat(in: tiles), eats: nil)
        case .eats:
            self.targets = BossTargets(whatToEat: nil, eats: eats(in: tiles))
        case .targetAttack:
            self.targets = BossTargets(
                whatToEat: nil,
                eats: nil,
                whatToAttack: targetsToAttack(in: tiles, with: self.attackType)
            )
        case .rests:
            break
        }
    }
    
    private func nextStateType() -> BossStateType {
        switch self.stateType {
        case .targetEat:
            return .eats
        case .eats:
            return .targetAttack
        case .targetAttack:
            return .rests
        case .rests:
            return .targetEat
        }
    }
    
    private func targetsToEat(in tiles: [[Tile]]) -> [TileCoord] {
        return targetRocksToEat(in: tiles, numberRocksToEat: 2)
    }
    
    private func targetsToAttack(in tiles: [[Tile]], with attacks: [BossAttackType]?) -> [TileCoord] {
        guard let attacks = attacks else { return [] }
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
        var nextBossState = bossState.advance(tiles: tiles, turnsInState: turnsInState())
        var sendInput = false
        if nextBossState.stateType != oldBossState.stateType {
            // there has been a change so update the bossState
            nextBossState.enter(tiles: tiles)
            sendInput = nextBossState.stateType != .rests
        }
        
        return (BossPhase(bossState: nextBossState, bossPhaseType: self.bossPhaseType), sendInput)
    }
    
    private func turnsInState() -> Int {
        switch bossState.stateType {
        case .targetEat:
            return 2
        case .eats:
            return 0
        case .targetAttack:
            return 1
        case .rests:
            return 2
        }
    }
}

class BossController {
    
    let level: Level
    
    // Debug so we can test easily
    let bossLevelNumber = 0
    
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
        guard level.depth == bossLevelNumber else { return }
        
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


func attacked(tiles: [[Tile]], by attacks: [BossAttackType]) -> [TileCoord] {
         //TODO: can be optimized
//         var columnsAttacked = Set<Int>()
//         var rowsAttacked = Set<Int>()
//         var monstersSpawned = Set<TileCoord>()
         var bombsSpawned = Set<TileCoord>()
         for attack in attacks {
             switch attack {
             case .dynamite:
                bombsSpawned.insert(randomCoord(in: tiles, notIn: bombsSpawned))
//             case .column:
//                 columnsAttacked.insert(Int.random(tiles.count, notInSet: columnsAttacked))
//             case .row:
//                 rowsAttacked.insert(Int.random(tiles.count, notInSet: rowsAttacked))
//             case .spawn:
//                 monstersSpawned.insert(randomCoord(notIn: monstersSpawned))
             }
         }

//         var columnCoords = Set<TileCoord>()
//         var rowCoords = Set<TileCoord>()
//         for row in 0..<tiles.count {
//             for col in 0..<tiles.count {
//                 if columnsAttacked.contains(col) {
//                     columnCoords.insert(TileCoord(row, col))
//                 }
//                 if rowsAttacked.contains(row) {
//                     rowCoords.insert(TileCoord(row, col))
//                 }
//             }
//         }
    
        return  Array(bombsSpawned)

//         var result: [BossAttackType: Set<TileCoord>] = [:]
////         if !columnCoords.isEmpty {
////             result[.column] = columnCoords
////         }
////         if !rowCoords.isEmpty {
////             result[.row] = rowCoords
////         }
//         if !bombsSpawned.isEmpty {
//             result[.dynamite] = bombsSpawned
//         }
////         if !monstersSpawned.isEmpty {
////             result[.spawn] = monstersSpawned
////         }
//         return result

     }
