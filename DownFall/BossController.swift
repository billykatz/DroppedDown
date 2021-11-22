//
//  BossController.swift
//  DownFall
//
//  Created by Billy on 11/16/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct BossTileAttack: Codable, Hashable {
    let tileType: TileType
    let tileCoord: TileCoord
    
    init(_ tileType: TileType, _ coord: TileCoord) {
        self.tileType = tileType
        self.tileCoord = coord
    }
}

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
    case phaseChange
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
        case .rests, .phaseChange:
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
        case .rests, .phaseChange:
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
    
    var columnsToGrow: Int {
        switch self {
        case .first: return 0 // return 3
        case .second: return 3 // return 4
        case .third: return 5
        case .dead: return 0
        }

    }
    
    var rocksToEat: Int {
        switch self {
        case .first: return 5 // return 3
        case .second: return 5 // return 4
        case .third: return 6
        case .dead: return 0
        }
    }
}

struct BossPhaseTargets: Codable, Hashable {
    let createPillars: [BossTileAttack]?
}

struct BossPhase: Codable, Hashable {
    private(set) var bossState: BossState
    public let bossPhaseType: BossPhaseType
    private let numberOfIndividualColumns: Double
    var phaseChangeTagets: BossPhaseTargets
    
    public init(numberOfColumns: Int = 0) {
        let initialState = BossState(stateType: .rests, turnsLeftInState: turnsInState(.rests), targets: BossTargets())
        self.init(bossState: initialState, bossPhaseType: .first, numberColumns: numberOfColumns)
    }
    
    private init(bossState: BossState, bossPhaseType: BossPhaseType, numberColumns: Int, bossPhaseChangeTargets: BossPhaseTargets? = nil) {
        self.bossState = bossState
        self.bossPhaseType = bossPhaseType
        self.numberOfIndividualColumns = Double(numberColumns)
        self.phaseChangeTagets = bossPhaseChangeTargets ?? BossPhaseTargets(createPillars: nil)
    }
    
    
    mutating func advance(tiles: [[Tile]]) -> (BossPhase, Bool) {
        let oldBossState = bossState
        let nextStateTurns = turnsInState(bossState.nextStateType())
        
        // this sets the next state's number of turns.  If the state doesnt advnace then it is ignored
        let nextBossState = bossState.advance(tiles: tiles, turnsInState: nextStateTurns, nummberOfRocksToEat: bossPhaseType.rocksToEat)
        let sendInput = nextBossState.stateType != oldBossState.stateType
        
        // next boss phase might happen
        let nextBossPhaseType = nextPhase(tiles: tiles)
        var nextBossPhase = BossPhase(bossState: nextBossState, bossPhaseType: nextBossPhaseType, numberColumns: Int(numberOfIndividualColumns))
        
        // the phase is changing, let's do a special attack
        // this will overwrite any active boss attack, that's on purpose
        if nextBossPhaseType != self.bossPhaseType {
            
            // create a new boss state with the type .phaseChange
            let phaseChangeBossState = BossState(stateType: .phaseChange, turnsLeftInState: turnsInState(.phaseChange), targets: BossTargets())
            
            // lets calculate the phase change targets
            let nextPhaseChangeTagets = BossPhaseTargets(createPillars: calculatePhaseChangeTargets(nextPhase: nextBossPhaseType, tiles: tiles))
            
            // grab the extra number of columns
            let numberOfAdditionalColumns = (nextPhaseChangeTagets.createPillars?.count ?? 0) * 3
            
            // create the next boss phase that will be returned
            nextBossPhase = BossPhase(bossState: phaseChangeBossState, bossPhaseType: nextBossPhaseType, numberColumns: Int(numberOfIndividualColumns)+numberOfAdditionalColumns, bossPhaseChangeTargets: nextPhaseChangeTagets)
            
        }
        
        return (nextBossPhase, sendInput)
    }
    
    func calculatePhaseChangeTargets(nextPhase: BossPhaseType, tiles: [[Tile]]) -> [BossTileAttack] {
        var growColumnsCoord = Set<BossTileAttack>()
        
        let nonTargetable = nonGrowableCoords(tiles: tiles)
        while growColumnsCoord.count < nextPhase.columnsToGrow {
            let randomCoord = randomCoord(in: tiles, notIn: nonTargetable)
            growColumnsCoord.insert(BossTileAttack(TileType.pillar(.random), randomCoord))
        }
        
        return Array(growColumnsCoord)
        
    }
    
    func nextPhase(tiles: [[Tile]]) -> BossPhaseType {
        switch bossPhaseType {
        case .first:
            let healthLeft = pillarHealthCount(for: tiles)
            if Double(healthLeft) <= numberOfIndividualColumns*0.66 {
                return .second
            } else {
                return .first
            }
        case .second:
            let healthLeft = pillarHealthCount(for: tiles)
            if Double(healthLeft) <= numberOfIndividualColumns*0.40 {
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
        
        self.phase = level.savedBossPhase ?? BossPhase(numberOfColumns: level.numberOfIndividualColumns)
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
        let oldPhase = phase
        self.phase = newPhase
        if newPhase.bossPhaseType != oldPhase.bossPhaseType {
            InputQueue.append(Input(.bossPhaseStart(newPhase)))
        } else if (shouldSendInput) {
            InputQueue.append(Input(.bossTurnStart(newPhase)))
        }
    }
    
    public func saveState() -> BossPhase {
        return phase
    }
}

