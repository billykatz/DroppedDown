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
    
    struct Constants {
        static let tag = String(describing: Level.self)
    }
    
    static func ==(_ lhs: Level, _ rhs: Level) -> Bool {
        return lhs.depth == rhs.depth && lhs.randomSeed == rhs.randomSeed
    }
    
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, gemsSpawned: 0, monsterSpawnTurnTimer: 0, startingUnlockables: [], otherUnlockables: [], randomSeed: 12345, isTutorial: false, runModel: nil)
    
    enum CodingKeys: String, CodingKey {
        case depth
        case monsterTypeRatio
        case monsterCountStart
        case maxMonsterOnBoardRatio
        case boardSize
        case tileTypeChances
        case maxSpawnGems
        case goalProgress
        case savedBossPhase
        case gemsSpawned
        case monsterSpawnTurnTimer
        case startingUnlockables
        case otherUnlockables
        case randomSeed
        case isTutorial
        case offers
        case goals
        case levelFeatures
        // run model purposely left out to avoid circular references
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(depth, forKey: .depth)
        try container.encode(monsterTypeRatio, forKey: .monsterTypeRatio)
        try container.encode(monsterCountStart, forKey: .monsterCountStart)
        try container.encode(maxMonsterOnBoardRatio, forKey: .maxMonsterOnBoardRatio)
        try container.encode(boardSize, forKey: .boardSize)
        try container.encode(tileTypeChances, forKey: .tileTypeChances)
        try container.encode(maxSpawnGems, forKey: .maxSpawnGems)
        try container.encode(savedBossPhase, forKey: .savedBossPhase)
        try container.encode(gemsSpawned, forKey: .gemsSpawned)
        try container.encode(monsterSpawnTurnTimer, forKey: .monsterSpawnTurnTimer)
        try container.encode(startingUnlockables, forKey: .startingUnlockables)
        try container.encode(otherUnlockables, forKey: .otherUnlockables)
        try container.encode(randomSeed, forKey: .randomSeed)
        try container.encode(isTutorial, forKey: .isTutorial)
        try container.encode(goalProgress, forKey: .goalProgress)
        try container.encode(goals, forKey: .goals)
        try container.encode(offers, forKey: .offers)
        try container.encode(levelFeatures, forKey: .levelFeatures)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        depth = try container.decode(Int.self, forKey: .depth)
        monsterTypeRatio = try container.decode([EntityModel.EntityType: RangeModel].self, forKey: .monsterTypeRatio)
        monsterCountStart = try container.decode(Int.self, forKey: .monsterCountStart)
        maxMonsterOnBoardRatio = try container.decode(Double.self, forKey: .maxMonsterOnBoardRatio)
        boardSize = try container.decode(Int.self, forKey: .boardSize)
        tileTypeChances = try container.decode(TileTypeChanceModel.self, forKey: .tileTypeChances)
        maxSpawnGems = try container.decode(Int.self, forKey: .maxSpawnGems)
        gemsSpawned = try container.decode(Int.self, forKey: .gemsSpawned)
        monsterSpawnTurnTimer = try container.decode(Int.self, forKey: .monsterSpawnTurnTimer)
        startingUnlockables = try container.decode([Unlockable].self, forKey: .startingUnlockables)
        otherUnlockables = try container.decode([Unlockable].self, forKey: .otherUnlockables)
        goalProgress = try container.decode([GoalTracking].self, forKey: .goalProgress)
        goals = try container.decode([LevelGoal].self, forKey: .goals)
        
        if let offers = try? container.decode([StoreOffer].self, forKey: .offers) {
            self.offers = offers
        } else {
            offers = []
        }
        
        if let isTutorial = try? container.decode(Bool.self, forKey: .isTutorial) {
            self.isTutorial = isTutorial
        } else {
            isTutorial = false
        }
        
        // added in 0.8.1
        if let randomSeed = try? container.decode(UInt64.self, forKey: .randomSeed) {
            self.randomSeed = randomSeed
        } else {
            randomSeed = UInt64.random(in: UInt64.min...UInt64.max)
            
        }
        
        // added in 0.8.1
        if let savedBossPhase = try? container.decode(BossPhase.self, forKey: .savedBossPhase) {
            self.savedBossPhase = savedBossPhase
        } else {
            if depth == bossLevelDepthNumber {
                savedBossPhase = BossPhase.init(numberOfColumns: 36)
            } else {
                self.savedBossPhase = nil
            }
        }
        
        if let levelFeatures = try? container.decode(LevelFeatures.self, forKey: .levelFeatures) {
            self.levelFeatures = levelFeatures
        } else {
            self.levelFeatures = nil
        }
        
        // run model purposefully left out because it is passed in on Level construction from the RunModel
        runModel = nil
    }
    
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
    let maxSpawnGems: Int
    var gemsSpawned: Int
    var monsterSpawnTurnTimer: Int
    let startingUnlockables: [Unlockable]
    let otherUnlockables: [Unlockable]
    let randomSeed: UInt64
    let isTutorial: Bool
    var goalProgress: [GoalTracking]
    var savedBossPhase: BossPhase?
    public var offers: [StoreOffer] = []
    public var goals: [LevelGoal] = []
    public var levelFeatures: LevelFeatures?
    weak var runModel: RunModel?

    
    public var levelStartTiles: [LevelStartTiles] {
        if let all = levelFeatures?.levelStartTiles {
            return all
        } else {
            return  []
        }
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
    
    public func startLevel(playerData: EntityModel, isTutorial: Bool) {
        // sets level features
        let levelStartTiles = createLevelStartTiles(playerData: playerData)
        // sets our self.goals
        let previousLevelGoals = runModel?.lastLevelGoals(currentDepth: depth)
        self.goals = createLevelGoals(playerData: playerData, levelStartTiles: levelStartTiles, isTutorial: isTutorial, previousLevelGoals: previousLevelGoals)
    }
    
    
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
        let firstTierOffers = level.itemsInTier(1, playerData: playerData)//.filter( { $0.tier == 1 && $0.type != .snakeEyes } )
        
        if !firstTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(firstTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 1, numberOfItems: firstTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        reservedOffers.removeAll()
        
        // remove any runes that the player has from this offer pool
        let secondTierOffers = level.itemsInTier(2, playerData: playerData)
        
        if !secondTierOffers.isEmpty {
            reservedOffers = reservedOffers.union(secondTierOffers)
            let newOffer = level.rerollPotentialItems(depth: level.depth, unlockables: level.otherUnlockables, startingUnlockables: level.startingUnlockables, playerData: playerData, randomSource: randomSource, reservedOffers: reservedOffers, offerTier: 2, numberOfItems: secondTierOffers.count)
            
            newOffers.append(contentsOf: newOffer)
        }
        
        return newOffers
    }
    
    public func randomItemOrRune(playerData: EntityModel, offersOnBoard: [StoreOffer]) -> StoreOffer {
        // pool of items
        var allUnlockables = Set<Unlockable>(self.startingUnlockables)
        allUnlockables.formUnion(self.otherUnlockables)
        
        let unlockables = Array(allUnlockables)
        
        // reserve items
        var reservedOffers = Set<StoreOffer>()
        reservedOffers.formUnion(offersOnBoard)
        
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        if let chosen = randomSource.chooseElement(unlockables, avoidBlock: { unlockable in
            if reservedOffers.contains(unlockable.item) {
                return true
            } else if case StoreOfferType.gems = unlockable.item.type {
                return true
            } else if unlockable.applysToBasePlayer {
                // get rid of boring lucks and dodges
                return true
            } else if let runes = playerData.pickaxe?.runes,
                      let unlockableRune = unlockable.item.rune {
                return runes.contains(unlockableRune)
            } else if unlockable.item.type == .chest {
                // get rid of chests
                return true
            } else {
                return false
            }
        }) {
            return chosen.item
        } else {
            return .offer(type: .plusOneMaxHealth, tier: 1)
        }
    }
    
    
    // MARK: - Private methods
    
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
    
    /// func to create different configurations of level start tiles
    /// Sets the LevelFeatures var that backs level start tiles
    private func createLevelGoals(playerData: EntityModel, levelStartTiles: [LevelStartTiles], isTutorial: Bool, previousLevelGoals: [LevelGoal]?) -> [LevelGoal] {
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        func randomRockGoal(_ colors: [ShiftShaft_Color], amount: Int, minimumGroupSize: Int = 1) -> LevelGoal {
            let randomColor = colors.randomElement()!
            return LevelGoal(type: .unlockExit, tileType: .rock(color: randomColor, holdsGem: false, groupCount: 0),
                             targetAmount: amount, minimumGroupSize: minimumGroupSize, grouped: minimumGroupSize > 1)
        }
        
        let totalPillarAmount = levelStartTiles
            .filter { levelStartTile in
                if case TileType.pillar = levelStartTile.tileType {
                    return true
                } else {
                    return false
                }
            }
            .compactMap { $0.tileType.pillarHealth }
            .reduce(0, +)
        
        let offeredGemAmount = levelStartTiles
            .compactMap { $0.tileType.gemAmount }
            .reduce(0, +)
        
#if DEBUG
        if let goals = createScreenShotLevelGoals() {
            return goals
        }
#endif
        
        var goalChances: [AnyChanceModel<LevelGoal>] = []
        switch depth {
        case 0:
            if isTutorial {
                let rockGoal = randomRockGoal([.purple], amount: 15)
                
                return [rockGoal]
            }
            
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 1)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 20)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 50)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 50)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance])
            
        case 1:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 2)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 25)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 50)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 50)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance])
            
        case 2:
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 30)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 3)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 50)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 50)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance])
            
            
        case 3:
            
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 30)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 4)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 4:
            let monsterAmount = 5
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 35)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 5:
            let monsterAmount = 7
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 40)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            if offeredGemAmount > 0 {
                let gemGoal = LevelGoal.gemGoal(amount: offeredGemAmount)
                let gemGoalChance = AnyChanceModel(thing: gemGoal, chance: 100)
                goalChances.append(gemGoalChance)
            }
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 20)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 20)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 20)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 6:
            let monsterAmount = 9
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 45)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
            
        case 7:
            let monsterAmount = 12
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 50)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            if offeredGemAmount > 0 {
                let gemGoal = LevelGoal.gemGoal(amount: offeredGemAmount)
                let gemGoalChance = AnyChanceModel(thing: gemGoal, chance: 200)
                goalChances.append(gemGoalChance)
            }
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 20)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 20)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 20)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 8:
            let monsterAmount = 15
            let totalPillarAmount = createTotalPillarGoalAmount(totalPillars: totalPillarAmount, depth: depth, randomSource: randomSource, previousLevelGoals: previousLevelGoals)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 55)
            let brownRockGoal = randomRockGoal([.brown], amount: 7)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            if offeredGemAmount > 0 {
                let gemGoal = LevelGoal.gemGoal(amount: offeredGemAmount)
                let gemGoalChance = AnyChanceModel(thing: gemGoal, chance: 200)
                goalChances.append(gemGoalChance)
            }
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 20)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 20)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 20)
            let brownGoalChance = AnyChanceModel(thing: brownRockGoal, chance: 20)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance, brownGoalChance])
            
        case bossLevelDepthNumber:
            return [LevelGoal.bossGoal()]
                
        case 10...Int.max:
            let monsterAmount = Int.random(in: 10...15)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: Int.random(lower: 60, upper: 75, interval: 5))
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            return [rockGoal, monsterGoal]
            
        case testLevelDepthNumber:
            let rockGoal = LevelGoal(type: .unlockExit, tileType: .rock(color: .blue, holdsGem: false, groupCount: 0), targetAmount: 3, minimumGroupSize: 1, grouped: false)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            if offeredGemAmount > 0 {
                let gemGoal = LevelGoal.gemGoal(amount: offeredGemAmount)
                let gemGoalChance = AnyChanceModel(thing: gemGoal, chance: 200)
                goalChances.append(gemGoalChance)
            }
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 20)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 20)
            
            goalChances.append(contentsOf: [rockGoalChance, pillarGoalChance])
            
            
        default:
            goalChances = []
        }
        
        goalChances = goalChances.map { chanceDeltaLevelGoal(propsedGoalChanceModel: $0, lastLevelGoals: previousLevelGoals ?? []) }
        
        return randomSource.chooseElementsWithChance(goalChances, choices: 2).map { $0.thing }
    }
    
    
    /// func to create different configurations of level start tiles
    /// Sets the LevelFeatures var that backs level start tiles
    private func createLevelStartTiles(playerData: EntityModel) -> [LevelStartTiles] {
        let randomSource = GKLinearCongruentialRandomSource(seed: randomSeed)
        let lastLevelFeatures = runModel?.lastLevelFeatures(currentDepth: depth)
        //        let lastLevelOffersings = runModel?.lastLevelOffers(currentDepth: depth)
        var encasementTiles: [LevelStartTiles] = []
        var pillarTiles: [LevelStartTiles] = []
        
        let encasementSizes = baseChanceEncasementSize(depth: depth)
        let thingsEncased = baseChanceEncasementOffers(depth: depth, playerData: playerData, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables, randomSource: randomSource, lastLevelFeatures: lastLevelFeatures)
        
        if let chosenSize = randomSource.chooseElementWithChance(encasementSizes)?.thing {
            let levelStartTiles = potentialEncasementPillarCoords(depth: depth, randomSource: randomSource, encasementChanceModel: thingsEncased, encasementSizes: chosenSize)
            pillarTiles = levelStartTiles.pillars
            encasementTiles = levelStartTiles.encasements
        }
        
        self.levelFeatures = LevelFeatures(encasements: encasementTiles, pillars: pillarTiles)
        
        pillarTiles.append(contentsOf: encasementTiles)
        return pillarTiles
    }
    
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
                    StoreOffer.offer(type: .gems(amount: 15), tier: 1),
                    StoreOffer.offer(type: .snakeEyes, tier: 1),
