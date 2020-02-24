//
//  LevelConstructor.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct LevelConstructor {
    
    static func buildLevels(_ difficulty: Difficulty) -> [Level] {
        return LevelType.gameCases.map { levelType in
            return Level(type: levelType,
                         monsterTypeRatio: monstersPerLevel(levelType, difficulty: difficulty),
                         monsterCountStart: monsterCountStart(levelType, difficulty: difficulty),
                         maxGems: 1,
                         maxTime: timePer(levelType, difficulty: difficulty),
                         boardSize: boardSize(per: levelType, difficulty: difficulty),
                         abilities: availableAbilities(per: levelType, difficulty: difficulty),
                         goldMultiplier: difficulty.goldMultiplier,
                         rocksRatio: availableRocksPerLevel(levelType, difficulty: difficulty),
                         pillarCoordinates: pillars(per: levelType, difficulty: difficulty))
        }
    }
    
    static func buildTutorialLevels() -> [Level] {
        return (0..<LevelType.tutorialCases.count).map { index in
            Level(type: LevelType.tutorialCases[index],
                  monsterTypeRatio: [:],
                  monsterCountStart: 0,
                  maxGems: 0,
                  maxTime: 0,
                  boardSize: 4,
                  abilities: [],
                  goldMultiplier: 1,
                  rocksRatio: [:],
                  pillarCoordinates: [],
                  tutorialData: GameScope.shared.tutorials[index])
        }
    }
    
    static func boardSize(per levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            return 8
        case .second:
            return 9
        case .third:
            return 10
        case .boss:
            fatalError()
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
        case .first:
            let rocks = matchUp([.rock(.red), .rock(.blue), .rock(.purple)], range: normalRockRange, subRanges: 3)
            return rocks
        case .second:
            let rocks = matchUp([.rock(.red), .rock(.blue), .rock(.purple)], range: normalRockRange, subRanges: 3)
            return rocks
        case .third:
            let rocks = matchUp([.rock(.red), .rock(.blue), .rock(.purple), .rock(.brown)], range: normalRockRange, subRanges: 4)
            return rocks
        case .boss, .tutorial1, .tutorial2:
            fatalError("Gotta do boss and or not call this for tutorial")
        }
    }
    
    static func pillars(per levelType: LevelType, difficulty: Difficulty) -> [(TileType, TileCoord)] {
        let boardWidth = boardSize(per: levelType, difficulty: difficulty)
        let inset = 2
        if levelType == .third {
            return [
                    (TileType.pillar(.red), TileCoord(inset, inset)),
                    (TileType.pillar(.blue), TileCoord(inset, boardWidth-inset-1)),
                    (TileType.pillar(.brown), TileCoord(boardWidth-inset-1, boardWidth-inset-1)),
                    (TileType.pillar(.purple), TileCoord(boardWidth-inset-1, inset))
                    ]
        } else {
            return []
        }
    }

    
    static func monsterCountStart(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        let boardWidth = boardSize(per: levelType, difficulty: difficulty)
        let boardsize = boardWidth * boardWidth
        switch (levelType, difficulty) {
        case (.first, _):
            return boardsize/10
        case (.second, _):
            return boardsize/9
        case (.third, _):
            return boardsize/8
        default:
            preconditionFailure("Chloe is so cure when she is sleepy")
        }
    }
    
    static func monstersPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: RangeModel] {
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
        
        
        
        let normalRockRange = RangeModel(lower: 0, upper: 100)
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return matchUp([.rat, .bat], range: normalRockRange, subRanges: 2)
            case .normal, .hard:
                let ratRange = RangeModel(lower: 0, upper: 40)
                let alamoRange = ratRange.next(40)
                let batRange = alamoRange.next(20)
                return [.rat: ratRange, .alamo: alamoRange, .bat: batRange]
//                return matchUp([.rat, .bat, .alamo], range: normalRockRange, subRanges: 3)
            }
        case .second:
            switch difficulty{
            case .easy:
                return matchUp([.rat, .bat, .dragon], range: normalRockRange, subRanges: 3)
            case .normal, .hard:
                return matchUp([.rat, .bat, .dragon, .alamo], range: normalRockRange, subRanges: 4)
            }
        case .third:
            switch difficulty{
            case .easy:
                return matchUp([.bat, .dragon, .alamo], range: normalRockRange, subRanges: 3)
            case .normal, .hard:
                return matchUp([.rat, .bat, .dragon, .alamo], range: normalRockRange, subRanges: 4)
            }
        case .boss, .tutorial1, .tutorial2:
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
        case .third:
            switch difficulty{
            case .easy:
                return 70
            case .normal:
                return 55
            case .hard:
                return 50
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
    
    static func availableAbilities(per levelType: LevelType, difficulty: Difficulty) -> [AnyAbility] {
        let abilities: [Ability] = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion(), TransmogrificationPotion(), KillMonsterPotion(), RockASwap()]
        
        //        switch levelType {
        //        case .first:
        //            switch difficulty {
        //            case .easy, .normal, .hard:
        //                abilities = [LesserHealingPotion(), Dynamite(), SwordPickAxe()]
        //            }
        //        case .second:
        //            switch difficulty {
        //            case .easy, .normal, .hard:
        //                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion()]
        //            }
        //        case .third:
        //            switch difficulty {
        //            case .easy, .normal, .hard:
        //                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion(), ShieldEast()]
        //            }
        //        case .boss, .tutorial1, .tutorial2:
        //            fatalError("Boss level not implemented yet")
        //        }
        
        return abilities.map { AnyAbility($0) }
    }
}
