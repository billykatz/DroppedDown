//
//  LevelConstructor.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import GameplayKit

struct LevelConstructor {
    
    static func buildLevels(_ difficulty: Difficulty, randomSource: GKLinearCongruentialRandomSource) -> [Level] {
        return LevelType.gameCases.map { levelType in
            return Level(type: levelType,
                         monsterTypeRatio: monsterTypes(per: levelType, difficulty: difficulty),
                         monsterCountStart: monsterCountStart(levelType, difficulty: difficulty),
                         maxMonsterOnBoardRatio: maxMonsterOnBoardRatio(per: levelType, difficulty: difficulty),
                         maxGems: 1,
                         maxTime: timePer(levelType, difficulty: difficulty),
                         boardSize: boardSize(per: levelType, difficulty: difficulty),
                         abilities: availableAbilities(per: levelType, difficulty: difficulty),
                         goldMultiplier: difficulty.goldMultiplier,
                         rocksRatio: availableRocksPerLevel(levelType, difficulty: difficulty),
                         pillarCoordinates: pillars(per: levelType, difficulty: difficulty),
                         threatLevelController: buildThreatLevelController(per: levelType, difficulty: difficulty),
                         goals: levelGoal(per: levelType, difficulty: difficulty), numberOfGoalsNeedToUnlockExit: numberOfGoalsNeedToUnlockExit(per: levelType, difficulty: difficulty))
        }
    }
    