//                    StoreOffer.offer(type: .rune(.rune(for: .drillDown)), tier: 1),
//                    StoreOffer.offer(type: .gemMagnet, tier: 1),
                ]
            } else {
                return [
                    StoreOffer.offer(type: .gems(amount: 50), tier: 2),
                    StoreOffer.offer(type: .snakeEyes, tier: 2)
                ]
                
            }
            
        }
#endif
        
        let lastLevelOffers = runModel?.lastLevelOffers(currentDepth: depth)
        let allPastLevelOffers = runModel?.allPastLevelOffers(currentDepth: depth)
        
        let offers = tierOptions(tier: tier, depth: depth, startingUnlockabls: startingUnlockables, otherUnlockabls: otherUnlockables, lastLevelsOffering: lastLevelOffers, allPastLevelOffers: allPastLevelOffers, playerData: playerData, randomSource: randomSource)
        return offers
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
    
    private func randomItem(playerData: EntityModel, tier: StoreOfferTier, optionalCheck: ((StoreOffer) -> Bool)?) -> StoreOffer {
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
    
    
}

//MARK: - Buckets
/// Weights the different bucket options.
func chanceDeltaStoreOfferBuckets(_ buckets: [AnyChanceModel<StoreOfferBucket>], lastLevelOfferings: [StoreOfferBucket]?, allPastLevelOffers: [StoreOfferBucket]?, playerData: EntityModel, depth: Depth, unlockables: [Unlockable]) -> [AnyChanceModel<StoreOfferBucket>] {
    
    GameLogger.shared.log(prefix: "LevelModel", message: "~~~~~~~~ Level \(depth) ~~~~~~~ ")
    GameLogger.shared.log(prefix: "LevelModel", message: "~~~~~~~~ Weighting Buckets ~~~~~~~ ")
    
    var healthBucketChance = buckets.filter { $0.thing.type == .health }.reduce(Float(0), { prev, current in return prev + current.chance })
    var dodgeLuckBucketChance = buckets.filter { $0.thing.type == .dodgeLuck }.reduce(Float(0), { prev, current in return prev + current.chance })
//    var luckBucketChance = buckets.filter { $0.thing.type == .luck }.reduce(Float(0), { prev, current in return prev + current.chance })
    var utilBucketChance = buckets.filter { $0.thing.type == .util }.reduce(Float(0), { prev, current in return prev + current.chance })
    var wealthBucketChance = buckets.filter { $0.thing.type == .wealth }.reduce(Float(0), { prev, current in return prev + current.chance })
    var runeBucketChance = buckets.filter { $0.thing.type == .rune }.reduce(Float(0), { prev, current in return prev + current.chance })
    
    for bucket in buckets {
        switch (depth, bucket.thing.type) {
        case (0, .health), (1, .health), (2, .health):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(healthBucketChance)")
            healthBucketChance = chanceDeltaOfferHealthBucket(playerData: playerData, currentChance: healthBucketChance, modifier: 1.0)
            
        case (3, .health), (4, .health), (5, .health):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(healthBucketChance)")
            healthBucketChance = chanceDeltaOfferHealthBucket(playerData: playerData, currentChance: healthBucketChance, modifier: 0.9)
            
        case (6, .health), (7, .health), (8, .health):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(healthBucketChance)")
            healthBucketChance = chanceDeltaOfferHealthBucket(playerData: playerData, currentChance: healthBucketChance, modifier: 0.8)
            
        case (_, .dodgeLuck):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(dodgeLuckBucketChance)")
            dodgeLuckBucketChance = chanceDeltaOfferDodgeLuckBucket(playerData: playerData, modifier: 1, currentChance: dodgeLuckBucketChance, lastLevelOfferBuckets: lastLevelOfferings)
            
//        case (_, .luck):
//            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(luckBucketChance)")
//            luckBucketChance = chanceDeltaOfferLuckBucket(playerData: playerData, modifier: 1, currentChance: luckBucketChance, lastLevelOfferBuckets: lastLevelOfferings)
            
        case (_, .util):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(utilBucketChance)")
            utilBucketChance = chanceOfferUtilBucket(pastLevelOffers: lastLevelOfferings, modifier: 1, currentChance: utilBucketChance)
            
        case (_, .wealth):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(wealthBucketChance)")
            wealthBucketChance = chanceDeltaOfferWealthBucket(playerData: playerData, unlockables: unlockables, currentChance: wealthBucketChance)
            
        case (_, .rune):
            GameLogger.shared.log(prefix: "LevelModel", message: "Old \(bucket.thing.type) chance is \(runeBucketChance)")
            runeBucketChance = chanceDeltaOfferRuneBucket(playerData: playerData, allPastLevelOffers: allPastLevelOffers, modifier: 1.0, depth: depth, currentChance: runeBucketChance)
            
        default:
            break
        }
        
    }
    healthBucketChance = max(0.01, healthBucketChance)
    dodgeLuckBucketChance = max(0.01, dodgeLuckBucketChance)
    wealthBucketChance = max(0.01, wealthBucketChance)
    utilBucketChance = max(0.01, utilBucketChance)
    runeBucketChance = max(0.01, runeBucketChance)
    
    return buckets.map { bucket in
        switch bucket.thing.type {
        case .health:
            GameLogger.shared.log(prefix: "LevelModel", message: "New \(bucket.thing.type) chance is \(healthBucketChance)")
            return AnyChanceModel(thing: StoreOfferBucket(type: bucket.thing.type), chance: healthBucketChance)
        case .dodgeLuck:
            GameLogger.shared.log(prefix: "LevelModel", message: "New \(bucket.thing.type) chance is \(dodgeLuckBucketChance)")
            return AnyChanceModel(thing: StoreOfferBucket(type: bucket.thing.type), chance: dodgeLuckBucketChance)
        case .wealth:
            GameLogger.shared.log(prefix: "LevelModel", message: "New \(bucket.thing.type) chance is \(wealthBucketChance)")
            return AnyChanceModel(thing: StoreOfferBucket(type: bucket.thing.type), chance: wealthBucketChance)
        case .util:
            GameLogger.shared.log(prefix: "LevelModel", message: "New \(bucket.thing.type) chance is \(utilBucketChance)")
            return AnyChanceModel(thing: StoreOfferBucket(type: bucket.thing.type), chance: utilBucketChance)
        case .rune:
            GameLogger.shared.log(prefix: "LevelModel", message: "New \(bucket.thing.type) chance is \(runeBucketChance)")
            return AnyChanceModel(thing: StoreOfferBucket(type: bucket.thing.type), chance: runeBucketChance)
        }
        
    }
}
        

