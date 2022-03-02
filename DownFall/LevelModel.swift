//
//  LevelModel.swift
//  DownFall
//
//  Created by William Katz on 12/25/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit
import GameplayKit


enum EncasementSize {
    case small
    case medium
    case large
}

func randomRune(playerData: EntityModel, startingUnlockables: [Unlockable], otherUnlockables: [Unlockable], avoid: (Rune) -> Bool = { _ in false }) -> Rune? {
    // pool of items
    var allUnlockables = Set<Unlockable>(startingUnlockables)
    allUnlockables.formUnion(otherUnlockables)
    
    let potentialOffers = allUnlockables
        .filter({ $0.canAppearInRun })
        .filter({ $0.item.rune != nil })
    
    
    var newOffer: StoreOffer? = potentialOffers.randomElement()?.item
    
    var maxTries: Int = 30
    
    while maxTries > 0 {
        if let pickace = playerData.pickaxe,
           // player already has
           // or we want to avoid the new rune executing this branch chooses a new offer
           pickace.runes.contains(where: { playerRune in
               if let newRune = newOffer?.rune {
                   if avoid(newRune) {
                       return true
                   } else {
                       return playerRune == newRune
                   }
               } else {
                   return true
               }
           }) {
            newOffer = potentialOffers.randomElement()?.item
        } else if let rune = newOffer?.rune {
            return rune
        }
        maxTries -= 1
    }
    
    return newOffer?.rune
}


