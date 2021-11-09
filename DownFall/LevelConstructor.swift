//
//  LevelConstructor.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import GameplayKit

typealias Depth = Int

struct LevelConstructor {
    
    static func buildLevel(depth: Int, randomSource: GKLinearCongruentialRandomSource, playerData: EntityModel, unlockables: [Unlockable], startingUnlockables: [Unlockable], isTutorial: Bool) -> Level {
        let pillars = pillars(depth: depth, randomSource: randomSource)
        let gemsAtDepth = maxSpawnGems(depth: depth)
        
        return
            Level(
                depth: depth,
                monsterTypeRatio: monsterTypes(depth: depth),
                monsterCountStart: monsterCountStart(depth: depth),
                maxMonsterOnBoardRatio: maxMonsterOnBoardRatio(depth: depth),
                boardSize: boardSize(depth: depth),
                tileTypeChances: availableRocksPerLevel(depth: depth),
                pillarCoordinates: pillars,
                goals: levelGoal(depth: depth, pillars: pillars, gemAtDepth: gemsAtDepth, randomSource: randomSource, isTutorial: isTutorial),
                maxSpawnGems: gemsAtDepth,
                goalProgress: [],
                potentialItems: potentialItems(depth: depth, unlockables: unlockables, startingUnlockables: startingUnlockables, playerData: playerData, randomSource: randomSource, isTutorial: isTutorial)
            )
    }
    
    static func potentialItems(depth: Depth, unlockables: [Unlockable], startingUnlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource, isTutorial: Bool) -> [StoreOffer] {
        
        if depth == 0 && isTutorial {
            return [
                StoreOffer.offer(type: .gems(amount: 15), tier: 1),
                StoreOffer.offer(type: .plusOneMaxHealth, tier: 1)
            ]
        }
        
        var offers = [StoreOffer]()
        var allUnlockables = unlockables
        allUnlockables.append(contentsOf: startingUnlockables)
        offers.append(contentsOf: tierItems(tier: 1, depth: depth, unlockables: allUnlockables, playerData: playerData, randomSource: randomSource))
        offers.append(contentsOf: tierItems(tier: 2, depth: depth, unlockables: allUnlockables, playerData: playerData, randomSource: randomSource))
        
        return offers
        
    }
    
    /// Item pool rewards
    /// [✅] - At least 1 offer must be a way to heal
    /// [✅] - If the player has an empty rune slot then increase the chance of offering a rune
    /// [✅] - first goal: offer health and something else
    /// [✅] - second goal: offer non-health and non-health
    /// [✅] - if the player has a full pickaxe then increase chance of offering a rune slot
    /// [push] - if a player just bought an item then increase the chance of it showing up
    ///
    /// For this release
    /// the first tier always offers health and something else in that tier.
    ///
    