func chanceDeltaOfferHealthBucket(playerData: EntityModel, currentChance: Float, modifier: Float) -> Float {
    var delta: Float = 1
    let currHealth = Float(playerData.hp)
    let maxHealth = Float(playerData.originalHp)
    if currHealth <= maxHealth / 4  {
        delta = 5
    }
    else if currHealth <= maxHealth / 3 {
        delta = 4
    } else if currHealth <= maxHealth / 2  {
        delta = 3
    } else if currHealth <= maxHealth / 4 * 3 {
        delta = 2.5
    } else if currHealth <= maxHealth / 6 * 5 {
        delta = 2
    } else {
        delta = 1.25
    }
    
    return delta * currentChance * modifier
}



func chanceDeltaOfferDodgeLuckBucket(playerData player: EntityModel, modifier: Float, currentChance: Float, lastLevelOfferBuckets: [StoreOfferBucket]?) -> Float {
    
    /// Based off dodge stuff
    var dodgeDelta = Float(1)
    if player.dodge > 40 {
        dodgeDelta = 0.1
    } else if player.dodge > 35 {
        dodgeDelta = 0.2
    } else if player.dodge > 30 {
        dodgeDelta = 0.3
    } else if player.dodge > 25 {
        dodgeDelta = 0.4
    } else if player.dodge > 20 {
        dodgeDelta = 0.5
    } else if player.dodge > 15 {
        dodgeDelta = 0.6
    } else if player.dodge > 10 {
        dodgeDelta = 0.9
    } else if player.dodge > 5 {
        dodgeDelta = 1.2
    } else if player.dodge >= 0 {
        dodgeDelta = 1.4
    }
    
    let dodgeOfferedLastLevel = (lastLevelOfferBuckets ?? []).filter{ $0.type == StoreOfferBucketType.dodgeLuck }.count
    if dodgeOfferedLastLevel == 1 {
        dodgeDelta *= 0.25
    } else if dodgeOfferedLastLevel == 2  {
        dodgeDelta *= 0.1
    }
    
    var luckDelta = Float(1)
    if player.luck > 70 {
        luckDelta = 0.1
    } else if player.luck > 60 {
        luckDelta = 0.1
    } else if player.luck > 50 {
        luckDelta = 0.2
    } else if player.luck > 40 {
        luckDelta = 0.4
    } else if player.luck > 30 {
        luckDelta = 0.5
    } else if player.luck > 25 {
        luckDelta = 0.6
    } else if player.luck > 10 {
        luckDelta = 0.9
    } else if player.luck > 5 {
        luckDelta = 1.1
    } else if player.luck >= 0 {
        luckDelta = 1.4
    }


    let luckOfferedLastLevel = (lastLevelOfferBuckets ?? []).filter{  $0.type == StoreOfferBucketType.dodgeLuck }.count
    if luckOfferedLastLevel == 1 {
        luckDelta *= 0.25
    } else if luckOfferedLastLevel == 2  {
        luckDelta *= 0.1
    }

    return currentChance * ((dodgeDelta/2) + (luckDelta/2)) * modifier
}

