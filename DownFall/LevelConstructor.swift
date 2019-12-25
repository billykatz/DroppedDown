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
                         boardSize: 8,
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
    
    static func availableRocksPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [TileType: RangeModel] {
        let normalRockRange = RangeModel(lower: 0, upper: 90)
        switch levelType {
        case .first:
            let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(3)
            return [.redRock: dividedRockRanges[0],
                    .blueRock: dividedRockRanges[1],
                    .purpleRock: dividedRockRanges[2],
                    .greenRock: dividedRockRanges[2].next(10)]
        case .second:
            let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(4)
            return [.redRock: dividedRockRanges[0],
                    .blueRock: dividedRockRanges[1],
                    .purpleRock: dividedRockRanges[2],
                    .brownRock: dividedRockRanges[3],
                    .greenRock: dividedRockRanges[3].next(10)]
        case .third:
            let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(5)
            return [.redRock: dividedRockRanges[0],
                    .blueRock: dividedRockRanges[1],
                    .purpleRock: dividedRockRanges[2],
                    .brownRock: dividedRockRanges[3],
                    .blackRock: dividedRockRanges[4],
                    .greenRock: dividedRockRanges[4].next(10)]
        case .boss, .tutorial1, .tutorial2:
            fatalError("Gotta do boss and or not call this for tutorial")
        }
    }
    
    static func monstersPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: RangeModel] {
        let normalRockRange = RangeModel(lower: 0, upper: 100)
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(2)
                return [.rat: dividedRockRanges[0],
                        .bat: dividedRockRanges[1]]
            case .normal, .hard:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(3)
                return [.rat: dividedRockRanges[0],
                        .bat: dividedRockRanges[1],
                        .alamo: dividedRockRanges[2]]
            }
        case .second:
            switch difficulty{
            case .easy:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(3)
                return [.rat: dividedRockRanges[0],
                        .bat: dividedRockRanges[1],
                        .dragon: dividedRockRanges[2]]
            case .normal, .hard:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(4)
                return [.rat: dividedRockRanges[0],
                        .bat: dividedRockRanges[1],
                        .dragon: dividedRockRanges[2],
                        .alamo: dividedRockRanges[3]]
            }
        case .third:
            switch difficulty{
            case .easy:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(4)
                return [.bat: dividedRockRanges[0],
                        .dragon: dividedRockRanges[1],
                        .alamo: dividedRockRanges[2],
                        .wizard: dividedRockRanges[3]]
            case .normal, .hard:
                let dividedRockRanges = normalRockRange.divivdedIntoSubRanges(5)
                return [.bat: dividedRockRanges[0],
                        .dragon: dividedRockRanges[1],
                        .alamo: dividedRockRanges[2],
                        .wizard: dividedRockRanges[3],
                        .lavaHorse: dividedRockRanges[4]]
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
