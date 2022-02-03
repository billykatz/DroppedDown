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

enum BossSuperAttackType: String, Codable {
    case web
}

enum BossAttackType: Hashable, Codable, CustomStringConvertible {
    case dynamite
    case poison
    case spawnMonster(withType: EntityModel.EntityType)
    
    static var defaultSpawnMonster: BossAttackType {
        return .spawnMonster(withType: .spider)
    }
    
    var description: String {
        switch self {
        case .dynamite:
            return "Dynamite"
        case .poison:
            return "Poison"
        case .spawnMonster(withType: let type):
            return "Spawn \(type.rawValue)"
        }
    }
}

enum BossStateType: Hashable, Codable, CustomStringConvertible {
    case intro
    case targetEat
    case eats
    case targetAttack(type: BossAttackType)
    case attack(type: BossAttackType)
    case rests
    case phaseChange
    case targetSuperAttack
    case superAttack
    
    var description: String {
        switch self {
        case .intro:
            return "Intro"
        case .targetEat:
            return "Target Eats"
        case .eats:
            return "Eats"
        case .targetAttack(let type):
            return "Target Attack - \(type.description)"
        case .attack(let type):
            return "Attacks - \(type.description)"
        case .rests:
            return "Rests"
        case .phaseChange:
            return "Phase Change"
        case .targetSuperAttack:
            return "Target Super Attack"
        case .superAttack:
            return "Super Attack"
        }
    }
    
}

struct BossTargets: Codable, Hashable {
    var whatToEat: [TileCoord]?
    var eats: [TileCoord]?
    var whatToAttack: [BossAttackType: [TileCoord]]?
    var attack: [BossAttackType: [TileCoord]]?
    var superAttack: [BossSuperAttackType: [TileCoord]]?
    
    var spawnMonsterAttacks: [(BossAttackType, [TileCoord])] {
        let initalValue: [(BossAttackType, [TileCoord])] = []
        return (attack ?? [:]).reduce(initalValue, { prev, entry in
            let (key, value) = entry
            if case BossAttackType.spawnMonster = key {
                var newResult = prev
                newResult.append((key, value))
                return newResult
            } else {
                return prev
            }
        })
    }
    
    var monsterTypesSpawned: [EntityModel.EntityType] {
        
        let initalValue: [(BossAttackType, [TileCoord])] = []
        let attacks = (whatToAttack ?? [:]).reduce(initalValue, { prev, entry in
            let (key, value) = entry
            if case BossAttackType.spawnMonster = key {
                var newResult = prev
                newResult.append((key, value))
                return newResult
            } else {
                return prev
            }
        })
        
        let attackCoord: [(EntityModel.EntityType, TileCoord)] = []
        let monsterTypeCoords = attacks.reduce(attackCoord) { prev, bossAttack -> [(EntityModel.EntityType, TileCoord)]  in
            let (attackType, coords) = bossAttack
            var newArray = prev
            if case BossAttackType.spawnMonster(withType: let type) = attackType {
                for coord in coords {
                    newArray.append((type, coord))
                }
                return newArray
            } else {
                return prev
            }
        }
        
        return monsterTypeCoords.sorted { firstMonsterAttack, secondMonsterAttack in
            return firstMonsterAttack.1.col < secondMonsterAttack.1.col
        }.map { $0.0 }
    }

    
    var whereToSpawnMonstersCoordinates: [TileCoord] {
        var tileCoords: [TileCoord] = []
        for (key, value) in whatToAttack ?? [:] {
            if case BossAttackType.spawnMonster = key {
                tileCoords.append(contentsOf: value)
            }
        }
        
        return tileCoords
    }
    
    var whatToAttackContainsSpawnMonster: Bool {
        return (whatToAttack ?? [:]).keys.contains(where: {
            if case BossAttackType.spawnMonster = $0 {
                return true
            } else {
                return false
            }
        })
    }
}

struct BossState: Codable, Hashable, CustomStringConvertible {
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
    
    func advance(tiles: [[Tile]], turnsInState: Int, nummberOfRocksToEat: Int, eatenRocks: Int) -> BossState {
        if turnsLeftInState <= 0 {
            let nextStateType = nextStateType(tiles, eatenRocks: eatenRocks)
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
    
    var description: String {
        return "\(stateType.description) - \(turnsLeftInState)"
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
                whatToAttack: oldState.targets.whatToAttack,
                attack: validateAndUpdatePlannedAttacks(in: tiles, plannedAttacks: oldState.targets.whatToAttack)
            )
            
        case .intro, .rests, .phaseChange, .superAttack, .targetSuperAttack:
            break
        }
    }
    
