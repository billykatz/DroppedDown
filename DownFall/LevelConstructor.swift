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
                     goalProgress: [])
    }
    
    static func maxSpawnGems(depth: Depth) -> Int {
        return max(1, depth / 4) * 3
    }
    
    static func levelGoal(depth: Depth, pillars: [PillarCoorindates], gemAtDepth: Int) -> [LevelGoal] {
        func randomRockGoal(_ colors: [Color], amount: Int, minimumGroupSize: Int) -> LevelGoal? {
            guard let randomColor = colors.randomElement() else { return nil }
            return LevelGoal(type: .unlockExit, tileType: .rock(randomColor), targetAmount: amount, minimumGroupSize: minimumGroupSize, grouped: minimumGroupSize > 1)
        }
        
        
        var goals: [LevelGoal?]
        switch depth {
        case 0:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 2)
            let gemGoal = LevelGoal.gemGoal(amount: 1)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 25, minimumGroupSize: 1)
            goals = [gemGoal, rockGoal, monsterGoal]
        case 1:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 3)
            let gemGoal = LevelGoal.gemGoal(amount: 2)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 35, minimumGroupSize: 1)
            goals = [gemGoal, rockGoal, monsterGoal]
        case 2:
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            let rockGoal = randomRockGoal([.red, .purple,. blue], amount: 5, minimumGroupSize: 4)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 5)
            goals = [gemGoal, rockGoal, monsterGoal]
        case 3:
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            let runeGoal = LevelGoal.useRuneGoal(amount: 2)
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 7)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillars.count * 2)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 8, minimumGroupSize: 4)
            goals = [gemGoal, rockGoal, monsterGoal, pillarGoal, runeGoal]
        case 4:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 10)
            let runeGoal = LevelGoal.useRuneGoal(amount: 3)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 8, minimumGroupSize: 5)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillars.count * 2)
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            goals = [runeGoal, rockGoal, monsterGoal, pillarGoal, gemGoal]
        case 5:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 12)
            let runeGoal = LevelGoal.useRuneGoal(amount: 4)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 5, minimumGroupSize: 6)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillars.count * 2)
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            goals = [rockGoal, gemGoal, monsterGoal, pillarGoal, runeGoal]
        case 6:
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 15)
            let runeGoal = LevelGoal.useRuneGoal(amount: 5)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 8, minimumGroupSize: 5)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillars.count * 3)
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            goals = [rockGoal, gemGoal, monsterGoal, pillarGoal, runeGoal]
        case (7...Int.max):
            let monsterGoal = LevelGoal.killMonsterGoal(amount: 15)
            let runeGoal = LevelGoal.useRuneGoal(amount: 5)
            let rockGoal = randomRockGoal([.blue, .purple, .red], amount: 8, minimumGroupSize: 5)
            let pillarGoal = LevelGoal.pillarGoal(amount: pillars.count * 3)
            let gemGoal = LevelGoal.gemGoal(amount: gemAtDepth)
            goals = [rockGoal, gemGoal, monsterGoal, pillarGoal, runeGoal]
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
        case 0, 1:
            return 7
        case 2, 3:
            return 8
        case 4, 5,6, (7...Int.max):
            return 9
        default:
            fatalError()
        }
    }
    
    static func maxMonsterOnBoardRatio(depth: Depth) -> Double {
        switch depth {
        case 0, 1, 2:
            return 0.05
        case 3, 4:
            return 0.1
        case 5, 6, 7:
            return 0.15
        case 8, 9, 10:
            return 0.2
        case 10...Int.max:
            return 0.25
        default:
            preconditionFailure("Failed")
        }
        
    }
    
    static func availableRocksPerLevel(depth: Depth) -> TileTypeChanceModel {
        
        switch depth {
        case 0, 1, 2, 3:
            let chances = TileTypeChanceModel(chances: [.rock(.red): 33,
                                                        .rock(.blue): 33,
                                                        .rock(.purple): 33])
            return chances
        case 4:
            let chances = TileTypeChanceModel(chances: [.rock(.red): 30,
                                                        .rock(.blue): 30,
                                                        .rock(.purple): 30,
                                                        .rock(.brown): 10])
            return chances
        case 5:
            let chances = TileTypeChanceModel(chances: [.rock(.red): 28,
                                                        .rock(.blue): 28,
                                                        .rock(.purple): 28,
                                                        .rock(.brown): 15])
            return chances
            
        case 6, (7...Int.max):
            let chances = TileTypeChanceModel(tileTypes: [.rock(.red),
                                                          .rock(.blue),
                                                          .rock(.purple),
                                                          .rock(.brown)])
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
        
        let numberPillars = min(boardSize(depth: depth), (depth / 3) * (abs(randomSource.nextInt()) % 3 + 1))
        
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
            let ratRange = RangeModel(lower: 0, upper: 40)
            let alamoRange = ratRange.next(40)
            let batRange = alamoRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .bat: batRange]
        case 2:
            let ratRange = RangeModel(lower: 0, upper: 20)
            let alamoRange = ratRange.next(20)
            let dragonRange = alamoRange.next(20)
            let batRange = alamoRange.next(10)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 3, 4:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(10)
            return [.sally: sallyRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 5, 6:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(20)
            return [.sally: sallyRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case 7...Int.max:
            let ratRange = RangeModel(lower: 0, upper: 20)
            let alamoRange = ratRange.next(20)
            let dragonRange = alamoRange.next(20)
            let batRange = alamoRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        default:
            fatalError()
        }
    }
}