fileprivate func baseChanceEncasementOffers(depth: Depth, playerData: EntityModel, startingUnlockables: [Unlockable], otherUnlockables: [Unlockable], randomSource: GKLinearCongruentialRandomSource, lastLevelFeatures: LevelFeatures?) -> [ChanceModel] {
    /// Create random offers
    // tier 1 health
    let randomTier1HealthOption = randomItem(playerData: playerData, tier: 1, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) { offer in
        return offer.type.isAHealingOption
    }
    // tier 1 health
    let randomTier1NonHealthOption = randomItem(playerData: playerData, tier: 1, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) { offer in
        return !offer.type.isAHealingOption
    }
    
    // tier 2 health
    let randomTier2HealthOption = randomItem(playerData: playerData, tier: 1, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) { offer in
        return offer.type.isAHealingOption
    }
    // tier 2 non-health
    let randomTier2NonHealthOption = randomItem(playerData: playerData, tier: 1, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) { offer in
        return !offer.type.isAHealingOption
    }
    
    // rune
    var randomRune1: Rune = .rune(for: .getSwifty)
    if let rune = randomRune(playerData: playerData, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) {
        randomRune1 = rune
    }
    
    var randomRune2: Rune = .rune(for: .fireball)
    if let rune = randomRune(playerData: playerData, startingUnlockables: startingUnlockables, otherUnlockables: otherUnlockables) {
        randomRune2 = rune
    }
    
    // health and items
    let tier1HealthOption: TileType = .offer(.offer(type: randomTier1HealthOption.type, tier: 3))
    let tier1NonHealthOption: TileType = .offer(.offer(type: randomTier1NonHealthOption.type, tier: 3))
    let tier2HealthOption: TileType = .offer(.offer(type: randomTier2HealthOption.type, tier: 3))
    let tier2NonHealthOption: TileType = .offer(.offer(type: randomTier2NonHealthOption.type, tier: 3))
    
    // just runes and slots
    let rune1Type: TileType = .offer(.offer(type: .rune(.rune(for: randomRune1.type)), tier: 3))
    let rune2Type: TileType = .offer(.offer(type: .rune(.rune(for: randomRune2.type)), tier: 3))
    let runeSlot: TileType = .offer(.offer(type: .runeSlot, tier: 3))
    
    // monster types
    let batMonsterType: TileType = .monster(EntityModel.monsterWithType(.bat))
    let hardMonsterType: TileType = .monster(EntityModel.monsterWithType(randomSource.nextBool() ? .bat : .sally))
    let mediumMonsterType: TileType = .monster(EntityModel.monsterWithType(randomSource.nextBool() ? .dragon : .alamo))
    let easyMonsterType: TileType = .monster(EntityModel.monsterWithType(randomSource.nextBool() ? .rat : .alamo))
    
    // exits
    let blockExit = TileType.exit(blocked: true)
    

    switch depth {
    case 0, 1, 2:
        return []
    case 3:
        let baseChance: Float = 25
        let randomHealthChance: ChanceModel = .init(tileType: tier1HealthOption, chance: baseChance)
        let randomNonHealthChance: ChanceModel = .init(tileType: tier1NonHealthOption, chance: baseChance)
        let mediumMonsterChance: ChanceModel = .init(tileType: mediumMonsterType, chance: baseChance)
        let easyMonsterChance: ChanceModel = .init(tileType: easyMonsterType, chance: 20)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 5)
        
        let chanceModel: [ChanceModel] = [
            randomHealthChance, randomNonHealthChance, mediumMonsterChance, easyMonsterChance, exitBlockedChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel
        
    case 4:
        
        let tier1Health: ChanceModel = .init(tileType: tier1HealthOption, chance: 20)
        let tier1NonHealth: ChanceModel = .init(tileType: tier1NonHealthOption, chance: 20)
        let easyMonsterChance: ChanceModel = .init(tileType: easyMonsterType, chance: 15)
        let mediumMonsterChance: ChanceModel = .init(tileType: mediumMonsterType, chance: 25)
        let hardMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 10)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 10)
        
        let chanceModel: [ChanceModel] = [
            tier1Health, tier1NonHealth, hardMonsterChance, mediumMonsterChance, easyMonsterChance, exitBlockedChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel

    case 5:
        let tier1Health: ChanceModel = .init(tileType: tier1HealthOption, chance: 15)
        let tier1NonHealth: ChanceModel = .init(tileType: tier1NonHealthOption, chance: 15)
        let tier2Health: ChanceModel = .init(tileType: tier2HealthOption, chance: 5)
        let easyMonsterChance: ChanceModel = .init(tileType: easyMonsterType, chance: 10)
        let mediumMonsterChance: ChanceModel = .init(tileType: mediumMonsterType, chance: 15)
        let hardMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 25)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 10)
        let runeChance: ChanceModel = .init(tileType: rune1Type, chance: 5)
        
        let chanceModel: [ChanceModel] = [
            tier1Health, tier1NonHealth,
            tier2Health,
            easyMonsterChance, mediumMonsterChance, hardMonsterChance,
            exitBlockedChance,
            runeChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel

        
    case 6:
        let tier1Health: ChanceModel = .init(tileType: tier1HealthOption, chance: 5)
        let tier1NonHealth: ChanceModel = .init(tileType: tier1NonHealthOption, chance: 5)
        let tier2Health: ChanceModel = .init(tileType: tier2HealthOption, chance: 10)
        let tier2NonHealth: ChanceModel = .init(tileType: tier2NonHealthOption, chance: 10)
        let mediumMonsterChance: ChanceModel = .init(tileType: mediumMonsterType, chance: 5)
        let hardMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 15)
        let batMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 25)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 25)
        let runeChance: ChanceModel = .init(tileType: rune1Type, chance: 10)
        
        let chanceModel: [ChanceModel] = [
            tier1Health, tier1NonHealth,
            tier2Health, tier2NonHealth,
            mediumMonsterChance, hardMonsterChance, batMonsterChance,
            exitBlockedChance,
            runeChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel
        
    case 7:
        let tier2Health: ChanceModel = .init(tileType: tier2HealthOption, chance: 10)
        let tier2NonHealth: ChanceModel = .init(tileType: tier2NonHealthOption, chance: 5)
        let hardMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 10)
        let batMonsterChance: ChanceModel = .init(tileType: batMonsterType, chance: 30)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 40)
        let runeChance: ChanceModel = .init(tileType: rune1Type, chance: 5)
        
        let chanceModel: [ChanceModel] = [
            tier2Health, tier2NonHealth,
            hardMonsterChance, batMonsterChance,
            exitBlockedChance,
            runeChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel
        
    case 8:
        let tier2Health: ChanceModel = .init(tileType: tier2HealthOption, chance: 15)
        let tier2NonHealth: ChanceModel = .init(tileType: tier2NonHealthOption, chance: 10)
        let hardMonsterChance: ChanceModel = .init(tileType: hardMonsterType, chance: 10)
        let batMonsterChance: ChanceModel = .init(tileType: batMonsterType, chance: 25)
        let exitBlockedChance: ChanceModel = .init(tileType: blockExit, chance: 30)
        let runeChance: ChanceModel = .init(tileType: rune1Type, chance: 5)
        let runeSlotChance: ChanceModel = .init(tileType: runeSlot, chance: 5)
        
        let chanceModel: [ChanceModel] = [
            tier2Health, tier2NonHealth,
            hardMonsterChance, batMonsterChance,
            exitBlockedChance,
            runeChance, runeSlotChance
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel
        
    case bossLevelDepthNumber:
        let tier1Health: ChanceModel = .init(tileType: tier1HealthOption, chance: 16)
        let tier2Health: ChanceModel = .init(tileType: tier2HealthOption, chance: 16)
        let batMonsterChance1: ChanceModel = .init(tileType: batMonsterType, chance: 33)
        let batMonsterChance2: ChanceModel = .init(tileType: batMonsterType, chance: 33)
        
        let chanceModel: [ChanceModel] = [
            tier1Health, tier2Health,
            batMonsterChance1, batMonsterChance2
        ].map {
            chanceDeltaEncasementOffer(encasedOfferChanceModel: $0, playerData: playerData, lastLevelFeatures: lastLevelFeatures)
        }
        
        return chanceModel

        
    default:
        return[]
    }
}