    func nextStateType(_ tiles: [[Tile]], eatenRocks: Int) -> BossStateType {
        switch self.stateType {
        case .targetEat:
            // all the targeted tiles can be destroyed by the player in which case we should cycle back to the start of the boss routine
            if (eats(in: tiles) ?? []).isEmpty { return .rests }
            else { return .eats }
            
        case .eats:
            // after eating, there is a chance the super attack is charge in which case we would advance to super attaack targeting
//            if superAttackIsCharged(eatenRocks: eatenRocks) {
//                return .targetSuperAttack
//            } else {
            // choose the correct targeting mode to start in
            if (targets.whatToAttack ?? [:]).keys.contains(where: { $0 == .dynamite }) {
                return .targetAttack(type: .dynamite)
            } else if (targets.whatToAttack ?? [:]).keys.contains(where: { $0 == .poison }) {
                return .targetAttack(type: .poison)
            } else if targets.whatToAttackContainsSpawnMonster {
                return .targetAttack(type: .defaultSpawnMonster)
            } else {
                return.rests
            }
//            }
            
        case let .targetAttack(type: type):
            return .attack(type: type)
            
        case let .attack(type: type):
            // the attacks are now sequenced
            // 1. Dyanmite
            // 2. Poison
            // 3. Spawn Spider
            
            // Depending on what rocks the Boss eats, it may not go in that exact order
            switch type {
            case .dynamite:
                if (targets.whatToAttack ?? [:]).keys.contains(where: { $0 == .poison }) {
                    return .targetAttack(type: .poison)
                } else if targets.whatToAttackContainsSpawnMonster {
                    return .targetAttack(type: .defaultSpawnMonster)
                } else {
                    return.rests
                }
            case .poison:
                if targets.whatToAttackContainsSpawnMonster {
                    return .targetAttack(type: .defaultSpawnMonster)
                } else {
                    return .rests
                }
            case .spawnMonster:
                return .rests
            }
            
        case .targetSuperAttack:
            return .superAttack
            
        case .superAttack:
            return .rests
            
        case .intro, .rests, .phaseChange:
            return .targetEat
//            if superAttackIsCharged(eatenRocks: eatenRocks) { return  .targetSuperAttack }
//            else { return .targetEat }
            
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
        case .second: return 6 // return 4
        case .third: return 7
        case .dead: return 0
        }
    }
    
    var rocksToSpawn: Int {
        switch self {
        case .first:
            return 0
        case .second:
            return 5
        case .third:
            return 7
        case .dead:
            return 0
        }
    }
    
    var rockColorToSpawn: ShiftShaft_Color? {
        switch self {
        case .first, .dead:
            return nil
        case .second: return .brown
        case .third: return .green
        }
        
    }
    
    var monstersToSpawn: Int {
        switch self {
        case .first: return 0
        case .second: return 3
        case .third: return 6
        case .dead: return 0
        }
    }
}

struct BossPhaseTargets: Codable, Hashable {
    let createPillars: [BossTileAttack]?
    let spawnMonsters: [BossTileAttack]?
    let throwRocks: [BossTileAttack]?
}

struct BossPhase: Codable, Hashable {
    private(set) var bossState: BossState
    public let bossPhaseType: BossPhaseType
    private let numberOfIndividualColumns: Double
    var phaseChangeTagets: BossPhaseTargets
    var eatenRocks: Int
    
    public init(numberOfColumns: Int = 0) {
        let initialState = BossState(stateType: .intro, turnsLeftInState: turnsInState(.intro), targets: BossTargets())
        self.init(bossState: initialState, bossPhaseType: .first, numberColumns: numberOfColumns, eatenRocks: 0)
    }
    
