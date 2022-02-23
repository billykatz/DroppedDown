//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

enum LevelGoalType: String, Codable, Hashable {
    case unlockExit
    case useRune
    case destroyBoss
}

struct LevelGoal: Codable, Hashable {
    let type: LevelGoalType
    let tileType: TileType
    let targetAmount: Int
    let minimumGroupSize: Int
    let grouped: Bool
    
    static func bossGoal() -> LevelGoal {
        return LevelGoal(type: .destroyBoss, tileType: .empty, targetAmount: 1, minimumGroupSize: 1, grouped: false)
    }
    
    static func gemGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .gem, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func killMonsterGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .monster(.zeroedEntity(type: .rat)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func pillarGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .unlockExit, tileType: .pillar(PillarData(color: .blue, health: 1)), targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
    
    static func useRuneGoal(amount: Int) -> LevelGoal {
        return LevelGoal(type: .useRune, tileType: .empty, targetAmount: amount, minimumGroupSize: 1, grouped: false)
    }
}

struct PillarCoorindates: Codable, Hashable {
    let pillar: TileType
    let coord: TileCoord
    
    init(_ tuple: (TileType, TileCoord)) {
        self.pillar = tuple.0
        self.coord = tuple.1
    }
    
}

struct LevelStartTiles: Codable, Hashable {
    let tileType: TileType
    let tileCoord: TileCoord
}

class Level: Codable, Hashable {
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
    let pillarCoordinates: [PillarCoorindates]
    let goals: [LevelGoal]
    let maxSpawnGems: Int
    var goalProgress: [GoalTracking]
    var savedBossPhase: BossPhase?
    let potentialItems: [StoreOffer]
    var gemsSpawned: Int
    var monsterSpawnTurnTimer: Int
    let levelStartTiles: [LevelStartTiles]
    let startingUnlockables: [Unlockable]
    let otherUnlockables: [Unlockable]
    
    init(
        depth: Depth,
        monsterTypeRatio: [EntityModel.EntityType: RangeModel],
        monsterCountStart: Int,
        maxMonsterOnBoardRatio: Double,
        boardSize: Int,
        tileTypeChances: TileTypeChanceModel,
        pillarCoordinates: [PillarCoorindates],
        goals: [LevelGoal],
        maxSpawnGems: Int,
        goalProgress: [GoalTracking],
        savedBossPhase: BossPhase?,
        potentialItems: [StoreOffer],
        gemsSpawned: Int,
        monsterSpawnTurnTimer: Int,
        levelStartTiles: [LevelStartTiles],
        startingUnlockables: [Unlockable],
        otherUnlockables: [Unlockable]
    ) {
        self.depth = depth
        self.monsterTypeRatio = monsterTypeRatio
        self.monsterCountStart = monsterCountStart
        self.maxMonsterOnBoardRatio = maxMonsterOnBoardRatio
        self.boardSize = boardSize
        self.tileTypeChances = tileTypeChances
        self.pillarCoordinates = pillarCoordinates
        self.goals = goals
        self.maxSpawnGems = maxSpawnGems
        self.goalProgress = goalProgress
        self.savedBossPhase = savedBossPhase
        self.potentialItems = potentialItems
        self.gemsSpawned = gemsSpawned
        self.monsterSpawnTurnTimer = monsterSpawnTurnTimer
        self.levelStartTiles = levelStartTiles
        self.startingUnlockables = startingUnlockables
        self.otherUnlockables = otherUnlockables
    }
    
    static func ==(_ lhs: Level, _ rhs: Level) -> Bool {
        return lhs.depth == rhs.depth
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(depth)
    }
    
    var hasExit: Bool {
        return true
    }
    
    var spawnsMonsters: Bool {
        return true
    }
    
    var isBossLevel: Bool {
        return bossLevelDepthNumber == depth
    }
    
    var humanReadableDepth: String {
        return "\(depth + 1)"
    }
    
    var numberOfIndividualColumns: Int {
        return 3*pillarCoordinates.count
    }
    