//func chanceDeltaOfferLuckBucket(playerData player: EntityModel, modifier: Float, currentChance: Float, lastLevelOfferBuckets: [StoreOfferBucket]?) -> Float {
//    var delta = Float(1)
//    if player.luck > 70 {
//        delta = 0.1
//    } else if player.luck > 60 {
//        delta = 0.2
//    } else if player.luck > 50 {
//        delta = 0.3
//    } else if player.luck > 40 {
//        delta = 0.5
//    } else if player.luck > 30 {
//        delta = 0.6
//    } else if player.luck > 25 {
//        delta = 0.8
//    } else if player.luck > 10 {
//        delta = 0.9
//    } else if player.luck > 5 {
//        delta = 0.95
//    } else if player.luck > 0 {
//        delta = 1.1
//    }
//
//
//    let luckOfferedLastLevel = (lastLevelOfferBuckets ?? []).filter{  $0.type == StoreOfferBucketType.luck }.count
//    if luckOfferedLastLevel == 1 {
//        delta *= 0.5
//    } else if luckOfferedLastLevel == 2  {
//        delta *= 0.2
//    }
//
//    return currentChance * delta * modifier
//}

func chanceOfferUtilBucket(pastLevelOffers: [StoreOfferBucket]?, modifier: Float, currentChance: Float) -> Float {
    let numberPastLevels = pastLevelOffers?.filter( { $0.type == .util }).count ?? 0
    var delta = Float(1)
    if numberPastLevels > 2 {
        delta = 0.25
    } else if numberPastLevels > 1 {
        delta = 0.5
    } else {
        delta = 1.5
    }
    
    return delta * modifier * currentChance
}