    static func tierItems(tier: StoreOfferTier, depth: Depth, unlockables: [Unlockable], playerData: EntityModel, randomSource: GKLinearCongruentialRandomSource) -> [StoreOffer] {
        
        if tier == 1 {
            // always offer at least 1 heal
            let healingOptions =
                unlockables
                .filter { unlockable in
                    return unlockable.canAppearInRun && unlockable.item.tier == tier && (unlockable.item.type == .lesserHeal || unlockable.item.type == .greaterHeal)
                }
            
            guard let healingOption = healingOptions.randomElement() else { preconditionFailure("There must always be at least 1 unlockable at tier 1 for healing")}
            
//            let otherOptions = [
//                unlockables
//                .filter { unlockable in
//                    return !healingOptions.contains(unlockable) && unlockable.canAppearInRun && unlockable.item.tier == tier
//                }
//
//            guard let otherOption = otherOptions.randomElement() else {  preconditionFailure("There must always be at least 1 other unlockable at tier 1 that isn't healing")}

//            return [healingOption.item, otherOption.
            #warning("Fix for release")
            return [healingOption.item, StoreOffer.offer(type: .rune(.rune(for: .bubbleUp)), tier: 1)]
        }
        else if tier == 2 {
            let playerHasFullPickaxe = playerData.pickaxe?.isAtMaxCapacity() ?? false
            
            let chanceRune: Int
            let chanceRuneSlot: Int
            if playerHasFullPickaxe {
                chanceRune = 20
                chanceRuneSlot = 50
            } else {
                chanceRune = 50
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
                    
                    guard let option = runeOptions.randomElement() else { continue }
                    
                    options.append(option)
                    
                } else if (randomNumber >= chanceRune && randomNumber < chanceRune + chanceRuneSlot && !offeredRuneSlotAlready) {
                    offeredRuneSlotAlready = true
                    
                    let runeSlotOptions = unlockables.filter { unlockable in
                        return unlockable.canAppearInRun && unlockable.item.tier == tier && unlockable.item.type == .runeSlot
                    }
                    
                    guard let option = runeSlotOptions.randomElement() else { continue }
                    
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
                    
                    guard let option = otherOptions.randomElement() else { continue }
                    
                    options.append(option)
                }
                
                randomNumber = randomSource.nextInt(upperBound: 100)

            }
            
            return options.map { $0.item }
            
            
        } else {
            preconditionFailure("For this release we are only allowing two goals")
        }

    }
    
    
    static func depthDivided(_ depth: Depth) -> Int {
        return depth/5
    }
    
    static func maxSpawnGems(depth: Depth) -> Int {
        return depthDivided(depth) + 3
    }
    
    static func levelGoal(depth: Depth, pillars: [PillarCoorindates], gemAtDepth: Int, randomSource: GKLinearCongruentialRandomSource, isTutorial: Bool) -> [LevelGoal] {
        func randomRockGoal(_ colors: [ShiftShaft_Color], amount: Int, minimumGroupSize: Int = 1) -> LevelGoal? {
            guard let randomColor = colors.randomElement() else { return nil }
            return LevelGoal(type: .unlockExit, tileType: .rock(color: randomColor, holdsGem: false, groupCount: 0), targetAmount: amount, minimumGroupSize: minimumGroupSize, grouped: minimumGroupSize > 1)
        }
        
        
        var goals: [LevelGoal?]
        switch depth {
        case 0:
            if isTutorial {
                let rockGoal = randomRockGoal([.purple], amount: 15)!
                
                return [rockGoal]
            }
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 1)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 20)
            
            goals = [monsterGoal, rockGoal]
        case 1:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 2)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 25)
            goals = [rockGoal, monsterGoal]
            
        case 2,3:
            let monsterAmount = Int(Double(boardSize(depth: depth)) * Double(boardSize(depth: depth)) * maxMonsterOnBoardRatio(depth: depth))
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 30)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
        
        case 4:
            let monsterAmount = 4
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 35)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
        case 5:
            let monsterAmount = 5
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 40)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
        case 6:
            let monsterAmount = 6
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 45)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
        case 7:
            let monsterAmount = 7
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 50)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
        
        case 8:
            let monsterAmount = 8
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 55)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
        case 9:
            let monsterAmount = 9
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 60)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
        
        case 10...Int.max:
            let monsterAmount = Int.random(in: 10...15)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: Int.random(lower: 60, upper: 75, interval: 5))
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
        
            
        default:
            goals = []
        }
        
        return goals.compactMap { $0 }.choose(random: 2)
    }
    
    static func boardSize(depth: Depth) -> Int {
        switch depth {
        case 0, 1, 2, 3, 4:
            return 8
        case 5...Int.max:
            return 9
        default:
            fatalError()
        }
    }
    
    static func maxMonsterOnBoardRatio(depth: Depth) -> Double {
        /// step function. every 5 levels we increase the maximum monster ratio by 0.05
        return min(0.2, Double(depthDivided(depth))*0.05 + 0.05)
    }
    
    static func availableRocksPerLevel(depth: Depth) -> TileTypeChanceModel {
        
        switch depth {
        // just for testing
//        case 0:
//            return TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 100,
//                                                        .rock(color: .blue, holdsGem: false): 50  ,
//                                                        ])
        case 0, 1, 2, 3, 4:
            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 33,
                                                        .rock(color: .blue, holdsGem: false, groupCount: 0): 33,
                                                        .rock(color: .purple, holdsGem: false, groupCount: 0): 33])
            return chances
        case 5, 6, 7...Int.max:
            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 33,
                                                        .rock(color: .blue, holdsGem: false, groupCount: 0): 33,
                                                         .rock(color: .purple, holdsGem: false, groupCount: 0): 33])
             return chances
