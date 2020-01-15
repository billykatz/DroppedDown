//
//  LevelConstructor.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct LevelConstructor {
    static let monstersOnScreenDivisor = 2
    
    static func buildLevels(_ difficulty: Difficulty) -> [Level] {
        return LevelType.gameCases.map { levelType in
            let maxMonstersTotal = LevelConstructor.maxMonstersTotalPer(levelType, difficulty: difficulty)
            let maxMonstersOnScreen = maxMonstersTotal/LevelConstructor.monstersOnScreenDivisor
            return Level(type: levelType,
                         monsterRatio: monstersPerLevel(levelType, difficulty: difficulty),
                         maxMonstersTotal: maxMonstersTotal,
                         maxMonstersOnScreen: maxMonstersOnScreen,
                         maxGems: 1,
                         maxTime: timePer(levelType, difficulty: difficulty),
                         boardSize: boardSize(per: levelType, difficulty: difficulty),
                         abilities: availableAbilities(per: levelType, difficulty: difficulty),
                         goldMultiplier: difficulty.goldMultiplier,
                         rocksRatio: availableRocksPerLevel(levelType, difficulty: difficulty))
        }
    }
    
    static func buildTutorialLevels() -> [Level] {
        return (0..<LevelType.tutorialCases.count).map { index in
            Level(type: LevelType.tutorialCases[index],
                  monsterRatio: [:],
                  maxMonstersTotal: 0,
                  maxMonstersOnScreen: 0,
                  maxGems: 0,
                  maxTime: 0,
                  boardSize: 4,
                  abilities: [],
                  goldMultiplier: 1,
                  rocksRatio: [:],
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
            var rocks = matchUp([.redRock, .blueRock, .purpleRock], range: normalRockRange, subRanges: 3)
            rocks[.greenRock] = normalRockRange.next(10)
            return rocks
        case .second:
            var rocks = matchUp([.redRock, .blueRock, .purpleRock], range: normalRockRange, subRanges: 3)
            rocks[.greenRock] = normalRockRange.next(10)
            return rocks
        case .third:
            var rocks = matchUp([.redRock, .blueRock, .purpleRock, .brownRock], range: normalRockRange, subRanges: 4)
            rocks[.greenRock] = normalRockRange.next(10)
            return rocks
        case .boss, .tutorial1, .tutorial2:
            fatalError("Gotta do boss and or not call this for tutorial")
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
                return matchUp([.rat, .bat, .alamo], range: normalRockRange, subRanges: 3)
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
                return matchUp([.wizard, .bat, .dragon, .alamo, .lavaHorse], range: normalRockRange, subRanges: 5)
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
    }
    
    static func maxMonstersTotalPer(_ levelType: LevelType, difficulty: Difficulty) -> Int {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return 6
            case .normal:
                return 12
            case .hard:
                return 20
            }
        case .second:
            switch difficulty{
            case .easy:
                return 8
            case .normal:
                return 15
            case .hard:
                return 25
            }
        case .third:
            switch difficulty{
            case .easy:
                return 10
            case .normal:
                return 20
            case .hard:
                return 30
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
        var abilities: [Ability] = []
        switch levelType {
        case .first:
            switch difficulty {
            case .easy, .normal, .hard:
                abilities = [LesserHealingPotion(), Dynamite(), SwordPickAxe()]
            }
        case .second:
            switch difficulty {
            case .easy, .normal, .hard:
                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion()]
            }
        case .third:
            switch difficulty {
            case .easy, .normal, .hard:
                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion(), ShieldEast()]
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
        
        return abilities.map { AnyAbility($0) }
    }
}
