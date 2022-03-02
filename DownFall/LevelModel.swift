//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

struct LevelVariableModifier {
    
    func chanceDeltaOfferHealth(playerData: EntityModel) -> Float {
        if Double(playerData.hp) <= Double(playerData.originalHp / 4)  {
            return 25
        }
        else if Double(playerData.hp) <= Double(playerData.originalHp / 3) {
            return 15
        } else if Double(playerData.hp) <= Double(playerData.originalHp / 2)  {
            return 10
        } else if Double(playerData.hp) <= Double(playerData.originalHp / 3 * 4)  {
            return 5
        } else if playerData.hp == playerData.originalHp {
            return -20
        } else {
            return 0
        }
    }
    
//    func chanceDeltaOfferNonRuneRelated(playerData: EntityModel, lastLevelOfferings: [StoreOffer]?) -> Float {
//        if Double(playerData.hp) <= Double(playerData.originalHp / 4)  {
//            return 30
//        }
//        else if Double(playerData.hp) <= Double(playerData.originalHp / 3) {
//            return 20
//        } else if Double(playerData.hp) <= Double(playerData.originalHp / 2)  {
//            return 10
//        } else if Double(playerData.hp) <= Double(playerData.originalHp / 3 * 4)  {
//            return 5
//        } else if playerData.hp == playerData.originalHp {
//            return -20
//        } else {
//            return 0
//        }
//    }
//
    
    func chanceDeltaOfferRune(playerData: EntityModel, currentChance: Float, lastLevelOfferings: [StoreOffer]?) -> Float {
        guard let pickaxe = playerData.pickaxe else { return 0 }
        
        var delta: Float = 0
        let offeredARuneLastLevel = lastLevelOfferings?.contains(where: { $0.rune != nil })
        
        switch (pickaxe.isAtMaxCapacity(), offeredARuneLastLevel) {
        case (true, true):
            delta += -10
        case (true, false):
            delta += 10
        case (false, true):
            delta += 0
        case (false, false):
            delta += 15
        case (true, .none):
            delta += -20
        case (false, .none):
            delta += 0
        default:
            delta += 0
        }
        
        return max(1, currentChance+delta)
        
    }
    
    func chanceDeltaOfferRuneSlot(playerData: EntityModel, currentChance: Float, lastLevelOfferings: [StoreOffer]?) -> Float {
        guard let pickaxe = playerData.pickaxe else { return 0 }
        
        var delta: Float = 0
        let offeredARuneSlotLastLevel = lastLevelOfferings?.contains(where: { $0.type == .runeSlot })
        
        switch (pickaxe.isAtMaxCapacity(), offeredARuneSlotLastLevel) {
        case (true, true):
            delta += 15
        case (true, false):
            delta += 20
        case (false, true):
            delta += -30
        case (false, false):
            delta += 0
        case (true, .none):
            delta += 25
        case (false, .none):
            delta += -15
        default:
            delta += 0
        }
        return max(1, currentChance + delta)
    }
    
    func chanceDeltaOfferHealthInEncasement(playerData: EntityModel, currentChance: Float) -> Float {
        var delta: Float = 0
        if Double(playerData.hp) <= Double(playerData.originalHp / 4)  {
            delta = 15
        }
        else if Double(playerData.hp) <= Double(playerData.originalHp / 3) {
            delta = 10
        } else if Double(playerData.hp) <= Double(playerData.originalHp / 2)  {
            delta = 5
        } else if playerData.hp == playerData.originalHp {
            delta = -20
        } else {
            delta = 0
        }
        
        return max(1, currentChance + delta)
    }
    
    
    func chanceDeltaOfferRuneInEncasement(playerData: EntityModel, currentChance: Float) -> Float {
        guard let pickaxe = playerData.pickaxe else { return 0 }
        
        var delta: Float = 0
        
        if pickaxe.isAtMaxCapacity() {
            delta += -10
        } else {
            delta += 10
        }
        
        return max(1, currentChance+delta)
        
    }
    
    func chanceDeltaOfferRuneSlotInEncasement(playerData: EntityModel, currentChance: Float) -> Float {
        guard let pickaxe = playerData.pickaxe else { return 0 }
        
        var delta: Float = 0
        
        if pickaxe.isAtMaxCapacity() {
            delta += 10
        } else {
            delta += -10
        }
        
        return max(1, currentChance+delta)
        
    }
    
    
    
    
    func chanceDeltaEncasement(numberOfEncasements: Int, depth: Depth, lastLevelFeatures: LevelFeatures?) -> Float {
        guard let lastLevelFeatures = lastLevelFeatures else {
            return 0
        }
        
        if lastLevelFeatures.encasements.isEmpty {
            if depth < 6 {
                return 20
            } else if depth < 8 {
                return 25
            } else if depth <= bossLevelDepthNumber {
                if numberOfEncasements < 2 {
                    return 15
                } else {
                    return 5
                }
            }
        } else {
            if depth < 6 {
                return -15
            } else if depth < 8 {
                return -20
            } else if depth <= bossLevelDepthNumber {
                if numberOfEncasements < 2 {
                    return -10
                } else {
                    return -3
                }
            }
        }
        
        return 0
        
    }
    