func chanceDeltaOfferWealthBucket(playerData: EntityModel, unlockables: [Unlockable], currentChance: Float) -> Float {
    var deltaChance = Float(1)
    let totalUnlockables = Float(unlockables.count)
    let totalOwnedUnlockables = Float(unlockables.filter { $0.canAppearInRun }.count)
    
    if totalOwnedUnlockables < totalUnlockables / 5 {
        deltaChance = 1.75
    } else if totalOwnedUnlockables < totalUnlockables / 3 {
        deltaChance = 1.5
    } else if totalOwnedUnlockables < totalUnlockables / 2 {
        deltaChance = 1.35
    } else if totalOwnedUnlockables < totalUnlockables / 3 * 4 {
        deltaChance = 1.15
    } else {
        deltaChance = 0.5
    }
    
    return max(0.01, currentChance * deltaChance)
    
}

func chanceDeltaOfferRuneBucket(playerData: EntityModel, allPastLevelOffers: [StoreOfferBucket]?, modifier: Float, depth: Depth, currentChance: Float) -> Float
{
    guard let pickaxe = playerData.pickaxe else { return  0 }
    var totalDelta = Float(1)
    let runeSlots = pickaxe.runeSlots
    let runes = pickaxe.runes.count
    
    let numberOfRuneOffered = allPastLevelOffers?.filter( { $0.type == .rune }).count ?? 0
    
    switch depth {
    case 0, 1:
        if numberOfRuneOffered >= 2 {
            totalDelta = 0.25
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 0.5
        } else {
            totalDelta = 2.5
        }
    case 2:
        if numberOfRuneOffered >= 2 {
            totalDelta = 0.25
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 0.5
        } else {
            totalDelta = 10
        }
    case 3:
        if numberOfRuneOffered >= 3 {
            totalDelta = 0.05
        } else if numberOfRuneOffered >= 2 {
            totalDelta = 0.25
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 0.75
        } else {
            // you deserve a ruin
            totalDelta = 15
        }
        
    case 4:
        if numberOfRuneOffered >= 3 {
            totalDelta = 0.05
        } else if numberOfRuneOffered >= 2 {
            totalDelta = 0.25
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 0.75
        } else {
            // you deserve a ruin
            totalDelta = 250
        }
        
    case 5, 6:
        if numberOfRuneOffered >= 5 {
            totalDelta = 0.05
        } else if numberOfRuneOffered >= 4 {
            totalDelta = 0.25
        } else if numberOfRuneOffered >= 3 {
            totalDelta = 0.5
        } else if numberOfRuneOffered >= 2 {
            totalDelta = 0.75
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 1
        } else {
            // you deserve a ruin
            totalDelta = 1000
        }
        
    case 7, 8:
        if numberOfRuneOffered >= 5 {
            totalDelta = 0.05
        } else if numberOfRuneOffered >= 4 {
            totalDelta = 0.2
        } else if numberOfRuneOffered >= 3 {
            totalDelta = 0.4
        } else if numberOfRuneOffered >= 2 {
            totalDelta = 0.8
        } else if numberOfRuneOffered >= 1 {
            totalDelta = 1.2
        } else {
            // you deserve a ruin
            totalDelta = 5000
        }
        
    default:
        totalDelta = 5000
    }
    
    if runeSlots - runes >= 4 {
        totalDelta += 0.5
    } else if runeSlots - runes >= 3 {
        totalDelta += 0.33
    } else if runeSlots - runes >= 2 {
        totalDelta += 0.25
    } else if runeSlots - runes >= 1 {
        totalDelta += 0.1
    } else if runeSlots - runes >= 0 {
        totalDelta += 0.1
    }
    
    totalDelta = max(0.1, totalDelta)
    
    
    return totalDelta * currentChance * modifier
}


// MARK: - Offers

func tierOptions(tier: StoreOfferTier, depth: Depth, startingUnlockabls: [Unlockable], otherUnlockabls: [Unlockable], lastLevelsOffering: [StoreOffer]?, allPastLevelOffers: [StoreOffer]?, playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource) -> [StoreOffer] {
    
    GameLogger.shared.log(prefix: "[LevelModel]", message: "~~~~~ Choose Tier Options \(tier) ~~~~~ ")
    let pastLevelOfferBuckets = lastLevelsOffering?.compactMap { StoreOfferBucket.bucket(for: $0.type) }
    let allPastLevelOfferBuckets = allPastLevelOffers?.compactMap { StoreOfferBucket.bucket(for: $0.type) }
    
    let chosenBucketOne: AnyChanceModel<StoreOfferBucket>?
    let chosenBucketTwo: AnyChanceModel<StoreOfferBucket>?
    
    switch tier {
    case 1:
        let baseChance: Float = Float(1)/Float(4) * 100
        let healthBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .health), chance: baseChance)
        let dodgeLuckBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .dodgeLuck), chance: baseChance)
        let utilBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .util), chance: baseChance)
        let wealthBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .wealth), chance: baseChance)
        
        let nonweightBuckets = [healthBucketChanceModel, dodgeLuckBucketChanceModel, utilBucketChanceModel, wealthBucketChanceModel]
        GameLogger.shared.log(prefix: "[LevelModel]", message: "About to weight bucket chances")
        let weightedBuckets = chanceDeltaStoreOfferBuckets(nonweightBuckets, lastLevelOfferings: pastLevelOfferBuckets, allPastLevelOffers: allPastLevelOfferBuckets, playerData: playerData, depth: depth, unlockables: otherUnlockabls)
        GameLogger.shared.log(prefix: "[LevelModel]", message: "Finished weight bucket chances")
        
        let buckets = randomSource.chooseElementsWithChance(weightedBuckets, choices: 2)
        if buckets.count == 0 {
            chosenBucketOne = nonweightBuckets[0]
            chosenBucketTwo = nonweightBuckets[1]
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Buckets is equal to 0")
        } else if buckets.count == 1 {
            chosenBucketOne = buckets.first
            chosenBucketTwo = nonweightBuckets[0]
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Buckets is equal to 1")
        } else {
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Chose \(buckets.first!.thing.type)")
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Chose \(buckets.last!.thing.type)")
            chosenBucketOne = buckets.first
            chosenBucketTwo = buckets.last
        }


    case 2:
        let baseChance: Float = Float(1)/Float(5) * 100
        let healthBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .health), chance: baseChance)
