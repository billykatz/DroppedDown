//
//  BossController.swift
//  DownFall
//
//  Created by Billy on 11/16/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

enum BossStateType: String, Codable {
    case targetEat
    case eats
    case rests
}

struct BossTargets: Codable, Hashable {
    var targetsToEat: [TileCoord]?
    var eats: [TileCoord]?
}

struct BossState: Codable, Hashable {
    let bossStateType: BossStateType
    let turnsLeftInState: Int
    
    var targets: BossTargets
    
    func advance(tiles: [[Tile]], turnsInState: Int) -> BossState {
        if turnsLeftInState <= 0 {
            let nextStateType = nextStateType()
            return BossState(
                bossStateType: nextStateType,
                turnsLeftInState: turnsInState,
                targets: BossTargets()
            )
        } else {
            return BossState(
                bossStateType: self.bossStateType,
                turnsLeftInState: self.turnsLeftInState - 1,
                targets: targets
            )
        }
    }
    
    mutating func enter(tiles: [[Tile]]) {
        switch self.bossStateType {
        case .eats:
            self.targets = BossTargets(targetsToEat: nil, eats: eats(in: tiles))
        case .targetEat:
            self.targets = BossTargets(targetsToEat: targetsToEat(in: tiles), eats: nil)
        case .rests:
            break
        }
    }
    
    private func nextStateType() -> BossStateType {
        switch self.bossStateType {
        case .targetEat:
            return .eats
        case .eats:
            return .rests
        case .rests:
            return .targetEat
        }
    }
    
    private func targetsToEat(in tiles: [[Tile]]) -> [TileCoord] {
        return targetRocksToEat(in: tiles, numberRocksToEat: 2)
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
        if nextBossState.bossStateType != oldBossState.bossStateType {
            // there has been a change so update the bossState
            nextBossState.enter(tiles: tiles)
            sendInput = nextBossState.bossStateType != .rests
        }
        
        return (BossPhase(bossState: nextBossState, bossPhaseType: self.bossPhaseType), sendInput)
    }
    
    private func turnsInState() -> Int {
        switch bossState.bossStateType {
        case .targetEat:
            return 2
        case .eats:
            return 0
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
        let bossState = BossState(bossStateType: .rests, turnsLeftInState: 2, targets: BossTargets())
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