    func chanceDeltaEncasementOffer(encasedOfferChanceModel: ChanceModel, playerData: EntityModel, lastLevelFeatures: LevelFeatures?) -> ChanceModel {
        guard let features = lastLevelFeatures, !features.encasements.isEmpty else { return encasedOfferChanceModel }
        var totalDelta: Float = 0
        let delta = features.encasements.reduce(Float(0), { prev, tile in
            var totalDelta: Float = 0
            // touch luck
            let oldOffer = tile.tileType
            let newOffer = encasedOfferChanceModel.tileType
            switch (oldOffer, newOffer) {
                
                // monster was the old offer
            case (.monster, .monster):
                totalDelta -= 25
            case (.monster, .exit):
                totalDelta -= 15
            case (.monster, .item), (.monster, .offer):
                totalDelta += 25
                
                // exit was the old offer
            case (.exit, .monster):
                totalDelta -= 20
            case (.exit, .exit):
                totalDelta -= 25
            case (.exit, .item), (.exit, .offer):
                totalDelta += 25
                
                // offered an rune or item last level?
            case (.offer, .exit):
                totalDelta += 15
            case (.offer, .monster):
                totalDelta += 10
            case (.offer, .offer):
                totalDelta -= 12.5
            case (.offer, .item):
                totalDelta -= 12.5
                
                // got offered gems last level?
            case (.item, .exit):
                totalDelta += 10
            case (.item, .monster):
                totalDelta += 5
            case (.item, .item):
                totalDelta -= 20
            case (.item, .offer):
                totalDelta -= 5
                
            case (_, _):
                totalDelta += 0
            }
            
            return prev + totalDelta
        })
        totalDelta += delta
        
        return ChanceModel(tileType: encasedOfferChanceModel.tileType, chance: max(1, encasedOfferChanceModel.chance + totalDelta))
    }
    
    
}


class Level: Codable, Hashable {
    