private func randomItem(playerData: EntityModel, tier: StoreOfferTier, startingUnlockables: [Unlockable], otherUnlockables: [Unlockable], optionalCheck: ((StoreOffer) -> Bool)?) -> StoreOffer {
    // pool of items
    var allUnlockables = Set<Unlockable>(startingUnlockables)
    allUnlockables.formUnion(otherUnlockables)
    
    let newOffer: StoreOffer? = allUnlockables
        .filter({ $0.canAppearInRun })
        .filter({ $0.item.rune == nil })
        .filter({ $0.item.tier == tier })
        .filter({ optionalCheck?($0.item) ?? true })
        .randomElement()?.item
    
    return newOffer ?? .zero
}


fileprivate func baseChanceEncasementSize(depth: Depth) -> [AnyChanceModel<[EncasementSize]>] {
    switch depth {
    case 0, 1, 2:
        return []
    case 3:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 65)
        let smallSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small], chance: 30)
        let mediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium], chance: 5)
        
        return [smallSizeChance, mediumSizeChance, justPillarsChance]
    case 4:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 30)
        let smallSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small], chance: 35)
        let mediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium], chance: 25)
        let largeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large], chance: 5)
        let smallSmallSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small, .small], chance: 5)
        
        return [smallSizeChance, mediumSizeChance, justPillarsChance, largeSizeChance, smallSmallSizeChance]
        
    case 5:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 20)
        let smallSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small], chance: 15)
        let mediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium], chance: 35)
        let largeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large], chance: 15)
        let smallSmallSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small, .small], chance: 5)
        let smallMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small, .medium], chance: 10)
        
        return [smallSizeChance, mediumSizeChance, justPillarsChance, largeSizeChance, smallMediumSizeChance, smallSmallSizeChance]
        
    case 6:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 15)
        let mediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium], chance: 25)
        let largeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large], chance: 30)
        let mediumMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium, .medium], chance: 15)
        let smallLargeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small, .large], chance: 5)
        let largeMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large, .medium], chance: 5)
        
        return [justPillarsChance, mediumSizeChance, largeSizeChance, mediumMediumSizeChance, smallLargeSizeChance, largeMediumSizeChance]

    case 7:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 10)
        let mediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium], chance: 5)
        let largeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large], chance: 30)
        let mediumMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium, .medium], chance: 25)
        let smallLargeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.small, .large], chance: 20)
        let largeMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large, .medium], chance: 15)
        
        return [justPillarsChance, mediumSizeChance, largeSizeChance, mediumMediumSizeChance, smallLargeSizeChance, largeMediumSizeChance]
        
    case 8:
        let justPillarsChance = AnyChanceModel<[EncasementSize]>.init(thing: [], chance: 10)
        let largeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large], chance: 20)
        let mediumMediumSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium, .medium], chance: 20)
        let mediumLargeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.medium, .large], chance: 25)
        let largeLargeSizeChance = AnyChanceModel<[EncasementSize]>.init(thing: [.large, .large], chance: 25)
        
        return [justPillarsChance, largeSizeChance, mediumMediumSizeChance, mediumLargeSizeChance, largeLargeSizeChance]

    case bossLevelDepthNumber:
        return [AnyChanceModel<[EncasementSize]>.init(thing: [.large, .large], chance: 100)]
        
    default:
        return[]
    }
}


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
            return -5
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