    private init(bossState: BossState, bossPhaseType: BossPhaseType, numberColumns: Int, bossPhaseChangeTargets: BossPhaseTargets? = nil, eatenRocks: Int) {
        self.bossState = bossState
        self.bossPhaseType = bossPhaseType
        self.numberOfIndividualColumns = Double(numberColumns)
        self.phaseChangeTagets = bossPhaseChangeTargets ?? BossPhaseTargets(createPillars: nil, spawnMonsters: nil, throwRocks: nil)
        self.eatenRocks = eatenRocks
    }
    
    
    mutating func advance(tiles: [[Tile]]) -> (BossPhase, Bool) {
        let oldBossState = bossState
        let nextStateTurns = turnsInState(bossState.nextStateType(tiles, eatenRocks: eatenRocks))
        
        // this sets the next state's number of turns.  If the state doesnt advnace then it is ignored
        let nextBossState = bossState.advance(tiles: tiles, turnsInState: nextStateTurns, nummberOfRocksToEat: bossPhaseType.rocksToEat, eatenRocks: eatenRocks)
        
        // send input on all state changes AND also when the state is rest so we can animate the eyes
        let sendInput = (nextBossState.stateType != oldBossState.stateType) || nextBossState.stateType == .rests
        
        // next boss phase might happen
        // phases are based on the number of pillars
        let nextBossPhaseType = nextPhase(tiles: tiles)
        var nextBossPhase = BossPhase(bossState: nextBossState, bossPhaseType: nextBossPhaseType, numberColumns: Int(numberOfIndividualColumns), eatenRocks: eatenRocks)
        
        // the phase is changing, let's do a special attack
        // this will overwrite any active boss attack, that's on purpose
        if nextBossPhaseType != self.bossPhaseType {
            
            // create a new boss state with the type .phaseChange
            let phaseChangeBossState = BossState(stateType: .phaseChange, turnsLeftInState: turnsInState(.phaseChange), targets: BossTargets())
            
            // lets calculate the phase change targets
            let nextPhaseChangeTargets: BossPhaseTargets = calculatePhaseChangeTargets(nextPhase: nextBossPhaseType, tiles: tiles)
//            let nextPhaseChangeTagets = BossPhaseTargets(createPillars: calculatePhaseChangeTargets(nextPhase: nextBossPhaseType, tiles: tiles), spawnMonsters: nil, throwRocks: nil)
            
            // grab the extra number of columns
            let numberOfAdditionalColumns = (nextPhaseChangeTargets.createPillars?.count ?? 0) * 3
            
            // create the next boss phase that will be returned
            nextBossPhase = BossPhase(bossState: phaseChangeBossState, bossPhaseType: nextBossPhaseType, numberColumns: Int(numberOfIndividualColumns)+numberOfAdditionalColumns, bossPhaseChangeTargets: nextPhaseChangeTargets, eatenRocks: eatenRocks)
            
        }
        
        return (nextBossPhase, sendInput)
    }
    
    func calculatePhaseChangeTargets(nextPhase: BossPhaseType, tiles: [[Tile]]) -> BossPhaseTargets {
        var rocksThrown = Set<BossTileAttack>()
        var monstersSpawned = Set<BossTileAttack>()
        
        var nonTargetable = nonGrowableCoords(tiles: tiles)
        var maxCount = 100
        while (rocksThrown.count < nextPhase.rocksToSpawn) && maxCount >= 0 {
            //should be brown or green
            let rockColor = nextPhase.rockColorToSpawn ?? .brown
            let randomCoord = randomCoord(in: tiles, notIn: nonTargetable)
            rocksThrown.insert(BossTileAttack(TileType.rock(color: rockColor, holdsGem: false, groupCount: 1), randomCoord))
            nonTargetable.insert(randomCoord)
            maxCount -= 1
        }
        
        maxCount = 100
        while (monstersSpawned.count < nextPhase.monstersToSpawn) && (maxCount >= 0) {
            let randomCoord = randomCoord(in: tiles, notIn: nonTargetable)
            let randomMonster = EntityModel.monsterWithRandomType()
            let alreadySpawnedThisTypeOfMonster = monstersSpawned.contains(where: { bossTileAttack in
                if case TileType.monster(let monster) =  bossTileAttack.tileType {
                    return randomMonster.type == monster.type
                } else {
                    return false
                }
            })
            if !alreadySpawnedThisTypeOfMonster {
                monstersSpawned.insert(BossTileAttack(TileType.monster(randomMonster), randomCoord))
                nonTargetable.insert(randomCoord)
            } else if monstersSpawned.count >= EntityModel.bossMonsters.count {
                // for the second phase change we spawn a lot of monsters
                // so its okay if we repeat some
                monstersSpawned.insert(BossTileAttack(TileType.monster(randomMonster), randomCoord))
                nonTargetable.insert(randomCoord)
            }
            maxCount -= 1
        }
        
        return BossPhaseTargets(createPillars: nil, spawnMonsters: Array(monstersSpawned), throwRocks: Array(rocksThrown))
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
            if Double(healthLeft) <= numberOfIndividualColumns*0.33 {
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
        
        // move on to the next phase
        if newPhase.bossPhaseType != oldPhase.bossPhaseType {
            InputQueue.append(Input(.bossPhaseStart(newPhase)))
        }
        // move on to the next state within a phase
        else if (shouldSendInput) {
            if newPhase.bossState.stateType == .eats {
                // record what we had eaten from the previous
                self.phase.eatenRocks += newPhase.bossState.targets.eats?.count ?? 0
            } else if newPhase.bossState.stateType == .targetSuperAttack {
                self.phase.eatenRocks = 0
            }
            
            InputQueue.append(Input(.bossTurnStart(newPhase)))
        }
    }
    
    public func saveState() -> BossPhase {
        return phase
    }
}