    static func ==(_ lhs: Level, _ rhs: Level) -> Bool {
        return lhs.depth == rhs.depth && lhs.randomSeed == rhs.randomSeed
    }
    
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), goals: [LevelGoal(type: .unlockExit, tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)], maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, gemsSpawned: 0, monsterSpawnTurnTimer: 0, startingUnlockables: [], otherUnlockables: [], randomSeed: 12345, isTutorial: false, runModel: nil)
    
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
    let goals: [LevelGoal]
    let maxSpawnGems: Int
    var goalProgress: [GoalTracking]
    var savedBossPhase: BossPhase?
    var gemsSpawned: Int
    var monsterSpawnTurnTimer: Int
    let startingUnlockables: [Unlockable]
    let otherUnlockables: [Unlockable]
    let randomSeed: UInt64
    let isTutorial: Bool
    weak var runModel: RunModel?
    
    private var levelChanceModifier: LevelVariableModifier {
        return LevelVariableModifier()
    }
    
    public var levelFeatures: LevelFeatures?
    public var levelStartTiles: [LevelStartTiles] {
        if let all = levelFeatures?.levelStartTiles {
            return all
        } else {
            return  []
        }
    }
    public var offers: [StoreOffer] = []
    
    public var bossLevelStartTiles: [LevelStartTiles] {
        let toughMonster: EntityModel.EntityType = .bat
        let goodReward = TileType.item(Item(type: .gem, amount: 100, color: .blue))
        
        let coord1 = TileCoord(6, 4)
        let coord2 = TileCoord(2, 4)
        let coords = [coord1, coord2]
        
        let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
        
        let (newCoords, element) = coords.dropRandom()
        let monsterStartTile = LevelStartTiles(tileType: TileType.monster(monsterEntity), tileCoord: element!)
        
        let rewardStartTile = LevelStartTiles(tileType: goodReward, tileCoord: newCoords.first!)
        
        let newPillarCoords: [TileCoord] = [
            TileCoord(7, 4), TileCoord(5, 4), TileCoord(6, 3), TileCoord(6, 5),
            TileCoord(3, 4), TileCoord(1, 4), TileCoord(2, 3), TileCoord(2, 5),
        ]
        
        var pillarCoords = matchupPillarsRandomly(coordinatess: newPillarCoords)
        
        pillarCoords.append(monsterStartTile)
        pillarCoords.append(rewardStartTile)
        
        return pillarCoords
        
    }
    
    public var isBossLevel: Bool {
        return bossLevelDepthNumber == depth
    }
    
    public var humanReadableDepth: String {
        return "\(depth + 1)"
    }
    
    init(
        depth: Depth,
        monsterTypeRatio: [EntityModel.EntityType: RangeModel],
        monsterCountStart: Int,
        maxMonsterOnBoardRatio: Double,
        boardSize: Int,
        tileTypeChances: TileTypeChanceModel,
        goals: [LevelGoal],
        maxSpawnGems: Int,
        goalProgress: [GoalTracking],
        savedBossPhase: BossPhase?,
        gemsSpawned: Int,
        monsterSpawnTurnTimer: Int,
        startingUnlockables: [Unlockable],
        otherUnlockables: [Unlockable],
        randomSeed: UInt64,
        isTutorial: Bool,
        runModel: RunModel?
        
    ) {
        self.depth = depth
        self.monsterTypeRatio = monsterTypeRatio
        self.monsterCountStart = monsterCountStart
        self.maxMonsterOnBoardRatio = maxMonsterOnBoardRatio
        self.boardSize = boardSize
        self.tileTypeChances = tileTypeChances
        self.goals = goals
        self.maxSpawnGems = maxSpawnGems
        self.goalProgress = goalProgress
        self.savedBossPhase = savedBossPhase
        self.gemsSpawned = gemsSpawned
        self.monsterSpawnTurnTimer = monsterSpawnTurnTimer
        self.startingUnlockables = startingUnlockables
        self.otherUnlockables = otherUnlockables
        self.randomSeed = randomSeed
        self.isTutorial = isTutorial
        self.runModel = runModel
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(depth)
    }
    
    // MARK: - Public Methods
    
    
    public func monsterChanceOfShowingUp(tilesSinceMonsterKilled: Int) -> Int {
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
    
    /// func to create different configurations of level start tiles
    /// Sets the LevelFeatures var that backs level start tiles
    public func createLevelStartTiles(playerData: EntityModel) -> [LevelStartTiles] {
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        let lastLevelFeatures = runModel?.lastLevelFeatures(currentDepth: depth)
        //        let lastLevelOffersings = runModel?.lastLevelOffers(currentDepth: depth)
        var encasementTiles: [LevelStartTiles] = []
        var pillarTiles: [LevelStartTiles] = []
        
        switch depth {
        case 0,1,2:
            pillarTiles = []
            encasementTiles = []
            
        case 3:
            // 2 pillars
            pillarTiles = lowLevelPillars(randomSource: randomSource)
            encasementTiles = []
            
        case 4:
            // 50% chance to have just a pair of columns
            if randomSource.procsGivenChance(50) {
                // then create 4 pillars with something inside
                let randomHealthItem = randomItem(playerData: playerData, tier: 1) { offer in
                    return offer.type.isAHealingOption
                }
                let nonHealthItem = randomItem(playerData: playerData, tier: 1) { offer in
                    return !offer.type.isAHealingOption
                }
                
                let chanceDeltaHealthOffer = levelChanceModifier.chanceDeltaOfferHealth(playerData: playerData)
                let randomHealthChance = 50 + chanceDeltaHealthOffer
                let randomNonHealthChance = 50 - chanceDeltaHealthOffer
                
                let chanceModel: [ChanceModel] = [
                    .init(tileType: .offer(.offer(type: randomHealthItem.type, tier: 3)), chance: randomHealthChance),
                    .init(tileType: .offer(.offer(type: nonHealthItem.type, tier: 3)), chance: randomNonHealthChance)]
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                encasementTiles = encasement
            } else {
                pillarTiles = lowLevelPillars(randomSource: randomSource)
            }
            
        case 5:
            // spawn encasement
            let deltaSpawnEncasement = levelChanceModifier.chanceDeltaEncasement(numberOfEncasements: 1, depth: depth, lastLevelFeatures: lastLevelFeatures)
            let baseChanceProcEncasement: Float = 66
            let newChanceProcEncasement = baseChanceProcEncasement + deltaSpawnEncasement
            
            if randomSource.procsGivenChance(newChanceProcEncasement) {
                // then create 4 pillars with something inside
                // create monster to encase
                let toughMonster: EntityModel.EntityType = .bat
                let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
                
                // create rune encasement chances
                let randomRune = randomRune(playerData: playerData)
                let runeChance = levelChanceModifier.chanceDeltaOfferRuneInEncasement(playerData: playerData, currentChance: 15)
                
                // create rune slot encasement chances
                let runeSlotChance = levelChanceModifier.chanceDeltaOfferRuneSlotInEncasement(playerData: playerData, currentChance: 15)
                
                // create other items to encase
                let randomHealthItem = randomItem(playerData: playerData, tier: 1, optionalCheck: { $0.type.isAHealingOption })
                let gems: Item = .init(type: .gem, amount: 50)
                
                let chanceModel: [ChanceModel] = [
                    .init(tileType: .offer(.offer(type: .rune(randomRune.rune ?? .zero), tier: 3)), chance: runeChance),
                    .init(tileType: .offer(.offer(type: .runeSlot, tier: 3)), chance: runeSlotChance),
                    .init(tileType: .offer(.offer(type: randomHealthItem.type, tier: 3)), chance: 30),
                    .init(tileType: .item(gems), chance: 20),
                    .init(tileType: .monster(monsterEntity), chance: 15),
                    .init(tileType: .exit(blocked: true), chance: 5),
                ].map { [levelChanceModifier] chanceModel in levelChanceModifier.chanceDeltaEncasementOffer(encasedOfferChanceModel: chanceModel, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
                }
                
                
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                encasementTiles = encasement
            } else {
                pillarTiles = midLevelPillars(randomSource: randomSource)
            }
            
        case 6:
            // spawn encasement
            let deltaSpawnEncasement = levelChanceModifier.chanceDeltaEncasement(numberOfEncasements: 1, depth: depth, lastLevelFeatures: lastLevelFeatures)
            let baseChanceProcEncasement: Float = 66
            let newChanceProcEncasement = baseChanceProcEncasement + deltaSpawnEncasement
            
            if randomSource.procsGivenChance(newChanceProcEncasement) {
                // then create 4 pillars with something inside
                let toughMonster: EntityModel.EntityType = .bat
                let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
                let highTierItem = randomItem(playerData: playerData, tier: 2, optionalCheck: nil)
                
                let chanceModel: [ChanceModel] = [
                    .init(tileType: .exit(blocked: true), chance: 40),
                    .init(tileType: .monster(monsterEntity), chance: 40),
                    .init(tileType: .offer(.offer(type: highTierItem.type, tier: 3)), chance: 20),
                ].map {
                    levelChanceModifier.chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
                }
                
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                encasementTiles = encasement
            } else {
                pillarTiles = midLevelPillars(randomSource: randomSource)
            }
            
        case 7:
            // spawn encasement
            let deltaSpawnEncasement = levelChanceModifier.chanceDeltaEncasement(numberOfEncasements: 1, depth: depth, lastLevelFeatures: lastLevelFeatures)
            let baseChanceProcEncasement: Float = 66
            let newChanceProcEncasement = baseChanceProcEncasement + deltaSpawnEncasement
            
            if randomSource.procsGivenChance(newChanceProcEncasement) {
                // then create 4 pillars with something inside
                let toughMonster: EntityModel.EntityType = .bat
                let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
                let highTierHealthItem = randomItem(playerData: playerData, tier: 2, optionalCheck: { $0.type.isAHealingOption })
                let lowTierHealthItem = randomItem(playerData: playerData, tier: 1, optionalCheck: { $0.type.isAHealingOption })
                
                let exitChanceModel: ChanceModel = .init(tileType: .exit(blocked: true), chance: 35)
                let monsterChanceModel: ChanceModel = .init(tileType: .monster(monsterEntity), chance: 35)
                let lowGemChanceModel: ChanceModel = .init(tileType: .item(.init(type: .gem, amount: 50)), chance: 15)
                let highGemChanceModel: ChanceModel = .init(tileType: .item(.init(type: .gem, amount: 100)), chance: 1)
                
                // create and modify health items
                let highHealthChance = levelChanceModifier.chanceDeltaOfferHealthInEncasement(playerData: playerData, currentChance: 10)
                let lowHealthChance = levelChanceModifier.chanceDeltaOfferHealthInEncasement(playerData: playerData, currentChance: 5)
                let highHealthChanceModel: ChanceModel = .init(tileType: .offer(.offer(type: highTierHealthItem.type, tier: 3)), chance: highHealthChance)
                let lowHealthChanceModel: ChanceModel = .init(tileType: .offer(.offer(type: lowTierHealthItem.type, tier: 3)), chance: lowHealthChance)
                
                let chanceModel: [ChanceModel] = [
                    // gems
                    highGemChanceModel,
                    lowGemChanceModel,
                    //health
                    highHealthChanceModel,
                    lowHealthChanceModel,
                    // tough
                    monsterChanceModel,
                    exitChanceModel
                ].map {
                    levelChanceModifier.chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
                }
                
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                encasementTiles = encasement
            } else {
                pillarTiles = midLevelPillars(randomSource: randomSource)
            }
            
        case 8:
            
            // create monster for encasements
            let toughMonster: EntityModel.EntityType = .bat
            let toughMonster2: EntityModel.EntityType = .bat
            let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
            let monsterEntity2 = EntityModel(originalHp: 1, hp: 1, name: toughMonster2.textureString, attack: .zero, type: toughMonster2, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
            let monster1ChanceModel: ChanceModel = .init(tileType: .monster(monsterEntity), chance: 25)
            let monster2ChanceModel: ChanceModel = .init(tileType: .monster(monsterEntity2), chance: 10)
            
            //exit
            let exitChanceModel: ChanceModel = .init(tileType: .exit(blocked: true), chance: 20)
            
            // gem chances
            let highGemChanceModel: ChanceModel = .init(tileType: .item(.init(type: .gem, amount: 100)), chance: 2)
            
            // create and modify health items
            let highTierHealthItem = randomItem(playerData: playerData, tier: 2, optionalCheck: { $0.type.isAHealingOption })
            let lowTierHealthItem = randomItem(playerData: playerData, tier: 1, optionalCheck: { $0.type.isAHealingOption })
            let highHealthChance = levelChanceModifier.chanceDeltaOfferHealthInEncasement(playerData: playerData, currentChance: 10)
            let lowHealthChance = levelChanceModifier.chanceDeltaOfferHealthInEncasement(playerData: playerData, currentChance: 10)
            let highHealthChanceModel: ChanceModel = .init(tileType: .offer(.offer(type: highTierHealthItem.type, tier: 3)), chance: highHealthChance)
            let lowHealthChanceModel: ChanceModel = .init(tileType: .offer(.offer(type: lowTierHealthItem.type, tier: 3)), chance: lowHealthChance)
            
            let highTierItem = randomItem(playerData: playerData, tier: 2, optionalCheck: nil)
            let hieghTierItemChanceModel: ChanceModel = ChanceModel(tileType: .offer(.offer(type: highTierItem.type, tier: 3)), chance: 20)
            
            let chanceModel: [ChanceModel] = [
                // tough onces
                exitChanceModel,
                monster1ChanceModel,
                monster2ChanceModel,
                //health
                highHealthChanceModel,
                lowHealthChanceModel,
                // gems
                highGemChanceModel,
                // item
                hieghTierItemChanceModel
            ]
            
            let baseChanceDoubleEncasements: Float = 50
            let deltaDouble = levelChanceModifier.chanceDeltaEncasement(numberOfEncasements: 2, depth: depth, lastLevelFeatures: lastLevelFeatures)
            let newChanceDoubleEncasements = baseChanceDoubleEncasements + deltaDouble
            
            let baseChanceSingleEncasement: Float = 40
            let deltaSingle = levelChanceModifier.chanceDeltaEncasement(numberOfEncasements: 1, depth: depth, lastLevelFeatures: lastLevelFeatures)
            let newChanceSingleEncasement = baseChanceSingleEncasement + deltaSingle
            
            if randomSource.procsGivenChance(newChanceDoubleEncasements) {
                // spawn encasement
                
                encasementTiles = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 2)
            } else if randomSource.procsGivenChance(newChanceSingleEncasement) {
                encasementTiles = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                
            } else {
                pillarTiles = highLevelPillars(randomSource: randomSource)
            }
            
            
            
        case bossLevelDepthNumber:
            pillarTiles = bossLevelStartTiles
            
        case bossLevelDepthNumber...Int.max:
            pillarTiles = []
            
        default:
            pillarTiles = []
            
        }
        
        self.levelFeatures = LevelFeatures(encasements: encasementTiles, pillars: pillarTiles)
        
        pillarTiles.append(contentsOf: encasementTiles)
        return pillarTiles
    }
    
    public func itemsInTier(_ tier: StoreOfferTier, playerData: EntityModel) -> [StoreOffer] {
        let lastLevelOffers = runModel?.lastLevelOffers(currentDepth: depth)
        let items = potentialItems(tier: tier, playerData: playerData, lastLevelOffers: lastLevelOffers)
        self.offers.append(contentsOf: items)
        return items
    }
    
    public func rerollOffersForLevel(_ level: Level, playerData: EntityModel) -> [StoreOffer] {
        var newOffers: [StoreOffer] = []
        var reservedOffers = Set<StoreOffer>()
        
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        let firstTierOffers = level.itemsInTier(1, playerData: playerData).filter( { $0.type != .snakeEyes } )
        
        if !firstTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(firstTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 1, numberOfItems: firstTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        reservedOffers.removeAll()
        
        let secondTierOffers = level.itemsInTier(2, playerData: playerData).filter( { $0.type != .snakeEyes } )
        
        if !secondTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(secondTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 2, numberOfItems: secondTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        return newOffers
    }
    
    private func rerollPotentialItems(depth: Depth, unlockables: [Unlockable], startingUnlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource, reservedOffers: Set<StoreOffer>, offerTier: StoreOfferTier, numberOfItems: Int) -> [StoreOffer] {
        
        var offers = [StoreOffer]()
        var allUnlockables = unlockables
        allUnlockables.append(contentsOf: startingUnlockables)
        offers.append(contentsOf: rerollTierItems(numberOfItems: numberOfItems, tier: offerTier, depth: depth, unlockables: allUnlockables, playerData: playerData, reservedOffers: reservedOffers, randomSource: randomSource))
        
        return offers
    }
    
    
    private func rerollTierItems(numberOfItems: Int, tier: StoreOfferTier, depth: Depth, unlockables: [Unlockable], playerData: EntityModel, reservedOffers: Set<StoreOffer>, randomSource: GKLinearCongruentialRandomSource) -> [StoreOffer] {
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
    
    public func randomItemOrRune(offersOnBoard: [StoreOffer]) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        // reserve items
        var reservedOffers = Set<StoreOffer>()
        reservedOffers.formUnion(offersOnBoard)
        
        var newOffer: StoreOffer? = allUnlockables.randomElement()?.item
        var maxTries: Int = 30
        while reservedOffers.contains(newOffer ?? .zero) && maxTries > 0 {
            newOffer = allUnlockables.randomElement()?.item
            maxTries -= 1
        }
        
        return newOffer!
    }
    
    // MARK: - Private methods
    
    private func potentialItems(tier: Int, playerData: EntityModel, lastLevelOffers: [StoreOffer]?) -> [StoreOffer] {
        
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        
        if depth == 0 && isTutorial {
            return [
                StoreOffer.offer(type: .gems(amount: 15), tier: 1),
                StoreOffer.offer(type: .plusOneMaxHealth, tier: 1)
            ]
        }
#if DEBUG
        if depth == testLevelDepthNumber {
            if tier == 1 {
                return [
                    StoreOffer.offer(type: .rune(.rune(for: .drillDown)), tier: 1),
                    StoreOffer.offer(type: .greaterRuneSpiritPotion, tier: 1),
                ]
            } else {
                return [
                    StoreOffer.offer(type: .wingedBoots, tier: 2),
                    StoreOffer.offer(type: .runeSlot, tier: 2)
                ]
                
            }
            
        }
#endif
        
        var offers = [StoreOffer]()
        var allUnlockables = otherUnlockables
        allUnlockables.append(contentsOf: startingUnlockables)
        offers.append(contentsOf: tierItems(tier: tier, depth: depth, unlockables: allUnlockables, playerData: playerData, randomSource: randomSource, lastLevelOffers: lastLevelOffers))
        
        return offers
        
    }
    
    /// Item pool rewards
    /// [✅] - At least 1 offer must be a way to heal
    /// [✅] - If the player has an empty rune slot then increase the chance of offering a rune
    /// [✅] - first goal: offer health and something else
    /// [✅] - second goal: offer non-health and non-health
    /// [✅] - if the player has a full pickaxe then increase chance of offering a rune slot
    /// [✅] - if a player just bought an item then increase the chance of it showing up
    ///
    
    private func tierItems(tier: StoreOfferTier, depth: Depth, unlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource, lastLevelOffers: [StoreOffer]?) -> [StoreOffer] {
        
        if tier == 1 {
            // always offer at least 1 heal
            
            let healingOptions =
            unlockables
                .filter { unlockable in
                    return unlockable.canAppearInRun && unlockable.item.tier == tier && unlockable.item.type.isAHealingOption
                }
            
            guard let healingOption = healingOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else { preconditionFailure("There must always be at least 1 unlockable at tier 1 for healing")}
            
            let otherOptions =
            unlockables
                .filter { unlockable in
                    return !healingOptions.contains(unlockable) && unlockable.canAppearInRun && unlockable.item.tier == tier
                }
            
            guard let otherOptionOne = otherOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else {  preconditionFailure("There must always be at least 1 other unlockable at tier 1 that isn't healing")}
            
            guard let otherOptionTwo = otherOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else {  preconditionFailure("There must always be at least 1 other unlockable at tier 1 that isn't healing")}
            
            
            var healthChance:Float = 33
            let deltaHealthChance = levelChanceModifier.chanceDeltaOfferHealth(playerData: playerData)
            healthChance += deltaHealthChance
            let healthChanceModel = AnyChanceModel<StoreOffer>(thing: healingOption.item, chance: healthChance)
            let otherOptionOneChanceModel = AnyChanceModel<StoreOffer>(thing: otherOptionOne.item, chance: 33)
            let otherOptionTwoChanceModel = AnyChanceModel<StoreOffer>(thing: otherOptionTwo.item, chance: 33)
            
            let potentialItems: [AnyChanceModel<StoreOffer>] = [healthChanceModel, otherOptionOneChanceModel, otherOptionTwoChanceModel]
            let choices: [AnyChanceModel<StoreOffer>] = randomSource.chooseElementsWithChance(potentialItems, choices: 2)
            
            return choices.map { $0.thing }
            
            // For testing purposes
            //            return [healingOption.item, StoreOffer.offer(type: .rune(.rune(for: .bubbleUp)), tier: 1)]
        }
        else if tier == 2 {
            // create var to holf potential offerings
            var potentialItems: [AnyChanceModel<StoreOffer>] = []
            
            // create just random item chance
            let nonRuneRelatedOptionChance: Float = 25
//            let deltaNonRuneRelatedOptionChance = levelChanceModifier.chanceDeltaOfferHealth(playerData: <#T##EntityModel#>)
            let notRuneRelatedOptions = unlockables.filter { unlockable in
                // remove rune slots, just offer other types of rewards
                return unlockable.canAppearInRun
                && unlockable.item.tier == tier
                && unlockable.item.type != .runeSlot
                && unlockable.item.rune == nil
            }
            
            if let favoredChoice = notRuneRelatedOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet } ) {
                let favoredChoiceChanceModel = AnyChanceModel(thing: favoredChoice.item, chance: nonRuneRelatedOptionChance)
                potentialItems.append(favoredChoiceChanceModel)
                
                if let nextChoice = randomSource.chooseElement(notRuneRelatedOptions, avoidBlock: { $0 == favoredChoice }) {
                    let nextChoiceChanceModel = AnyChanceModel(thing: nextChoice.item, chance: 15)
                    potentialItems.append(nextChoiceChanceModel)
                }
            }
            
            
            
            // create a rune slot offer based on the palyer's pickaxe and last level's offering
            let offerRuneSlotChance = levelChanceModifier.chanceDeltaOfferRuneSlot(playerData: playerData, currentChance: 25, lastLevelOfferings: lastLevelOffers)
            let runeSlotOffer = StoreOffer.offer(type: .runeSlot, tier: 2)
            let offerRuneSlotChanceModel: AnyChanceModel = .init(thing: runeSlotOffer, chance: offerRuneSlotChance)
            
            potentialItems.append(offerRuneSlotChanceModel)
            
            // create a rune offer 1
            let offerRuneChance = levelChanceModifier.chanceDeltaOfferRune(playerData: playerData, currentChance: 25, lastLevelOfferings: lastLevelOffers)
            let runeOneOptions = unlockables.filter { unlockable in
                if case let StoreOfferType.rune(rune) = unlockable.item.type {
                    return unlockable.canAppearInRun && unlockable.item.tier == tier && !(playerData.pickaxe?.runes.contains(rune) ?? false)
                } else {
                    return false
                }
            }
            
            guard let runeOptionOne = runeOneOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else {
                return potentialItems.map { $0.thing }
            }
            let runeOptionOneChanceModel = AnyChanceModel(thing: runeOptionOne.item, chance: offerRuneChance)
            potentialItems.append(runeOptionOneChanceModel)
            
            let runeOptionsTwo = unlockables.filter { unlockable in
                if case let StoreOfferType.rune(rune) = unlockable.item.type {
                    return unlockable.canAppearInRun
                    && unlockable.item.tier == tier
                    && unlockable != runeOptionOne
                    && !(playerData.pickaxe?.runes.contains(rune) ?? false)
                } else {
                    return false
                }
            }
            
            if let runeOptionTwo = randomSource.chooseElement(runeOptionsTwo) {
                let offerRuneTwoChance = levelChanceModifier.chanceDeltaOfferRune(playerData: playerData, currentChance: 5, lastLevelOfferings: lastLevelOffers)
                let runeOptionTwoChanceModel = AnyChanceModel(thing: runeOptionTwo.item, chance: offerRuneTwoChance)
                potentialItems.append(runeOptionTwoChanceModel)
            }
            
            let choices = randomSource.chooseElementsWithChance(potentialItems, choices: 2)
            return choices.map { $0.thing }
            
        } else {
            preconditionFailure("Only call this for tiers 1 and 2")
        }
    }
    
    
    private func randomRune(playerData: EntityModel) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        let potentialOffers = allUnlockables
            .filter({ $0.canAppearInRun })
            .filter({ $0.item.rune != nil })

        
        var newOffer: StoreOffer? = potentialOffers.randomElement()?.item
        
        var maxTries: Int = 30
        
        while maxTries > 0 {
            if let pickace = playerData.pickaxe,
               pickace.runes.contains(where: { playerRune in
                   return playerRune == (newOffer?.rune ?? .zero)
               }) {
                newOffer = potentialOffers.randomElement()?.item
            } else {
                return newOffer!
            }
            maxTries -= 1
        }
        
        return newOffer!
    }
    
    private func randomItem(playerData: EntityModel, tier: StoreOfferTier, optionalCheck: ((StoreOffer) -> Bool)? ) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        let newOffer: StoreOffer? = allUnlockables
            .filter({ $0.canAppearInRun })
            .filter({ $0.item.rune == nil })
            .filter({ $0.item.tier == tier })
            .filter({ optionalCheck?($0.item) ?? true })
            .randomElement()?.item
        
        return newOffer ?? .zero
    }
    
    
    
    private func potentialEncasementPillarCoords(randomSource: GKLinearCongruentialRandomSource, encasementChanceModel: [ChanceModel], numberOfEncasements: Int) -> [LevelStartTiles] {
        
        if boardSize == 8 {
            let encasementOption1: EncasementCoords = .init(middleTile: TileCoord(2, 2), outerTiles: [TileCoord(2, 1), TileCoord(1, 2), TileCoord(2, 3), TileCoord(3, 2)])
            let encasementOption2: EncasementCoords = .init(middleTile: TileCoord(5, 2), outerTiles: [TileCoord(4, 2), TileCoord(5, 1), TileCoord(6, 2), TileCoord(5, 3)])
            let encasementOption3: EncasementCoords = .init(middleTile: TileCoord(5, 5), outerTiles: [TileCoord(4, 5), TileCoord(5, 4), TileCoord(6, 5), TileCoord(5, 6)])
            let encasementOption4: EncasementCoords = .init(middleTile: TileCoord(2, 5), outerTiles: [TileCoord(2, 4), TileCoord(1, 5), TileCoord(3, 5), TileCoord(2, 6)])
            
            
            var pillarCoords: [LevelStartTiles] = []
            if let chosenEncasement = randomSource.chooseElement([encasementOption1, encasementOption2, encasementOption3, encasementOption4]) {
                
                pillarCoords.append(contentsOf: matchupPillarsRandomly(colors: ShiftShaft_Color.pillarCases, coordinatess: chosenEncasement.outerTiles))
                
                if let randomTile = randomSource.chooseElementWithChance(encasementChanceModel)?.tileType {
                    let encasedLevelStartTile = LevelStartTiles(tileType: randomTile, tileCoord: chosenEncasement.middleTile)
                    pillarCoords.append(encasedLevelStartTile)
                }
            }
            return pillarCoords
            
            
        } else if boardSize == 9 {
            let encasementOption1: EncasementCoords = .init(middleTile: TileCoord(2, 2), outerTiles: [TileCoord(2, 1), TileCoord(2, 3), TileCoord(1, 2), TileCoord(3, 2)])
            let encasementOption2: EncasementCoords = .init(middleTile: TileCoord(4, 1), outerTiles: [TileCoord(4, 0), TileCoord(4, 2), TileCoord(5, 1), TileCoord(3, 1)])
            let encasementOption3: EncasementCoords = .init(middleTile: TileCoord(6, 2), outerTiles: [TileCoord(6, 1), TileCoord(6, 3), TileCoord(7, 2), TileCoord(5, 2)])
            let encasementOption4: EncasementCoords = .init(middleTile: TileCoord(7, 4), outerTiles: [TileCoord(7, 3), TileCoord(7, 5), TileCoord(6, 4), TileCoord(8, 4)])
            let encasementOption5: EncasementCoords = .init(middleTile: TileCoord(6, 6), outerTiles: [TileCoord(6, 5), TileCoord(6, 7), TileCoord(5, 6), TileCoord(7, 6)])
            let encasementOption6: EncasementCoords = .init(middleTile: TileCoord(4, 7), outerTiles: [TileCoord(4, 6), TileCoord(4, 8), TileCoord(3, 7), TileCoord(5, 7)])
            let encasementOption7: EncasementCoords = .init(middleTile: TileCoord(2, 6), outerTiles: [TileCoord(2, 5), TileCoord(2, 7), TileCoord(1, 6), TileCoord(3, 6)])
            let encasementOption8: EncasementCoords = .init(middleTile: TileCoord(1, 4), outerTiles: [TileCoord(1, 3), TileCoord(1, 5), TileCoord(0, 4), TileCoord(2, 4)])
            let encasementOption9: EncasementCoords = .init(middleTile: TileCoord(4, 4), outerTiles: [TileCoord(4, 3), TileCoord(4, 5), TileCoord(3, 4), TileCoord(5, 4)])
            
            
            
            /// choose the outer encasements
            let allEncasements = [encasementOption1, encasementOption2, encasementOption3, encasementOption4, encasementOption5, encasementOption6, encasementOption7, encasementOption8, encasementOption9]
            let chosenEncasements = randomSource.chooseElements(choose: numberOfEncasements, fromArray: allEncasements)
            
            /// choose the two chance models
            var mutableChangeModels = encasementChanceModel
            
            var allCoords: [LevelStartTiles] = []
            for chosenEncasement in chosenEncasements {
                allCoords.append(contentsOf: matchupPillarsRandomly(colors: ShiftShaft_Color.pillarCases, coordinatess: chosenEncasement.outerTiles))
                
                if let randomTile = randomSource.chooseElementWithChance(mutableChangeModels)?.tileType {
                    mutableChangeModels.removeFirst { chanceModel in
                        return chanceModel.tileType == randomTile
                    }
                    let encasedLevelStartTile = LevelStartTiles(tileType: randomTile, tileCoord: chosenEncasement.middleTile)
                    allCoords.append(encasedLevelStartTile)
                }
            }
            
            return allCoords
            
        } else {
            // shouldnt be calling this
            return []
        }
    }
    
    private func matchupPillarsRandomly(colors: [ShiftShaft_Color] = ShiftShaft_Color.pillarCases, coordinatess: [TileCoord]) -> [LevelStartTiles] {
        var pillarColors = colors
        var coords = coordinatess
        var pillarCoordinates: [LevelStartTiles] = []
        
        // create PillarCoordinates randoming selecting elements from pillarColors and coords
        while pillarCoordinates.count < coordinatess.count {
            if pillarColors.isEmpty {
                pillarColors = colors.shuffled()
            }
            
            let (remainingColors, randomColor) = pillarColors.dropRandom()
            let (remainingCoords, randomCoord) = coords.dropRandom()
            
            pillarColors = remainingColors
            coords = remainingCoords
            
            if let color = randomColor, let coord = randomCoord {
                let pillarTile = TileType.pillar(PillarData(color: color, health: 3))
                let pillarCoord = LevelStartTiles(tileType: pillarTile, tileCoord: coord)
                pillarCoordinates.append(pillarCoord)
            }
            
        }
        
        return pillarCoordinates
    }
    
    
    
    private func lowLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
        let coords: [TileCoord] = [
            TileCoord(5, 4), TileCoord(3, 4),
        ]
        
        let coords2: [TileCoord] = [
            TileCoord(1, 1), TileCoord(6, 6)
        ]
        
        let coords3: [TileCoord] = [
            TileCoord(4, 1), TileCoord(3, 6)
        ]
        
        let coords4: [TileCoord] = [
            TileCoord(3, 4), TileCoord(4, 3),
        ]
        
        let coords5: [TileCoord] = [
            TileCoord(4, 0), TileCoord(3, 7),
        ]
        
        
        if let chosenCoords = randomSource.chooseElement([coords, coords2, coords3, coords4, coords5]) {
            return matchupPillarsRandomly(coordinatess: chosenCoords)
        } else {
            return []
        }
    }
    
    
    private func midLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
        let coords: [TileCoord] = [
            TileCoord(3, 3), TileCoord(5, 3),
            TileCoord(3, 5), TileCoord(5, 5)
        ]
        
        let coords2: [TileCoord] = [
            TileCoord(1, 4), TileCoord(3, 4), TileCoord(5, 4), TileCoord(7, 4)
        ]
        
        let coords3: [TileCoord] = [
            TileCoord(6, 2), TileCoord(2, 2),
            TileCoord(2, 6), TileCoord(6, 6)
        ]
        
        let coords4: [TileCoord] = [
            TileCoord(8, 3), TileCoord(8, 5),
            TileCoord(0, 3), TileCoord(0, 5)
        ]
        
        let coords5: [TileCoord] = [
            TileCoord(7, 1), TileCoord(1, 1),
            TileCoord(4, 4),
            TileCoord(7, 7), TileCoord(1, 7)
        ]
        
        let coords6: [TileCoord] = [
            TileCoord(8, 4), TileCoord(4, 8),
            TileCoord(4, 4),
            TileCoord(0, 4), TileCoord(4, 0)
        ]
        
        if let chosenCoords = randomSource.chooseElement([coords, coords2, coords3, coords4, coords5, coords6]) {
            return matchupPillarsRandomly(coordinatess: chosenCoords)
        } else {
            return []
        }
    }
    
    private func highLevelPillars(randomSource: GKLinearCongruentialRandomSource, avoid: [LevelStartTiles] = []) -> [LevelStartTiles] {
        let coords: [TileCoord] = [
            TileCoord(1, 8), TileCoord(0, 7), TileCoord(0, 8),
            TileCoord(8, 0), TileCoord(7, 0), TileCoord(8, 1)
        ]
        
        let coords2: [TileCoord] = [
            TileCoord(3, 0), TileCoord(4, 0), TileCoord(5, 0),
            TileCoord(3, 8), TileCoord(4, 8), TileCoord(5, 8)
        ]
        
        let coords3: [TileCoord] = [
            TileCoord(7, 3), TileCoord(6, 4), TileCoord(7, 5),
            TileCoord(1, 3), TileCoord(2, 4), TileCoord(1, 5),
        ]
        
        let coords4: [TileCoord] = [
            TileCoord(5, 3), TileCoord(5, 4),TileCoord(5, 5),
            TileCoord(4, 4),
            TileCoord(3, 3), TileCoord(3, 4),TileCoord(3, 5),
        ]
        
        let coords5: [TileCoord] = [
            TileCoord(4, 3), TileCoord(4, 4), TileCoord(4, 5),
            TileCoord(8, 4), TileCoord(7, 4),
            TileCoord(0, 4), TileCoord(1, 4),
        ]
        
        let coords6: [TileCoord] = [
            TileCoord(8, 0), TileCoord(7, 1),
            TileCoord(0, 0), TileCoord(1, 1),
            TileCoord(1, 7), TileCoord(0, 8),
            TileCoord(7, 7), TileCoord(8, 8),
        ]
        
        let allCoords = [coords, coords2, coords3, coords4, coords5, coords6]
        
        // filter out any set of coords that contains someone from avoid
        let possibleCoords = allCoords.filter { coords in
            return coords.allSatisfy { coord in
                !avoid
                    .map { $0.tileCoord }
                    .contains(coord)
            }
        }
        if let chosenCoords = randomSource.chooseElement(possibleCoords) {
            return matchupPillarsRandomly(coordinatess: chosenCoords)
        } else {
            return []
        }
        
    }
}