//        case 8, 9:
//            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 30,
//                                                        .rock(color: .blue, holdsGem: false, groupCount: 0): 30,
//                                                        .rock(color: .purple, holdsGem: false, groupCount: 0): 30,
//                                                        .rock(color: .brown, holdsGem: false, groupCount: 0): 10])
//            return chances
//
//        case 10...Int.max:
//            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 29,
//                                                        .rock(color: .blue, holdsGem: false, groupCount: 0): 29,
//                                                        .rock(color: .purple, holdsGem: false, groupCount: 0): 29,
//                                                        .rock(color: .brown, holdsGem: false, groupCount: 0): 13])
//            return chances
        default:
            fatalError("Level must be positive")
        }
    }
    
    /// Randomly creates 0 up to a max of boardsize/8 pillar coordinates
    static func pillars(depth: Depth, randomSource: GKLinearCongruentialRandomSource) -> [PillarCoorindates] {
        
        func randomPillar(notIn set: Set<ShiftShaft_Color>) -> TileType {
            var color = ShiftShaft_Color.pillarCases.randomElement()!
            while set.contains(color) {
                color = ShiftShaft_Color.pillarCases.randomElement()!
            }
            return TileType.pillar(PillarData(color: color, health: 3))
        }
        
        func randomPillar() -> TileType {
            return randomPillar(notIn: [.brown, .green])
        }
        
        
        
        //        =FLOOR( MIN(M3 - (2 - MOD(RAND() * 10, 2)),  (AD3 + RANDBETWEEN(-1,1) ) ))
        /// no pillars in first 5 levels
//        let depthDivided = self.depthDivided(depth)
        let numPillarsBasedOnDepth: Int
        switch depth {
        case 1, 2, 3, 4:
            numPillarsBasedOnDepth = 0
        case 5, 6, 7:
            numPillarsBasedOnDepth = 3 + (randomSource.positiveNextInt % 2 == 0 ? -1 : 1)
        case 8, 9:
            numPillarsBasedOnDepth = 0
        case 10...Int.max:
            numPillarsBasedOnDepth = 3 + (randomSource.positiveNextInt % 2 == 0 ? -1 : 1)
        default:
            numPillarsBasedOnDepth = 0
        }
        
        let numberPillars = min(boardSize(depth: depth) - (2 - randomSource.positiveNextInt % 2), numPillarsBasedOnDepth)
        
        var coord: [TileCoord] = []
        var pillars: [PillarCoorindates] = []
        for _ in 0..<numberPillars {
            let pillar = randomPillar()
            let coordinate = TileCoord.random(boardSize(depth: depth), notInReservedCoords: coord)
            
            coord.append(coordinate)
            pillars.append(PillarCoorindates((pillar, coordinate)))
        }
        
        return pillars
    }
    
    
    static func monsterCountStart(depth: Depth) -> Int {
        return min(boardSize(depth: depth), depth + 2)
    }
    
    static func monsterTypes(depth: Depth) -> [EntityModel.EntityType: RangeModel] {
        func matchUp(_ types: [EntityModel.EntityType], range: RangeModel, subRanges: Int) -> [EntityModel.EntityType: RangeModel] {
            guard types.count == subRanges else { fatalError("The number of types nust match the number of subranges") }
            let dividedMonsterRanges = range.divivdedIntoSubRanges(subRanges)
            var count = 0
            return types.reduce([:], { (prior, type) -> [EntityModel.EntityType: RangeModel] in
                var new = prior
                new[type] = dividedMonsterRanges[count]
                count += 1
                return new
            })
        }
        
        switch depth {
        case 0, 1:
            let ratRange = RangeModel(lower: 0, upper: 50)
            let alamoRange = ratRange.next(50)
            return [.rat: ratRange, .alamo: alamoRange]
        case 2:
            let ratRange = RangeModel(lower: 0, upper: 40)
            let alamoRange = ratRange.next(40)
            let batRange = alamoRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .bat: batRange]
        case 3, 4, 5:
            let alamoRange = RangeModel(lower: 0, upper: 33)
            let ratRange = alamoRange.next(33)
            let batRange = ratRange.next(33)
            return [.alamo: alamoRange, .rat: ratRange, .bat: batRange]
        case 6:
            let alamoRange = RangeModel(lower: 0, upper: 21)
            let dragonRange = alamoRange.next(25)
            let batRange = dragonRange.next(21)
            let ratRange = batRange.next(33)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 7:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(33)
            let batRange = dragonRange.next(20)
            let ratRange = batRange.next(27)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 8:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(33)
            let batRange = dragonRange.next(18)
            let ratRange = batRange.next(30)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 9:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(25)
            let batRange = dragonRange.next(25)
            let ratRange = batRange.next(30)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 10:
            let alamoRange = RangeModel(lower: 0, upper: 16)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(16)
            let ratRange = batRange.next(33)
            let sallyRange = ratRange.next(15)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
        case 11:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(20)
            let ratRange = batRange.next(30)
            let sallyRange = ratRange.next(15)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
        case 12:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(15)
            let ratRange = batRange.next(25)
            let sallyRange = ratRange.next(25)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
        case 13:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(15)
            let ratRange = batRange.next(30)
            let sallyRange = ratRange.next(25)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
        case 14:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(10)
            let ratRange = batRange.next(30)
            let sallyRange = ratRange.next(30)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
        case 15...Int.max:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(10)
            let ratRange = batRange.next(30)
            let sallyRange = ratRange.next(30)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        default:
            fatalError()
        }
    }
}
