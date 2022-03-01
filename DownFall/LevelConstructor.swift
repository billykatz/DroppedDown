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
let bossLevelDepthNumber = 9
let testLevelDepthNumber = -1

struct LevelConstructor {
    
    static func buildLevel(depth: Int, randomSource: GKLinearCongruentialRandomSource, playerData: EntityModel, unlockables: [Unlockable], startingUnlockables: [Unlockable], isTutorial: Bool, randomSeed: UInt64, runModel: RunModel?) -> Level {
        let gemsAtDepth = maxSpawnGems(depth: depth)
        
        
        return Level(
            depth: depth,
            monsterTypeRatio: monsterTypes(depth: depth),
            monsterCountStart: monsterCountStart(depth: depth),
            maxMonsterOnBoardRatio: maxMonsterOnBoardRatio(depth: depth),
            boardSize: boardSize(depth: depth),
            tileTypeChances: availableRocksPerLevel(depth: depth),
            goals: levelGoal(depth: depth, gemAtDepth: gemsAtDepth, randomSource: randomSource, isTutorial: isTutorial),
            maxSpawnGems: gemsAtDepth,
            goalProgress: [],
            savedBossPhase: nil,
            gemsSpawned: 0,
            monsterSpawnTurnTimer: 0,
            startingUnlockables: startingUnlockables,
            otherUnlockables: unlockables,
            randomSeed: randomSeed,
            isTutorial: isTutorial,
            runModel: runModel
        )
    }
    
    static func depthDivided(_ depth: Depth) -> Int {
        return abs(depth)/3
    }
    
    static func maxSpawnGems(depth: Depth) -> Int {
        // spawn at least 1
        return max(1, depthDivided(depth))
    }
    
    static func levelGoal(depth: Depth, gemAtDepth: Int, randomSource: GKLinearCongruentialRandomSource, isTutorial: Bool) -> [LevelGoal] {
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
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 30)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 3)
            
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
            
        case bossLevelDepthNumber:
            
            goals = [LevelGoal.bossGoal()]
            
        case 8, 9:
            let monsterAmount = 8
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: 55)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
            
        case 10...Int.max:
            let monsterAmount = Int.random(in: 10...15)
            let rockGoal = randomRockGoal([.red, .purple, .blue], amount: Int.random(lower: 60, upper: 75, interval: 5))
            let monsterGoal = LevelGoal.killMonsterGoal(amount: monsterAmount)
            
            goals = [rockGoal, monsterGoal]
            
        case testLevelDepthNumber:
            let rockGoal = LevelGoal(type: .unlockExit, tileType: .rock(color: .blue, holdsGem: false, groupCount: 0), targetAmount: 3, minimumGroupSize: 1, grouped: false)
            let rockGoal2 = LevelGoal(type: .unlockExit, tileType: .rock(color: .purple, holdsGem: false, groupCount: 0), targetAmount: 4, minimumGroupSize: 1, grouped: false)
            //            let monsterGoal = LevelGoal.killMonsterGoal(amount: 4)
            goals = [rockGoal, rockGoal2]
            
        default:
            goals = []
        }
        
        return goals.compactMap { $0 }.choose(random: 2)
    }
    
    static func boardSize(depth: Depth) -> Int {
        switch depth {
        case 0, 1:
            return 7
        case 2, 3, 4:
            return 8
        case 5...Int.max:
            return 9
        case testLevelDepthNumber:
            return 7
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
            //            case 0:
            //                return TileTypeChanceModel(chances: [.rock(color: .red, holdsGem: false, groupCount: 0): 50,
            //                                                     .rock(color: .blue, holdsGem: false, groupCount: 0): 50  ,
            //                                                            ])
        case 0, 1, 2, 3, 4, 5, 6:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 33,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 33,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 33
            ])
            
        case bossLevelDepthNumber:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 33,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 33,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 33
            ])
            
        case 7:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 32,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 32,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 32,
                .rock(color: .brown, holdsGem: false, groupCount: 0): 3])
            
        case 8:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 31,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 31,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 31,
                .rock(color: .brown, holdsGem: false, groupCount: 0): 6])
            
        case 10...Int.max:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 25,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 25,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 25,
                .rock(color: .brown, holdsGem: false, groupCount: 0): 25])
            
        case testLevelDepthNumber:
            return TileTypeChanceModel(chances: [
                .rock(color: .red, holdsGem: false, groupCount: 0): 33,
                .rock(color: .blue, holdsGem: false, groupCount: 0): 33,
                .rock(color: .purple, holdsGem: false, groupCount: 0): 33,
                //                    .rock(color: .brown, holdsGem: false, groupCount: 0): 25
            ]
            )
            
        default:
            fatalError("Level must be positive")
        }
    }
        
       
    
    static func monsterCountStart(depth: Depth) -> Int {
        if depth == testLevelDepthNumber { return 3 }
        if depth == bossLevelDepthNumber { return 0 }
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
            
        case 3:
            let ratRange = RangeModel(lower: 0, upper: 33)
            let alamoRange = ratRange.next(40)
            let batRange = alamoRange.next(25)
            return [.rat: ratRange, .alamo: alamoRange, .bat: batRange]
            
        case 4:
            let alamoRange = RangeModel(lower: 0, upper: 30)
            let ratRange = alamoRange.next(30)
            let batRange = ratRange.next(25)
            let dragonRange = batRange.next(15)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
            
        case 5:
            let alamoRange = RangeModel(lower: 0, upper: 21)
            let dragonRange = alamoRange.next(25)
            let batRange = dragonRange.next(25)
            let ratRange = batRange.next(21)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
            
        case 6:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(27)
            let batRange = dragonRange.next(28)
            let ratRange = batRange.next(15)
            let sallyRange = ratRange.next(10)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 7:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(22)
            let batRange = dragonRange.next(28)
            let ratRange = batRange.next(10)
            let sallyRange = ratRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 8:
            let alamoRange = RangeModel(lower: 0, upper: 16)
            let dragonRange = alamoRange.next(18)
            let batRange = dragonRange.next(26)
            let ratRange = batRange.next(10)
            let sallyRange = ratRange.next(30)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case bossLevelDepthNumber:
            return [:]
            
        case 10:
            let alamoRange = RangeModel(lower: 0, upper: 16)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(16)
            let ratRange = batRange.next(15)
            let sallyRange = ratRange.next(15)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 11:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(20)
            let ratRange = batRange.next(10)
            let sallyRange = ratRange.next(15)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 12:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(15)
            let ratRange = batRange.next(5)
            let sallyRange = ratRange.next(25)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 13:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(15)
            let sallyRange = batRange.next(25)
            return [.alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 14:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(30)
            return [.alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case 15...Int.max:
            let alamoRange = RangeModel(lower: 0, upper: 15)
            let dragonRange = alamoRange.next(15)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(30)
            return [.alamo: alamoRange, .dragon: dragonRange, .bat: batRange, .sally: sallyRange]
            
        case testLevelDepthNumber:
            let ratRange = RangeModel(lower: 0, upper: 50)
            let alamoRange = ratRange.next(50)
            return [.rat: ratRange, .alamo: alamoRange]
            
            
        default:
            fatalError()
        }
    }
}