//        let luckBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .luck), chance: baseChance)
        let dodgeLuckBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .dodgeLuck), chance: baseChance)
        let utilBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .util), chance: baseChance)
        let wealthBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .wealth), chance: baseChance)
        let runeBucketChanceModel = AnyChanceModel(thing: StoreOfferBucket(type: .rune), chance: baseChance)
        
        let nonweightBuckets = [healthBucketChanceModel, dodgeLuckBucketChanceModel, utilBucketChanceModel, wealthBucketChanceModel, runeBucketChanceModel]
        GameLogger.shared.log(prefix: "[LevelModel]", message: "About to weight bucket chances")
        let weightedBuckets = chanceDeltaStoreOfferBuckets(nonweightBuckets, lastLevelOfferings: pastLevelOfferBuckets, allPastLevelOffers: allPastLevelOfferBuckets, playerData: playerData, depth: depth, unlockables: otherUnlockabls)
        GameLogger.shared.log(prefix: "[LevelModel]", message: "Finished weight bucket chances")
        
        let buckets = randomSource.chooseElementsWithChance(weightedBuckets, choices: 2)
        if buckets.count == 0 {
            chosenBucketOne = nonweightBuckets[0]
            chosenBucketTwo = nonweightBuckets[1]
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Buckets is equal to 0")
        } else if buckets.count == 1 {
            chosenBucketOne = buckets.first
            chosenBucketTwo = nonweightBuckets[0]
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Buckets is equal to 1")
        } else {
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Chose \(buckets.first!.thing.type)")
            GameLogger.shared.log(prefix: "[LevelModel]", message: "Chose \(buckets.last!.thing.type)")
            chosenBucketOne = buckets.first
            chosenBucketTwo = buckets.last
        }
        
    default:
        chosenBucketOne = nil
        chosenBucketTwo = nil
    }
    
    guard let chosenBucketOne = chosenBucketOne, let chosenBucketTwo = chosenBucketTwo else {
        GameLogger.shared.log(prefix: "[Bug]", message: "No buckets chosen for the store offers")
        return []
    }
    
    var allUnlockables = startingUnlockabls
    allUnlockables.append(contentsOf: otherUnlockabls)
    let items = tierItems(from: [chosenBucketOne.thing, chosenBucketTwo.thing], tier: tier, depth: depth, allUnlockables: allUnlockables, playerData: playerData, randomSource: randomSource, lastLevelOffers: lastLevelsOffering, allPastLevelOFfers: allPastLevelOffers)
    
    
    return items
}

// Wraps each store offer in a chance model with equal chance to choose any of them
func baseChanceForOffers(potentialItems: [StoreOffer]) -> [AnyChanceModel<StoreOffer>] {
    
    var choiceWithChance: [AnyChanceModel<StoreOffer>] = []
    
    for offer in potentialItems {
        let allOptions = max(1, Float(potentialItems.count))
        choiceWithChance.append(.init(thing: offer, chance: 1/allOptions * 100))
    }
    
    return choiceWithChance
}

func deltaChanceOfferHealth(playerData: EntityModel, depth: Depth, storeOffer: StoreOffer, tier: StoreOfferTier, currentChance: Float, lastLevelOffers: [StoreOffer]?) -> Float {
    
    let offerType = storeOffer.type
    let currentHp = Float(playerData.hp)
    let originalHp = Float(playerData.originalHp)
    func maxIntendedHealthPerDepth(_ depth: Depth) -> Float {
        switch depth {
        case 0, 1:
            return 5
        case 2, 3:
            return 6
        case 4, 5:
            return 8
        case 6, 7:
            return 9
        case 8, 9:
            return 10
        default:
            return 5
        }
    }
    
    
    var maxHealthChance = Float(1)
    
    if offerType == .plusOneMaxHealth {
        if originalHp >= maxIntendedHealthPerDepth(depth) {
            maxHealthChance = 0.1
        } else if originalHp >= maxIntendedHealthPerDepth(depth) - 1 {
            maxHealthChance = 0.25
        } else {
            switch depth {
            case 0, 1, 2, 3, 4:
                maxHealthChance = 1.5
            case 5, 6, 7, 8:
                maxHealthChance = 0.5
            default:
                maxHealthChance =  1
            }

        }
    } else if offerType == .plusTwoMaxHealth {
        if originalHp >= maxIntendedHealthPerDepth(depth) {
            maxHealthChance = 0.1
        } else if originalHp >= maxIntendedHealthPerDepth(depth) - 1 {
            maxHealthChance = 0.2
        } else if originalHp >= maxIntendedHealthPerDepth(depth) - 2 {
            maxHealthChance = 0.4
        } else {
            switch depth {
            case 0, 1, 2, 3, 4:
                maxHealthChance = 1.5
            case 5, 6, 7, 8:
                maxHealthChance = 0.5
            default:
                maxHealthChance =  1
            }
        }
    }

    var healingPotionMultipler = Float(1)
    switch depth {
    case 0, 1, 2:
        if currentHp < originalHp/4 {
            healingPotionMultipler = 2
        } else if currentHp < originalHp/3 {
            healingPotionMultipler = 1.75
        } else if currentHp < originalHp/2 {
            healingPotionMultipler = 1.65
        } else if currentHp < originalHp/4 * 3 {
            healingPotionMultipler = 1.5
        } else if currentHp < originalHp/6 * 5 {
            healingPotionMultipler = 1.25
        } else {
            healingPotionMultipler = 1
        }
    case 3, 4, 5:
        if currentHp < originalHp/4 {
            healingPotionMultipler = 2
        } else if currentHp < originalHp/3 {
            healingPotionMultipler = 1.75
        } else if currentHp < originalHp/2 {
            healingPotionMultipler = 1.65
        } else if currentHp < originalHp/4 * 3 {
            healingPotionMultipler = 1.5
        } else if currentHp < originalHp/6 * 5 {
            healingPotionMultipler = 1.25
        } else {
            healingPotionMultipler = 1
        }
    case 6, 7, 8:
        if currentHp < originalHp/4 {
            healingPotionMultipler = 2
        } else if currentHp < originalHp/3 {
            healingPotionMultipler = 1.75
        } else if currentHp < originalHp/2 {
            healingPotionMultipler = 1.65
        } else if currentHp < originalHp/4 * 3 {
            healingPotionMultipler = 1.5
        } else if currentHp < originalHp/6 * 5 {
            healingPotionMultipler = 1.25
        } else {
            healingPotionMultipler = 1
        }
        
    default:
        break

    }
    
    
    var chanceModifier = Float(1)
    if offerType == .lesserHeal || offerType == .greaterHeal {
        chanceModifier = healingPotionMultipler
    } else {
        // + max health
        chanceModifier = maxHealthChance
    }
    
    // change offer chances based on what we offered last round
    for lastOffer in lastLevelOffers ?? [] {
        switch (lastOffer.type, offerType) {
            
        // offered
        case (.lesserHeal, .lesserHeal):
            chanceModifier *= 0.5
        case (.lesserHeal, .greaterHeal):
            chanceModifier *= 2
        case (.lesserHeal, .plusOneMaxHealth):
            chanceModifier *= 2
        case (.lesserHeal, .plusTwoMaxHealth):
            chanceModifier *= 2
            
        case (.greaterHeal, .greaterHeal):
            chanceModifier *= 0.5
        case (.greaterHeal, .lesserHeal):
            chanceModifier *= 2
        case (.greaterHeal, .plusOneMaxHealth):
            chanceModifier *= 2
        case (.greaterHeal, .plusTwoMaxHealth):
            chanceModifier *= 2
            
        case (.plusOneMaxHealth, .plusOneMaxHealth):
            chanceModifier *= 0.5
        case (.plusOneMaxHealth, .plusTwoMaxHealth):
            chanceModifier *= 2
        case (.plusOneMaxHealth, .lesserHeal):
            chanceModifier *= 2
        case (.plusOneMaxHealth, .greaterHeal):
            chanceModifier *= 2
            
        case (.plusTwoMaxHealth, .plusTwoMaxHealth):
            chanceModifier *= 0.5
        case (.plusTwoMaxHealth, .plusOneMaxHealth):
            chanceModifier *= 2
        case (.plusTwoMaxHealth, .lesserHeal):
            chanceModifier *= 2
        case (.plusTwoMaxHealth, .greaterHeal):
            chanceModifier *= 2
        default:
            chanceModifier *= 1
        }
    }
    
        
    return max(0.1, currentChance * chanceModifier)
}