func chanceDeltaLevelGoal(propsedGoalChanceModel: AnyChanceModel<LevelGoal>, lastLevelGoals: [LevelGoal]) -> AnyChanceModel<LevelGoal> {
    guard !lastLevelGoals.isEmpty else { return propsedGoalChanceModel }
    
    
    let delta = lastLevelGoals.reduce(Float(0), { prevDeltaTotal, lastLevelGoal in
        var totalDelta: Float = 0
        switch (lastLevelGoal.tileType, propsedGoalChanceModel.thing.tileType) {
        case (.pillar, .pillar):
            totalDelta -= propsedGoalChanceModel.chance / 2
            
        case let (.rock(lhsColor, _, _), .rock(rhsColor, _,  _)):
            switch (lhsColor, rhsColor) {
            case (.brown, .brown), (.red, .red), (.blue, .blue), (.purple, .purple):
                totalDelta -= propsedGoalChanceModel.chance / 2
            case (_, .brown):
                totalDelta += propsedGoalChanceModel.chance * 1.5
            default:
                break
            }
            
        case (.monster, .monster):
            totalDelta -= propsedGoalChanceModel.chance / 2
            
        default:
            break
            
        }
        
        return prevDeltaTotal + totalDelta
        
    })
    
    return AnyChanceModel(thing: propsedGoalChanceModel.thing, chance: propsedGoalChanceModel.chance + delta)
    
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
            totalDelta -= 15
        case (.monster, .exit):
            totalDelta -= 5
        case (.monster, .item), (.monster, .offer):
            totalDelta += 5
            
            // exit was the old offer
        case (.exit, .monster):
            totalDelta -= 10
        case (.exit, .exit):
            totalDelta -= 10
        case (.exit, .item), (.exit, .offer):
            totalDelta += 5
            
            // offered an rune or item last level?
        case (.offer, .exit):
            totalDelta += 5
        case (.offer, .monster):
            totalDelta += 0
        case (.offer, .offer):
            totalDelta -= 4
        case (.offer, .item):
            totalDelta -= 4
            
            // got offered gems last level?
        case (.item, .exit):
            totalDelta += 15
        case (.item, .monster):
            totalDelta += 15
        case (.item, .item):
            totalDelta -= 20
        case (.item, .offer):
            totalDelta -= 0
            
        case (_, _):
            totalDelta += 0
        }
        
        return prev + totalDelta
    })
    totalDelta += delta
    
    return ChanceModel(tileType: encasedOfferChanceModel.tileType, chance: max(1, encasedOfferChanceModel.chance + totalDelta))
}