    func monsterChanceOfShowingUp(tilesSinceMonsterKilled: Int) -> Int {
        switch depth {
        case 0,1:
            if tilesSinceMonsterKilled < 20 {
                return -1
            } else if tilesSinceMonsterKilled < 50 {
                return 3
            } else {
                return 10
            }
            
        case 2,3,4:
            if tilesSinceMonsterKilled < 20 {
                return -1
            } else if tilesSinceMonsterKilled < 45 {
                return 5
            } else {
                return 15
            }
            
        case 5, 6:
            if tilesSinceMonsterKilled < 18 {
                return -1
            } else if tilesSinceMonsterKilled < 36 {
                return 6
            } else {
                return 17
            }
            
        case bossLevelDepthNumber:
            return -1
            
        case 7,8...Int.max:
            if tilesSinceMonsterKilled < 15 {
                return -1
            } else if tilesSinceMonsterKilled < 30 {
                return 7
            } else {
                return 20
            }

            
        default:
            return -1
        }
    }
        
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), pillarCoordinates: [], goals: [LevelGoal(type: .unlockExit, tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, potentialItems: [], gemsSpawned: 0, monsterSpawnTurnTimer: 0, levelStartTiles: [], startingUnlockables: [], otherUnlockables: [])
    
    func rerollOffersForLevel(_ level: Level, playerData: EntityModel) -> [StoreOffer] {
        var newOffers: [StoreOffer] = []
        var reservedOffers = Set<StoreOffer>()
        
        let seed = UInt64.random(in: .min ... .max)
        let randomSource = GKLinearCongruentialRandomSource(seed: seed)
        let firstTierOffers = level.potentialItems.filter( { $0.tier == 1 && $0.type != .snakeEyes } )
        
        if !firstTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(firstTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 1, numberOfItems: firstTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        reservedOffers.removeAll()
        
        let secondTierOffers = level.potentialItems.filter( { $0.tier == 2 && $0.type != .snakeEyes } )
        
        if !secondTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(secondTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 2, numberOfItems: secondTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        return newOffers
    }
    
    func rerollPotentialItems(depth: Depth, unlockables: [Unlockable], startingUnlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource, reservedOffers: Set<StoreOffer>, offerTier: StoreOfferTier, numberOfItems: Int) -> [StoreOffer] {
                
        var offers = [StoreOffer]()
        var allUnlockables = unlockables
        allUnlockables.append(contentsOf: startingUnlockables)
        offers.append(contentsOf: rerollTierItems(numberOfItems: numberOfItems, tier: offerTier, depth: depth, unlockables: allUnlockables, playerData: playerData, reservedOffers: reservedOffers, randomSource: randomSource))
        
        return offers
    }

    
    func rerollTierItems(numberOfItems: Int, tier: StoreOfferTier, depth: Depth, unlockables: [Unlockable], playerData: EntityModel, reservedOffers: Set<StoreOffer>, randomSource: GKLinearCongruentialRandomSource) -> [StoreOffer] {
        var storeOffers: [StoreOffer] = []
        
        var allOptions =
        unlockables
            .filter { unlockable in
                return unlockable.canAppearInRun && unlockable.item.tier == tier && (!reservedOffers.contains(unlockable.item) && unlockable.item.type != .snakeEyes)
            }
        
        // grab as many as we need
        var maxCount = 30
        while storeOffers.count < numberOfItems {
            let potentialOption = allOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet })
            if let potentialOffer = potentialOption?.item, !storeOffers.contains(potentialOffer) {
                storeOffers.append(potentialOffer)
                allOptions.removeFirst(where: { $0 == potentialOption })
            }
            
            maxCount -= 1
            if maxCount < 0 {
                break
            }
        }
        
        return storeOffers
    }
    
    func randomItemOrRune(offersOnBoard: [StoreOffer]) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        // reserve items
        var reservedOffers = Set<StoreOffer>(self.potentialItems)
        reservedOffers.formUnion(offersOnBoard)
        
        var newOffer: StoreOffer? = allUnlockables.randomElement()?.item
        var maxTries: Int = 30
        while reservedOffers.contains(newOffer ?? .zero) && maxTries > 0 {
            newOffer = allUnlockables.randomElement()?.item
            maxTries -= 1
        }
        
        return newOffer!
    }

}