func deltaChanceOfferUtilWealth(storeOfferChance: AnyChanceModel<StoreOffer>, playerData: EntityModel, allUnlockables: [Unlockable], allPastLevelOffers: [StoreOffer]?) -> Float {
    var delta = Float(1)
    
    // all the same offer items from this tier
    let sameTierOffersInPast = allPastLevelOffers?.filter({ $0.tier == storeOfferChance.thing.tier })
    
    // none of the offers were this
    let noneWereThisOffer = sameTierOffersInPast?.allSatisfy({ alreadyOffered in
        return alreadyOffered != storeOfferChance.thing
    }) ?? false
    

    if storeOfferChance.thing.type == .runeSlot {
        let numberUnlockRunes = allUnlockables.filter { $0.item.rune != nil }.filter( { $0.canAppearInRun }).count
        let numberOfPlayerRuneSlots = playerData.pickaxe?.runeSlots ?? 0
        
        // if you only have X potential runes then you dont need any more rune slots
        if numberUnlockRunes <= numberOfPlayerRuneSlots {
            delta = 0
        } else if numberOfPlayerRuneSlots == 4 {
            delta = 0
        } else if numberOfPlayerRuneSlots == 3 {
            delta = 0.1
        } else  if numberOfPlayerRuneSlots == 2 {
            delta = 0.25
        } else if numberOfPlayerRuneSlots == 1 {
            delta = 0.75
        } else {
            delta = 0.85
        }
    }
    else if noneWereThisOffer {
        // add
        delta = 3
    }
    else {
        delta -= 0.25
    }
    
    return max(0.01, delta * storeOfferChance.chance)
}

func deltaChanceOfferDodgeLuck(offerChance: AnyChanceModel<StoreOffer>, depth: Depth) -> Float {
    var deltaChance = Float(1)
    switch (depth, offerChance.thing.type) {
    case (0, .fourLeafClover), (1, .fourLeafClover), (2, .fourLeafClover):
        deltaChance = 2
    case (0, .horseshoe), (1, .horseshoe), (2, .horseshoe):
        deltaChance = 1
    case (0, .luckyCat), (1, .luckyCat), (2, .luckyCat):
        deltaChance = 0.5
    case (3, .fourLeafClover), (4, .fourLeafClover), (5, .fourLeafClover):
        deltaChance = 0.75
    case (3, .horseshoe), (4, .horseshoe), (5, .horseshoe):
        deltaChance = 1.25
    case (3, .luckyCat), (4, .luckyCat), (5, .luckyCat):
        deltaChance = 0.75
    case (6, .fourLeafClover), (7, .fourLeafClover), (8, .fourLeafClover):
        deltaChance = 0.5
    case (6, .horseshoe), (7, .horseshoe), (8, .horseshoe):
        deltaChance = 1
    case (6, .luckyCat), (7, .luckyCat), (8, .luckyCat):
        deltaChance = 1.5
        
    // dodge stuff
    case (0, .sandals), (1, .sandals), (2, .sandals):
        deltaChance = 2
    case (0, .runningShoes), (1, .runningShoes), (2, .runningShoes):
        deltaChance = 1
    case (0, .wingedBoots), (1, .wingedBoots), (2, .wingedBoots):
        deltaChance = 0.5
        
    case (3, .sandals), (4, .sandals), (5, .sandals):
        deltaChance = 0.75
    case (3, .runningShoes), (4, .runningShoes), (5, .runningShoes):
        deltaChance = 1.25
    case (3, .wingedBoots), (4, .wingedBoots), (5, .wingedBoots):
        deltaChance = 0.75
        
    case (6, .sandals), (7, .sandals), (8, .sandals):
        deltaChance = 0.5
    case (6, .runningShoes), (7, .runningShoes), (8, .runningShoes):
        deltaChance = 1.0
    case (6, .wingedBoots), (7, .wingedBoots), (8, .wingedBoots):
        deltaChance = 1.25

    default:
        break
    }
            
            
    return max(1, deltaChance * offerChance.chance)

}

