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
    
    // ITEMS
    
    static var tier1Items:  [StoreOffer] {
        [
//            StoreOffer.offer(type: .plusOneMaxHealth, tier: 1),
            StoreOffer.offer(type: .killMonsterPotion, tier: 1),
            StoreOffer.offer(type: .transmogrifyPotion, tier: 1),
//            StoreOffer.offer(type: .greaterHeal, tier: 1)
        ]
    }
    
    static var tier2Items: [StoreOffer] {
        [
        StoreOffer.offer(type: .luck(amount: 2), tier: 2),
        StoreOffer.offer(type: .dodge(amount: 2), tier: 2),
        StoreOffer.offer(type: .plusTwoMaxHealth, tier: 2),
        StoreOffer.offer(type: .greaterHeal, tier: 2)
        ]
    }
    
    static var tier3Items: [StoreOffer] {
        [
        StoreOffer.offer(type: .luck(amount: 3), tier: 3),
        StoreOffer.offer(type: .dodge(amount: 3), tier: 3),
        StoreOffer.offer(type: .plusTwoMaxHealth, tier: 3),
        StoreOffer.offer(type: .greaterHeal, tier: 3)
        ]
    }
    
    static var tier1Runes: [StoreOffer] {
        [
            StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 1),
            StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 1),
            StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 1),
            StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 1),
            StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 1),
            StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 1)
        ]
    }
    
    static var basicRunes: [StoreOffer] {
        [
            StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 2)
        ]
    }
    
    /// RUNES
    
    static var tier2Runes: [StoreOffer] {
        [
            StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 2),
            StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 2)
        ]
    }
    
    static var tier3Runes: [StoreOffer] {
        [
            StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 3),
            StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 3),
            StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 3),
            StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 3),
            StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 3),
            StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier:32)
        ]
    }
    
    static func buildLevel(depth: Depth, randomSource: GKLinearCongruentialRandomSource) -> Level {
        let pillarCoords = pillars(depth: depth)
        let maxGems = maxSpawnGems(depth: depth)
        
        return Level(depth: depth,
                     monsterTypeRatio: monsterTypes(depth: depth),
                     monsterCountStart: monsterCountStart(depth: depth),
                     maxMonsterOnBoardRatio: maxMonsterOnBoardRatio(depth: depth),
                     boardSize: boardSize(depth: depth),
                     tileTypeChances: availableRocksPerLevel(depth: depth),
                     pillarCoordinates: pillarCoords,
                     goals: levelGoal(depth: depth, pillars: pillarCoords, gemAtDepth: maxGems),
                     maxSpawnGems: maxGems,
                     goalProgress: [],
                     potentialItems: potentialItems(depth: depth))
    }
    
    static func tier2items(depth: Depth) -> [StoreOffer] {
        switch depth {
        case 1:
            return basicRunes
        case 3:
            return tier2Runes
        case 0, 2:
            return tier2Items
        case 4, 9, 14:
            return [StoreOffer.offer(type: .runeSlot, tier: 2)]
        case 5:
            return tier2Runes
        case 6, 7, 8:
            return tier2Items
        case 10, 11, 12, 13:
            return tier2Items
        case 14..<Int.max:
            return tier2Items
        default:
            return []
        }
    }
    
    static func tier3items(depth: Depth) -> [StoreOffer] {
        switch depth {
        case 0,1:
            return []
        case 2,3:
            return tier3Items
        case 4, 9, 14:
            return tier3Runes
        case 5..<Int.max:
            return tier3Items
            
        default:
            return []
        }
    }
    
    static func potentialItems(depth: Depth) -> [StoreOffer] {
        var offers = [StoreOffer]()
        offers.append(contentsOf: tier1Items)
        offers.append(contentsOf: tier2items(depth: depth))
        offers.append(contentsOf: tier3items(depth: depth))
        
        return offers
    }
    
    static func depthDivided(_ depth: Depth) -> Int {
        return depth/5
    }
    
    static func maxSpawnGems(depth: Depth) -> Int {
        return depthDivided(depth) + 3
    }
    
    static func levelGoal(depth: Depth, pillars: [PillarCoorindates], gemAtDepth: Int, randomSource: GKLinearCongruentialRandomSource = GKLinearCongruentialRandomSource()) -> [LevelGoal] {
        func randomRockGoal(_ colors: [Color], amount: Int, minimumGroupSize: Int) -> LevelGoal? {
            guard let randomColor = colors.randomElement() else { return nil }
            return LevelGoal(type: .unlockExit, tileType: .rock(color: randomColor, holdsGem: false), targetAmount: amount, minimumGroupSize: minimumGroupSize, grouped: minimumGroupSize > 1)
        }
        
        
        var goals: [LevelGoal?]
        switch depth {
        case 0:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 1)
            let gemGoal = LevelGoal.gemGoal(amount: 1)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 2, minimumGroupSize: 3)
            
            goals = [gemGoal, rockGoal, monsterGoal]
        case 1:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 3)
            let gemGoal = LevelGoal.gemGoal(amount: 2)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 8, minimumGroupSize: 3)
            goals = [gemGoal, rockGoal, monsterGoal]
        case 2...Int.max:
            let minGroupSize = depthDivided(depth) + 3 + (abs(randomSource.nextInt())*100 % 2)
            let rockAmount = Int.random(lower: 20, upper: 35) / minGroupSize
            let monsterAmount = Int(Double(boardSize(depth: depth)) * Double(boardSize(depth: depth)) * maxMonsterOnBoardRatio(depth: depth))
            let gemAmount = gemAtDepth * Int.random(lower: 50, upper: 75) / 100
            let pillarAmount = pillars.count * 3 * Int.random(lower: 50, upper: 75) / 100
            let useRuneAmount = depthDivided(depth) + (abs(randomSource.nextInt() * 100) % 3) + 1
            
            let gemGoal = LevelGoal.gemGoal(amount: gemAmount)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: rockAmount, minimumGroupSize: minGroupSize)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillarAmount)
            let useRuneGoal = LevelGoal.useRuneGoal(amount: useRuneAmount)
            
            goals = [gemGoal, rockGoal, monsterGoal]
            
            if pillarAmount > 0 {
                goals.append(pillarGoal)
            } else if useRuneAmount > 0 {
                goals.append(useRuneGoal)
            }
        default:
            goals = []
        }
        
        switch depth {
        case 0, 1:
            return goals.compactMap { $0 }.choose(random: 2)
        default:
            return goals.compactMap { $0 }.choose(random: 3)
        }
    }
    
    static func boardSize(depth: Depth) -> Int {
        switch depth {
        case 0, 1, 2, 3, 4:
            return 7
        case 5...Int.max:
            return 8
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
        case 0, 1, 2, 3, 4:
            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false): 33,
                                                        .rock(color: .blue, holdsGem: false): 33,
                                                        .rock(color: .purple, holdsGem: false): 33])
            return chances
        case 5, 6, 7, 8, 9:
            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false): 31,
                                                        .rock(color: .blue, holdsGem: false): 31,
                                                        .rock(color: .purple, holdsGem: false): 31,
                                                        .rock(color: .brown, holdsGem: false): 7])
            return chances
            
        case 10...Int.max:
            let chances = TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false): 30,
                                                          .rock(color: .blue, holdsGem: false): 30,
                                                          .rock(color: .purple, holdsGem: false): 30,
                                                          .rock(color: .brown, holdsGem: false): 10])
            return chances
        default:
            fatalError("Level must be positive")
        }
    }
    
    /// Randomly creates 0 up to a max of boardsize/8 pillar coordinates
    static func pillars(depth: Depth, randomSource: GKLinearCongruentialRandomSource = GKLinearCongruentialRandomSource()) -> [PillarCoorindates] {
        
        func randomPillar(notIn set: Set<Color>) -> TileType {
            var color = Color.allCases.randomElement()!
            while set.contains(color) {
                color = Color.allCases.randomElement()!
            }
            return TileType.pillar(PillarData(color: color, health: 3))
        }
        
        func randomPillar() -> TileType {
            return randomPillar(notIn: [.brown, .green])
        }
        
        
        
//        =FLOOR( MIN(M3 - (2 - MOD(RAND() * 10, 2)),  (AD3 + RANDBETWEEN(-1,1) ) ))
        /// no pillars in first 5 levels
        let depthDivided = self.depthDivided(depth)
        let numPillarsBasedOnDepth =
            depthDivided == 0 ?
                0
                :
            depthDivided + (randomSource.positiveNextInt % 2 == 0 ? -1 : 1)
        
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