class Level: Codable, Hashable {
    
    static func ==(_ lhs: Level, _ rhs: Level) -> Bool {
        return lhs.depth == rhs.depth && lhs.randomSeed == rhs.randomSeed
    }
    
    static let zero = Level(depth: 0, monsterTypeRatio: [:], monsterCountStart: 0, maxMonsterOnBoardRatio: 0.0, boardSize: 0, tileTypeChances: TileTypeChanceModel(chances: [.empty: 1]), maxSpawnGems: 0, goalProgress: [], savedBossPhase: nil, gemsSpawned: 0, monsterSpawnTurnTimer: 0, startingUnlockables: [], otherUnlockables: [], randomSeed: 12345, isTutorial: false, runModel: nil)
    
    let depth: Depth
    let monsterTypeRatio: [EntityModel.EntityType: RangeModel]
    let monsterCountStart: Int
    let maxMonsterOnBoardRatio: Double
    let boardSize: Int
    let tileTypeChances: TileTypeChanceModel
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
    
    public var levelFeatures: LevelFeatures?
    public var levelStartTiles: [LevelStartTiles] {
        if let all = levelFeatures?.levelStartTiles {
            return all
        } else {
            return  []
        }
    }
    
    public var offers: [StoreOffer] = []
    
    public var goals: [LevelGoal] = []
    
    
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
            
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 30)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 4)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 4:
            let monsterAmount = 5
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 35)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
        case 5:
            let monsterAmount = 7
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
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 45)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: totalPillarAmount)
            
            let rockGoalChance = AnyChanceModel(thing: rockGoal, chance: 33)
            let monsterGoalChance = AnyChanceModel(thing: monsterGoal, chance: 33)
            let pillarGoalChance = AnyChanceModel(thing: pillarGoal, chance: 33)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance])
            
            
        case 7:
            let monsterAmount = 12
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 50)
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
            
        case 8:
            let monsterAmount = 15
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 55)
            let brownRockGoal = randomRockGoal([.brown], amount: 6)
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
            let brownGoalChance = AnyChanceModel(thing: brownRockGoal, chance: 15)
            
            goalChances.append(contentsOf: [rockGoalChance, monsterGoalChance, pillarGoalChance, brownGoalChance])
            
        case 9:
            let monsterAmount = 20
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 60)
            let brownRockGoal = randomRockGoal([.brown], amount: 12)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: (totalPillarAmount))
            if offeredGemAmount > 0 {
                let gemGoal = LevelGoal.gemGoal(amount: offeredGemAmount)
                let gemGoalChance = AnyChanceModel(thing: gemGoal, chance: 100)
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
            let deltaHealthChance =  chanceDeltaOfferHealth(playerData: playerData)
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
            //            let deltaNonRuneRelatedOptionChance =  chanceDeltaOfferHealth(playerData: <#T##EntityModel#>)
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
            let offerRuneSlotChance =  chanceDeltaOfferRuneSlot(playerData: playerData, currentChance: 25, lastLevelOfferings: lastLevelOffers)
            let runeSlotOffer = StoreOffer.offer(type: .runeSlot, tier: 2)
            let offerRuneSlotChanceModel: AnyChanceModel = .init(thing: runeSlotOffer, chance: offerRuneSlotChance)
            
            potentialItems.append(offerRuneSlotChanceModel)
            
            // create a rune offer 1
            let offerRuneChance =  chanceDeltaOfferRune(playerData: playerData, currentChance: 25, lastLevelOfferings: lastLevelOffers)
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
                let offerRuneTwoChance =  chanceDeltaOfferRune(playerData: playerData, currentChance: 5, lastLevelOfferings: lastLevelOffers)
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

private func encasementsOptions(depth: Depth, size: EncasementSize) -> [EncasementCoords] {
    switch depth {
    case 0, 1, 2:
        return []
    case 3, 4:
        // board size = 8
        // no mediums in the board size 8 realm
        if size == .small {
            let encasementOption1: EncasementCoords = .init(middleTile: TileCoord(0, 0), outerTiles: [TileCoord(1, 0), TileCoord(0, 1)])
            let encasementOption2: EncasementCoords = .init(middleTile: TileCoord(7, 0), outerTiles: [TileCoord(6, 0), TileCoord(7, 1)])
            let encasementOption3: EncasementCoords = .init(middleTile: TileCoord(7, 7), outerTiles: [TileCoord(7, 6), TileCoord(6, 7)])
            let encasementOption4: EncasementCoords = .init(middleTile: TileCoord(0, 7), outerTiles: [TileCoord(0, 6), TileCoord(1, 7)])
            
            return [encasementOption1, encasementOption2, encasementOption3, encasementOption4]
        } else if size == .medium {
            let mediumCornerOption1: EncasementCoords = .init(middleTile: TileCoord(0, 0), outerTiles: [TileCoord(2, 0), TileCoord(1, 1), TileCoord(0, 2)])
            let mediumCornerOption2: EncasementCoords = .init(middleTile: TileCoord(7, 0), outerTiles: [TileCoord(5, 0), TileCoord(6, 1), TileCoord(7, 2)])
            let mediumCornerOption3: EncasementCoords = .init(middleTile: TileCoord(7, 7), outerTiles: [TileCoord(7, 5), TileCoord(6, 6), TileCoord(5, 7)])
            let mediumCornerOption4: EncasementCoords = .init(middleTile: TileCoord(0, 7), outerTiles: [TileCoord(0, 5), TileCoord(1, 6), TileCoord(2, 7)])
            return [mediumCornerOption1, mediumCornerOption2, mediumCornerOption3, mediumCornerOption4]
        }
        else if size == .large {
            let encasementOption1: EncasementCoords = .init(middleTile: TileCoord(2, 2), outerTiles: [TileCoord(2, 1), TileCoord(1, 2), TileCoord(2, 3), TileCoord(3, 2)])
            let encasementOption2: EncasementCoords = .init(middleTile: TileCoord(5, 2), outerTiles: [TileCoord(4, 2), TileCoord(5, 1), TileCoord(6, 2), TileCoord(5, 3)])
            let encasementOption3: EncasementCoords = .init(middleTile: TileCoord(5, 5), outerTiles: [TileCoord(4, 5), TileCoord(5, 4), TileCoord(6, 5), TileCoord(5, 6)])
            let encasementOption4: EncasementCoords = .init(middleTile: TileCoord(2, 5), outerTiles: [TileCoord(2, 4), TileCoord(1, 5), TileCoord(3, 5), TileCoord(2, 6)])
            
            return [encasementOption1, encasementOption2, encasementOption3, encasementOption4]
        }
        
    case 5..<bossLevelDepthNumber:
        if size == .small {
            let cornerOption1: EncasementCoords = .init(middleTile: TileCoord(0, 0), outerTiles: [TileCoord(1, 0), TileCoord(0, 1)])
            let cornerOption2: EncasementCoords = .init(middleTile: TileCoord(8, 0), outerTiles: [TileCoord(7, 0), TileCoord(8, 1)])
            let cornerOption3: EncasementCoords = .init(middleTile: TileCoord(8, 8), outerTiles: [TileCoord(8, 7), TileCoord(7, 8)])
            let cornerOption4: EncasementCoords = .init(middleTile: TileCoord(0, 8), outerTiles: [TileCoord(0, 7), TileCoord(1, 8)])
            return  [cornerOption1, cornerOption2, cornerOption3, cornerOption4]
        }
        else if size == .medium {
            let sideOption1: EncasementCoords = .init(middleTile: TileCoord(4, 0), outerTiles: [TileCoord(3, 0), TileCoord(5, 0), TileCoord(4, 1)])
            let sideOption4: EncasementCoords = .init(middleTile: TileCoord(0, 4), outerTiles: [TileCoord(0, 3), TileCoord(0, 5), TileCoord(1, 4)])
            let sideOption2: EncasementCoords = .init(middleTile: TileCoord(8, 4), outerTiles: [TileCoord(8, 3), TileCoord(8, 5), TileCoord(7, 4)])
            let sideOption3: EncasementCoords = .init(middleTile: TileCoord(4, 8), outerTiles: [TileCoord(5, 8), TileCoord(3, 8), TileCoord(4, 7)])
            return [sideOption1, sideOption2, sideOption3, sideOption4]
        } else if size == .large {
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
            return [encasementOption1, encasementOption2, encasementOption3, encasementOption4, encasementOption5, encasementOption6, encasementOption7, encasementOption8, encasementOption9]
        }
    
    case bossLevelDepthNumber:
        let encasement1 = EncasementCoords(middleTile: TileCoord(6, 4), outerTiles: [TileCoord(7, 4), TileCoord(5, 4), TileCoord(6, 3), TileCoord(6, 5)])
        let encasement2 = EncasementCoords(middleTile: TileCoord(2, 4), outerTiles: [TileCoord(3, 4), TileCoord(1, 4), TileCoord(2, 3), TileCoord(2, 5)])

        return [encasement1, encasement2]
    default:
        break
        
    }
    return []
}


/// Call this with equal encasementChanceModel.count and encasementSizes.count
/// Call with no ecnasement chance model or no encasement sizes to just get normal pillars
private func potentialEncasementPillarCoords(depth: Int, randomSource: GKLinearCongruentialRandomSource, encasementChanceModel: [ChanceModel], encasementSizes: [EncasementSize]) -> (pillars: [LevelStartTiles], encasements: [LevelStartTiles]) {
    
    // early return if no encasements should be created
    if encasementChanceModel.isEmpty || encasementSizes.isEmpty {
        return (pillars: pillarsForDepth(depth: depth, randomSource: randomSource), encasements: [])
    }
    
    var pillarCoords: [LevelStartTiles] = []
    var mutableEncasementChanceModel = encasementChanceModel
    for size in encasementSizes {
        let choices = encasementsOptions(depth: depth, size: size)
        
        // avoid choosing encasement options that have a shared tile coord with already chosen encasement options
        if let chosenEncasement = randomSource.chooseElement(choices, avoidBlock: { potentialChoice in
            // when should we avoid?
            // when any element in pillar coords overlaps with any element with potential choice
            for coord in potentialChoice.allCoords {
                if pillarCoords.map( { $0.tileCoord }).contains(coord) {
                    return true
                }
            }
            return false
        }) {
            // create the pillars by matching up colors randomly
            pillarCoords.append(contentsOf: matchupPillarsRandomly(colors: ShiftShaft_Color.pillarCases, coordinatess: chosenEncasement.outerTiles))
            
            /// choose a random item/monster/exit/offer to throw into the middle tile
            if let randomTile = randomSource.chooseElementWithChance(mutableEncasementChanceModel)?.tileType {
                let encasedLevelStartTile = LevelStartTiles(tileType: randomTile, tileCoord: chosenEncasement.middleTile)
                pillarCoords.append(encasedLevelStartTile)
                
                /// dont choose this option again
                mutableEncasementChanceModel.removeFirst { chanceModel in
                    return chanceModel.tileType == randomTile
                }
            }
        }
    }
    
    return (pillars: [], encasements: pillarCoords)
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

fileprivate func pillarsForDepth(depth: Depth, randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
    switch depth {
    case 0, 1, 2: return []
    case 3, 4: return lowLevelPillars(randomSource: randomSource)
    case 5, 6: return midLevelPillars(randomSource: randomSource)
    case 7, 8, 9: return highLevelPillars(randomSource: randomSource)
    default: return []
    }
}

fileprivate func lowLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
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


fileprivate func midLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
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

fileprivate func highLevelPillars(randomSource: GKLinearCongruentialRandomSource, avoid: [LevelStartTiles] = []) -> [LevelStartTiles] {
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