func deltaChanceOfferRune(offerChance: AnyChanceModel<StoreOffer>, playerData: EntityModel) -> Float {
    guard let color = offerChance.thing.rune?.progressColor else { return offerChance.chance }
    guard let runes = playerData.pickaxe?.runes else { return offerChance.chance }
    let simiarRunes = Float(runes.map { $0.progressColor }.filter { $0 == color }.count)
    
    var deltaChance = Float(1)
    deltaChance -= (0.25) * simiarRunes
    
    if simiarRunes == 0 {
        deltaChance += 0.25
    }
    
    // remove it form the options with a negative chance
    if runes.contains(offerChance.thing.rune ?? .zero) {
        deltaChance = -1
    }
    
    return offerChance.chance * deltaChance
}

func deltaChanceForOffer(offerChances: [AnyChanceModel<StoreOffer>], recentlyPurchasedAndShouldSpawn: [StoreOffer], playerData: EntityModel, depth: Depth, tier: StoreOfferTier, lastLevelOffers: [StoreOffer]?, allPastLevelOffers: [StoreOffer]?, allUnlockables: [Unlockable]) -> [AnyChanceModel<StoreOffer>] {
    
    var newOfferChances: [AnyChanceModel<StoreOffer>] = []
    for offerChance in offerChances {
        var newChance = Float(1)
        switch StoreOfferBucket.bucket(for: offerChance.thing.type).type {
        case .health:
            newChance = deltaChanceOfferHealth(playerData: playerData, depth: depth, storeOffer: offerChance.thing, tier: tier, currentChance: offerChance.chance, lastLevelOffers: lastLevelOffers)
            
        case .util, .wealth:
            newChance = deltaChanceOfferUtilWealth(storeOfferChance: offerChance, playerData: playerData, allUnlockables: allUnlockables, allPastLevelOffers: allPastLevelOffers)
            
        case .dodgeLuck:
            newChance = deltaChanceOfferDodgeLuck(offerChance: offerChance, depth: depth)
            
        case .rune:
            newChance = deltaChanceOfferRune(offerChance: offerChance, playerData: playerData)
            
        }
        
        if recentlyPurchasedAndShouldSpawn.contains(offerChance.thing) {
            newChance *= 1000
        }
        
        if newChance > 0 {
            newOfferChances.append(.init(thing: offerChance.thing, chance: newChance))
        }
        
    }
    
    return newOfferChances
}

func tierItems(from buckets: [StoreOfferBucket], tier: StoreOfferTier, depth: Depth, allUnlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource, lastLevelOffers: [StoreOffer]?, allPastLevelOFfers: [StoreOffer]?) -> [StoreOffer] {
    var chosenOffers: [StoreOffer] = []
    
    for bucket in buckets {
        GameLogger.shared.log(prefix: "LevelModel", message: "Begin choosing offers form buckets \(bucket.type)")
        let availableBucketItems = allUnlockables
            .filter { unlockable in
                return unlockable.canAppearInRun
                && unlockable.item.tier == tier
                && bucket.contains(offerType: unlockable.item.type)
            }.map {
                $0.item
            }
        
        let recentlyPurchasedSpawnedItems = allUnlockables
            .filter { unlockable in
                return unlockable.canAppearInRun
                && unlockable.item.tier == tier
                && bucket.contains(offerType: unlockable.item.type)
                && unlockable.recentlyPurchasedAndHasntSpawnedYet
            }.map {
                $0.item
            }
        
        let availableOffersWithChance = baseChanceForOffers(potentialItems: availableBucketItems)
        let availbleOffersWithWeightChance = deltaChanceForOffer(offerChances: availableOffersWithChance, recentlyPurchasedAndShouldSpawn: recentlyPurchasedSpawnedItems, playerData: playerData, depth: depth, tier: tier, lastLevelOffers: lastLevelOffers, allPastLevelOffers: allPastLevelOFfers, allUnlockables: allUnlockables)
        
        #if DEBUG
        GameLogger.shared.log(prefix: "LevelModel", message: "---- Available items ---- ")
        for (idx, offer) in availableBucketItems.enumerated() {
            GameLogger.shared.log(prefix: "LevelModel", message: "(\(idx)) Type:\(offer.type) Tier:\(offer.tier)")
            if let baseChanceModel = availableOffersWithChance.filter({ $0.thing == offer }).first {
                GameLogger.shared.log(prefix: "LevelModel", message: "\tBase Chance: \(baseChanceModel.chance)")
            }
            if let weightedChanceModel = availbleOffersWithWeightChance.filter({ $0.thing == offer }).first {
                GameLogger.shared.log(prefix: "LevelModel", message: "\tWeighted Chance: \(weightedChanceModel.chance)")
            }
        }
        #endif
        
        
        if let random = randomSource.chooseElementWithChance(availbleOffersWithWeightChance).map( { $0.thing }) {
            GameLogger.shared.log(prefix: "LevelModel", message: "Chosen offer: \(random.type).\(random.tier)")
            chosenOffers.append(random)
        }
        
        
    }
    
    return chosenOffers
}

func createTotalPillarGoalAmount(totalPillars: Int, depth: Int, randomSource: GKLinearCongruentialRandomSource, previousLevelGoals: [LevelGoal]?) -> Int {
    
    var totalPillarAmount = Float(totalPillars)
    
    switch depth {
    case 0, 1, 2:
        totalPillarAmount *= 0
        
    case 3, 4:
        let chance1 = AnyChanceModel<Float>(thing: 0.6, chance: 33)
        let chance2 = AnyChanceModel<Float>(thing: 0.7, chance: 33)
        let chance3 = AnyChanceModel<Float>(thing: 0.8, chance: 33)
        
        if let chosen = randomSource.chooseElementWithChance([chance1, chance2, chance3]) {
            totalPillarAmount *= chosen.thing
        }
        
    case 5, 6, 7, 8:
        let chance1 = AnyChanceModel<Float>(thing: 0.6, chance: 25)
        let chance2 = AnyChanceModel<Float>(thing: 0.7, chance: 25)
        let chance3 = AnyChanceModel<Float>(thing: 0.8, chance: 25)
        let chance4 = AnyChanceModel<Float>(thing: 0.9, chance: 25)
        
        if let chosen = randomSource.chooseElementWithChance([chance1, chance2, chance3, chance4]) {
            totalPillarAmount *= chosen.thing
        }
        
    case bossLevelDepthNumber:
        totalPillarAmount *= 0
        
    default:
        totalPillarAmount *= 0
    }
    
    return Int(totalPillarAmount)

}
