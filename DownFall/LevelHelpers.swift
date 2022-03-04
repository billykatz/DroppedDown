//
//  LevelHelpers.swift
//  DownFall
//
//  Created by Billy on 3/3/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import GameplayKit

// MARK: Updating Chance

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


func baseChanceEncasementOffers(depth: Depth, playerData: EntityModel, startingUnlockables: [Unlockable], otherUnlockables: [Unlockable], randomSource: GKLinearCongruentialRandomSource, lastLevelFeatures: LevelFeatures?) -> [ChanceModel] {
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


func baseChanceEncasementSize(depth: Depth) -> [AnyChanceModel<[EncasementSize]>] {
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


func chanceDeltaOfferHealth(playerData: EntityModel, currentChance: Float, modifier: Float) -> Float {
    var delta: Float = 1
    let currHealth = Float(playerData.hp)
    let maxHealth = Float(playerData.originalHp)
    if currHealth <= maxHealth / 4  {
        delta = 3
    }
    else if currHealth <= maxHealth / 3 {
        delta = 2
    } else if currHealth <= maxHealth / 2  {
        delta = 1.5
    } else if currHealth == maxHealth {
        delta = 0.75
    } else {
        delta = 1
    }
    
    return delta * currentChance * modifier
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
    var delta: Float = 1
    if Double(playerData.hp) <= Double(playerData.originalHp) / 4  {
        delta = 15
    }
    else if Double(playerData.hp) <= Double(playerData.originalHp) / 3 {
        delta = 10
    } else if Double(playerData.hp) <= Double(playerData.originalHp) / 2  {
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




// MARK: - Normal Pillar Stuff

func pillarsForDepth(depth: Depth, randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
   switch depth {
   case 0, 1, 2: return []
   case 3, 4: return lowLevelPillars(randomSource: randomSource)
   case 5, 6: return midLevelPillars(randomSource: randomSource)
   case 7, 8, 9: return highLevelPillars(randomSource: randomSource)
   default: return []
   }
}


func lowLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
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


func midLevelPillars(randomSource: GKLinearCongruentialRandomSource) -> [LevelStartTiles] {
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

func highLevelPillars(randomSource: GKLinearCongruentialRandomSource, avoid: [LevelStartTiles] = []) -> [LevelStartTiles] {
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

func matchupPillarsRandomly(colors: [ShiftShaft_Color] = ShiftShaft_Color.pillarCases, coordinatess: [TileCoord]) -> [LevelStartTiles] {
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


// MARK: ENCASEMENT 
func encasementsOptions(depth: Depth, size: EncasementSize) -> [EncasementCoords] {
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
func potentialEncasementPillarCoords(depth: Int, randomSource: GKLinearCongruentialRandomSource, encasementChanceModel: [ChanceModel], encasementSizes: [EncasementSize]) -> (pillars: [LevelStartTiles], encasements: [LevelStartTiles]) {
    
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