    static func numberOfGoalsNeedToUnlockExit(per: LevelType, difficulty: Difficulty) -> Int {
    
        return 2
    }

    
    static func levelGoal(per: LevelType, difficulty: Difficulty) -> [LevelGoal] {
        let rockGoal = LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .rock(.purple), targetAmount: 10, minimumGroupSize: 5, grouped: true)
        let gemGoal = LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .gem, targetAmount: 3, minimumGroupSize: 1, grouped: false)
        let monsterGoal = LevelGoal(type: .unlockExit, reward: .gem(1), tileType: .monster(.zeroedEntity(type: .rat)), targetAmount: 5, minimumGroupSize: 1, grouped: false)
        return [rockGoal, gemGoal, monsterGoal]
    }
    
    static func buildTutorialLevels() -> [Level] {
        return (0..<LevelType.tutorialCases.count).map { index in
            Level(type: LevelType.tutorialCases[index],
                  monsterTypeRatio: [:],
                  monsterCountStart: 0,
                  maxMonsterOnBoardRatio: 0.0,
                  maxGems: 0,
                  maxTime: 0,
                  boardSize: 4,
                  abilities: [],
                  goldMultiplier: 1,
                  rocksRatio: [:],
                  pillarCoordinates: [],
                  threatLevelController: ThreatLevelController(),
                  goals: [LevelGoal(type: .unlockExit, reward: .gem(0), tileType: .empty, targetAmount: 0, minimumGroupSize: 0, grouped: false)],
                  numberOfGoalsNeedToUnlockExit: 0,
                  tutorialData: GameScope.shared.tutorials[index])
        }
    }
    
    static func boardSize(per levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first, .second:
            return 8
        case .third, .fourth:
            return 9
        case .fifth, .sixth, .seventh, .boss:
            return 10
        case .tutorial1, .tutorial2:
            fatalError()
        }
    }
    
    static func buildThreatLevelController(per levelType: LevelType, difficulty: Difficulty) -> ThreatLevelController {
        switch levelType {
        case .first, .second:
            return ThreatLevelController(yellowRange: 0..<75, orangeRange: 75..<150, redRange: 150..<Int.max)
        case .third, .fourth:
            return ThreatLevelController(yellowRange: 0..<65, orangeRange: 65..<130, redRange: 130..<Int.max)
        case .fifth, .sixth, .seventh:
            return ThreatLevelController(yellowRange: 0..<55, orangeRange: 55..<110, redRange: 110..<Int.max)
        case .tutorial1, .tutorial2, .boss:
            fatalError()
        }
    }
    
    
    static func maxMonsterOnBoardRatio(per levelType: LevelType, difficulty: Difficulty) -> Double {
        switch levelType {
        case .first:
            return 0.05
        case .second, .third:
            return 0.08
        case .fourth:
            return 0.10
        case .fifth, .sixth, .boss:
            return 0.12
        case .seventh:
            return  0.15
        case .tutorial1, .tutorial2:
            fatalError()
        }
    }
    
    
    static func availableRocksPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [TileType: RangeModel] {
        let normalRockRange = RangeModel(lower: 0, upper: 90)
        
        func matchUp(_ types: [TileType], range: RangeModel, subRanges: Int) -> [TileType: RangeModel] {
            guard types.count == subRanges else { fatalError("The number of types nust match the number of subranges") }
            let dividedRockRanges = range.divivdedIntoSubRanges(subRanges)
            var count = 0
            return types.reduce([:], { (prior, type) -> [TileType: RangeModel] in
                var new = prior
                new[type] = dividedRockRanges[count]
                count += 1
                return new
            })
        }
        
        switch levelType {
        case .first, .second, .third, .fourth:
            let rocks = matchUp([.rock(.red), .rock(.blue), .rock(.purple)], range: normalRockRange, subRanges: 3)
            return rocks
        case .fifth, .sixth, .seventh, .boss:
            let rocks = matchUp([.rock(.red), .rock(.blue), .rock(.purple), .rock(.brown)], range: normalRockRange, subRanges: 4)
            return rocks
        case .tutorial1, .tutorial2:
            fatalError("Do not call this for tutorial")
        }
    }
    
    static func pillars(per levelType: LevelType, difficulty: Difficulty) -> [(TileType, TileCoord)] {
        
        func randomPillar(notIn set: Set<Color>) -> TileType {
            var color = Color.allCases.randomElement()!
            while set.contains(color) {
                color = Color.allCases.randomElement()!
            }
            return TileType.pillar(color, 3)
        }
        
        
        let boardWidth = boardSize(per: levelType, difficulty: difficulty)
        let inset = 2
        switch levelType {
        case .first:
            return []
        case .second:
            return [
                (randomPillar(notIn: Set<Color>([.purple, .brown, .green])), TileCoord(boardWidth/2, boardWidth/2)),
                (randomPillar(notIn: Set<Color>([.purple, .brown, .green])), TileCoord(boardWidth/2 - 1, boardWidth/2 - 1)),
            ]
        case .third:
            return [
                (randomPillar(notIn: Set<Color>([.brown, .green])), TileCoord(inset, inset)),
                (randomPillar(notIn: Set<Color>([.brown, .green])), TileCoord(boardWidth-inset-1, boardWidth-inset-1))
            ]
        case .fourth:
            let inset = 4
            let randoPillar = randomPillar(notIn: Set<Color>([.brown, .green]))
            return [
                (randoPillar, TileCoord(inset, boardWidth-inset-2)),
                (randoPillar, TileCoord(inset, boardWidth-inset-1)),
                (randoPillar, TileCoord(inset, boardWidth-inset))
            ]
            
        case .fifth:
            let randomPillar1 = randomPillar(notIn: Set<Color>([.green]))
            let randomPillar2 = randomPillar(notIn: Set<Color>([.green]))
            return [
                (randomPillar1, TileCoord(0, 0)),
                (randomPillar1, TileCoord(0, 1)),
                (randomPillar1, TileCoord(1, 0)),
                (randomPillar2, TileCoord(boardWidth-1, boardWidth-2)),
                (randomPillar2, TileCoord(boardWidth-1, boardWidth-1)),
                (randomPillar2, TileCoord(boardWidth-2, boardWidth-1))
            ]
        case .sixth:
            let localInset = 3
            return [
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-localInset-1, localInset)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-localInset-1, boardWidth-localInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(localInset, boardWidth-localInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(localInset, localInset))
            ]
        case .seventh:
            let localInset = 2
            let otherInset = 4
            return [
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-localInset-1, localInset)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-localInset-1, boardWidth-localInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(localInset, boardWidth-localInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(localInset, localInset)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-otherInset-1, otherInset)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(boardWidth-otherInset-1, boardWidth-otherInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(otherInset, boardWidth-otherInset-1)),
                (randomPillar(notIn: Set<Color>([.green])), TileCoord(otherInset, otherInset))
            ]
        case .tutorial1, .tutorial2:
            return []
        case .boss:
            var pillarCoords: [TileCoord] = []
            let beforeHalf = boardWidth/2 - 1
            let afterHalf = boardWidth/2
            for column in beforeHalf...afterHalf {
                for row in (boardWidth/2 - 2)...(boardWidth/2 + 1) {
                    pillarCoords.append(TileCoord(row, column))
                }
            }
            
            let pillarTypes = [
                TileType.pillar(.red, 3), .pillar(.red, 3),
                .pillar(.blue, 3), .pillar(.blue, 3),
                .pillar(.brown, 3), .pillar(.brown, 3),
                .pillar(.purple, 3), .pillar(.purple, 3)
            ]
            
            var result:  [(TileType, TileCoord)] = []
            //TODO: make this determinstically randomized
            for (index, type) in pillarTypes.shuffled().enumerated() {
                result.append( (type, pillarCoords[index]) )
            }
            
            return result
        }
    }
    
    
    static func monsterCountStart(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            return 2
        case .second:
            return 3
        case .third, .fourth:
            return 6
        case .fifth, .sixth, .seventh:
            return 8
        case .boss:
            return 0
            
        default:
            preconditionFailure("Chloe is so cure when she is sleepy")
        }
    }
    
    static func monsterTypes(per levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: RangeModel] {
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
        
        switch levelType {
        case .first, .second:
            let ratRange = RangeModel(lower: 0, upper: 40)
            let alamoRange = ratRange.next(40)
            let batRange = alamoRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .bat: batRange]
        case .third:
            let ratRange = RangeModel(lower: 0, upper: 20)
            let alamoRange = ratRange.next(20)
            let dragonRange = alamoRange.next(20)
            let batRange = alamoRange.next(10)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case .fourth, .fifth:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(10)
            return [.sally: sallyRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case .sixth, .seventh:
            let alamoRange = RangeModel(lower: 0, upper: 20)
            let dragonRange = alamoRange.next(20)
            let batRange = dragonRange.next(10)
            let sallyRange = batRange.next(20)
            return [.sally: sallyRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case .boss:
            let ratRange = RangeModel(lower: 0, upper: 20)
            let alamoRange = ratRange.next(20)
            let dragonRange = alamoRange.next(20)
            let batRange = alamoRange.next(20)
            return [.rat: ratRange, .alamo: alamoRange, .dragon: dragonRange, .bat: batRange]
        case .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
    
    
    static func timePer(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return 50
            case .normal:
                return 45
            case .hard:
                return 40
            }
        case .second:
            switch difficulty{
            case .easy:
                return 60
            case .normal:
                return 50
            case .hard:
                return 45
            }
        case .third, .boss:
            switch difficulty{
            case .easy:
                return 70
            case .normal:
                return 55
            case .hard:
                return 50
            }
        case .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        default:
            return 0
        }
    }
    
    static func availableAbilities(per levelType: LevelType, difficulty: Difficulty) -> [AnyAbility] {
        
        func droppingRandom(numberOfElements: Int, from array: [Ability]) -> [Ability] {
            if numberOfElements >= array.count { return [] }
            if numberOfElements == 0 { return array }
            var new = array
            var removed = 0
            while removed < numberOfElements {
                let randomNumber = Int.random(new.count)
                removed += 1
                new.remove(at: randomNumber)
            }
            return new
        }

        
        var abilities: [Ability]
        
        switch levelType {
        case .first:
            abilities = [FreeLesserHealingPotion(), FreeKillMonsterPotion(), FreeDynamite()]
        case .second, .third:
            let temp: [Ability] = [LesserHealingPotion(), TransmogrificationPotion(), KillMonsterPotion(), Dynamite(), GreaterHealingPotion()]
            abilities = droppingRandom(numberOfElements: 2, from: temp)
        case .fourth:
            let temp: [Ability] = [GreatestHealingPotion(), RockASwap(), TransmogrificationPotion(), KillMonsterGroupPotion(),  KillMonsterPotion(), Dynamite(), GreaterHealingPotion(), MassMinePickaxe()]
                      abilities = droppingRandom(numberOfElements: 2, from: temp)
        case .fifth, .sixth, .seventh:
        let temp: [Ability] = [GreatestHealingPotion(), RockASwap(),MassMinePickaxe(), TransmogrificationPotion(), KillMonsterGroupPotion(),  KillMonsterPotion(), Dynamite(), GreaterHealingPotion()]
                  abilities = droppingRandom(numberOfElements: 2, from: temp)
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
        
        return abilities.map { AnyAbility($0) }
    }
}
