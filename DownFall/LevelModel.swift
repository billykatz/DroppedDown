//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

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
    
    var levelStartTiles: [LevelStartTiles] = []
    
    public var bossLevelStartTiles: [LevelStartTiles] {
        let toughMonster: EntityModel.EntityType = Bool.random() ? .bat : .sally
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
    public func createLevelStartTiles(playerData: EntityModel) -> [LevelStartTiles] {
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        let lastLevelStartTiles = runModel?.lastLevelStartTiles(currentDepth: depth)
        var levelStartTiles: [LevelStartTiles] = []
        
        switch depth {
        case 0,1,2:
            levelStartTiles = []
            
        case 3:
            // 2 pillars
            levelStartTiles = lowLevelPillars(randomSource: randomSource)
            
        case 4:
            // 50% chance to have just a pair of columns
            if randomSource.procsGivenChance(50) {
                // then create 4 pillars with something inside
                let chanceModel: [ChanceModel] = [.init(tileType: .offer(.offer(type: .lesserHeal, tier: 3)), chance: 50), .init(tileType: .item(.init(type: .gem, amount: 25)), chance: 50)]
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                levelStartTiles = encasement
            } else {
                levelStartTiles = lowLevelPillars(randomSource: randomSource)
            }
            
        case 5:
            // spawn encasement
            if randomSource.procsGivenChance(66) {
                // then create 4 pillars with something inside
                let toughMonster: EntityModel.EntityType = .bat
                let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
                let randomRune = randomRune(playerData: playerData)
                let chanceModel: [ChanceModel] = [
                    .init(tileType: .offer(.offer(type: .rune(randomRune.rune ?? .zero), tier: 3)), chance: 30),
                    .init(tileType: .item(.init(type: .gem, amount: 50)), chance: 30),
                    .init(tileType: .monster(monsterEntity), chance: 15),
                    .init(tileType: .empty, chance: 25),
                ]
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                levelStartTiles = encasement
            } else {
                levelStartTiles = midLevelPillars(randomSource: randomSource)
            }
            
        case 6:
            // spawn encasement
            if randomSource.procsGivenChance(66) {
                // then create 4 pillars with something inside
                let toughMonster: EntityModel.EntityType = .bat
                let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
                let chanceModel: [ChanceModel] = [
                    .init(tileType: .exit(blocked: true), chance: 50),
                    .init(tileType: .monster(monsterEntity), chance: 50),
                ]
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                levelStartTiles = encasement
            } else {
                levelStartTiles = midLevelPillars(randomSource: randomSource)
            }
            
        case 7:
            // spawn encasement
            let toughMonster: EntityModel.EntityType = .bat
            let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
            let chanceModel: [ChanceModel] = [
                .init(tileType: .exit(blocked: true), chance: 50),
                .init(tileType: .monster(monsterEntity), chance: 50),
            ]
            
            let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
            
            // procs and adds a encasement.  also adds 2 extra pillar
            if randomSource.procsGivenChance(50) {
                var tiles: [LevelStartTiles] = []
                tiles.append(contentsOf: encasement)
                
                let highLevelPillars = highLevelPillars(randomSource: randomSource, avoid: encasement)
                
                tiles.append(contentsOf: randomSource.chooseElements(choose: 2, fromArray: highLevelPillars))
                levelStartTiles = tiles
            } else {
                levelStartTiles = highLevelPillars(randomSource: randomSource, avoid: encasement)
            }
            
            
        case 8:
            
            let toughMonster: EntityModel.EntityType = randomSource.nextBool() ? .sally : .bat
            let toughMonster2: EntityModel.EntityType = randomSource.nextBool() ? .dragon : .sally
            let monsterEntity = EntityModel(originalHp: 1, hp: 1, name: toughMonster.textureString, attack: .zero, type: toughMonster, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
            let monsterEntity2 = EntityModel(originalHp: 1, hp: 1, name: toughMonster2.textureString, attack: .zero, type: toughMonster2, carry: .zero, animations: [], pickaxe: nil, effects: [], dodge: 0, luck: 0, killedBy: nil)
            let randomItem = randomItem(playerData: playerData, tier: 2)
            let chanceModel: [ChanceModel] = [
                .init(tileType: .exit(blocked: true), chance: 20),
                .init(tileType: .monster(monsterEntity), chance: 20),
                .init(tileType: .monster(monsterEntity2), chance: 8),
                .init(tileType: .offer(.offer(type: .greaterHeal, tier: 3)), chance: 20),
                .init(tileType: .offer(.offer(type: randomItem.type, tier: 3)), chance: 20),
                .init(tileType: .item(.init(type: .gem, amount: 100)), chance: 2),
                .init(tileType: .empty, chance: 10),
            ]
            
            
            if randomSource.procsGivenChance(10) {
                // spawn encasement
                
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 2)
                
                levelStartTiles = encasement
            } else if randomSource.procsGivenChance(55) {
                let encasement = potentialEncasementPillarCoords(randomSource: randomSource, encasementChanceModel: chanceModel, numberOfEncasements: 1)
                
                levelStartTiles = encasement

            } else {
                levelStartTiles = highLevelPillars(randomSource: randomSource)
            }
            
            
            
        case bossLevelDepthNumber:
            levelStartTiles = bossLevelStartTiles
            
        case bossLevelDepthNumber...Int.max:
            levelStartTiles = []
            
        default:
            levelStartTiles = []
            
        }
        self.levelStartTiles = levelStartTiles
        return levelStartTiles
    }
    
    public func itemsInTier(_ tier: StoreOfferTier, playerData: EntityModel) -> [StoreOffer] {
        return potentialItems(tier: tier, playerData: playerData)
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
    
    private func potentialItems(tier: Int, playerData: EntityModel) -> [StoreOffer] {
        
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
        offers.append(contentsOf: tierItems(tier: tier, depth: depth, unlockables: allUnlockables, playerData: playerData, randomSource: randomSource))
        
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
    
    private func tierItems(tier: StoreOfferTier, depth: Depth, unlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource) -> [StoreOffer] {
        
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
            
            guard let otherOption = otherOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else {  preconditionFailure("There must always be at least 1 other unlockable at tier 1 that isn't healing")}
            
            return [healingOption.item, otherOption.item]
            
            // For testing purposes
            //            return [healingOption.item, StoreOffer.offer(type: .rune(.rune(for: .bubbleUp)), tier: 1)]
        }
        else if tier == 2 {
            let playerHasFullPickaxe = playerData.pickaxe?.isAtMaxCapacity() ?? false
            
            let chanceRune: Int
            let chanceRuneSlot: Int
            if playerHasFullPickaxe {
                chanceRune = 20
                chanceRuneSlot = 50
            } else {
                chanceRune = 75
                chanceRuneSlot = 0
            }
            
            var randomNumber = randomSource.nextInt(upperBound: 100)
            var offeredRuneAlready = false
            var offeredRuneSlotAlready = false
            var options: [Unlockable] = []
            while (options.count < 2) {
                
                if (randomNumber < chanceRune && !offeredRuneAlready) {
                    offeredRuneAlready = true
                    let runeOptions = unlockables.filter { unlockable in
                        if case let StoreOfferType.rune(rune) = unlockable.item.type {
                            return unlockable.canAppearInRun && unlockable.item.tier == tier && !(playerData.pickaxe?.runes.contains(rune) ?? false)
                        } else {
                            return false
                        }
                    }
                    
                    guard let option = runeOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else { continue }
                    
                    options.append(option)
                    
                } else if (randomNumber >= chanceRune && randomNumber < chanceRune + chanceRuneSlot && !offeredRuneSlotAlready) {
                    offeredRuneSlotAlready = true
                    
                    let runeSlotOptions = unlockables.filter { unlockable in
                        return unlockable.canAppearInRun && unlockable.item.tier == tier && unlockable.item.type == .runeSlot
                    }
                    
                    guard let option = runeSlotOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else { continue }
                    
                    options.append(option)
                    
                } else {
                    let otherOptions = unlockables.filter { unlockable in
                        
                        // remove runes
                        if case StoreOfferType.rune = unlockable.item.type {
                            return false
                        }
                        
                        // remove rune slots, just offer other types of rewards
                        return !options.contains(unlockable) && unlockable.canAppearInRun && unlockable.item.tier == tier && unlockable.item.type != .runeSlot
                    }
                    
                    guard let option = otherOptions.randomElement(favorWhere: { $0.recentlyPurchasedAndHasntSpawnedYet }) else { continue }
                    
                    options.append(option)
                }
                
                randomNumber = randomSource.nextInt(upperBound: 100)
                
            }
            
            return options.map { $0.item }
            
            
        } else {
            preconditionFailure("For this release we are only allowing two goals")
        }
        
    }
    
    
    private func randomRune(playerData: EntityModel) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        var newOffer: StoreOffer? = allUnlockables
            .filter({ $0.canAppearInRun })
            .filter({ $0.item.rune != nil })
            .randomElement()?.item
        
        var maxTries: Int = 30
        
        while maxTries > 0 {
            if let pickace = playerData.pickaxe,
               pickace.runes.contains(where: { playerRune in
                   return playerRune == (newOffer?.rune ?? .zero)
               }) {
                newOffer = allUnlockables.randomElement()?.item
            } else {
                return newOffer!
            }
            maxTries -= 1
        }
        
        return newOffer!
    }
    
    private func randomItem(playerData: EntityModel, tier: StoreOfferTier) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        let newOffer: StoreOffer? = allUnlockables
            .filter({ $0.canAppearInRun })
            .filter({ $0.item.rune == nil })
            .filter({ $0.item.tier == tier })
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
                avoid
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

