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
                         monsters: monstersPerLevel(levelType, difficulty: difficulty),
                         maxMonstersTotal: maxMonstersTotal,
                         maxMonstersOnScreen: maxMonstersOnScreen,
                         maxGems: 1,
                         maxTime: timePer(levelType, difficulty: difficulty),
                         boardSize: 8,
                         abilities: availableAbilities(per: levelType, difficulty: difficulty),
                         goldMultiplier: difficulty.goldMultiplier)
        }
    }
    
    static func buildTutorialLevels() -> [Level] {
        return (0..<LevelType.tutorialCases.count).map { index in
            Level(type: LevelType.tutorialCases[index],
                  monsters: [:],
                  maxMonstersTotal: 0,
                  maxMonstersOnScreen: 0,
                  maxGems: 0,
                  maxTime: 0,
                  boardSize: 4,
                  abilities: [],
                  goldMultiplier: 1,
                  tutorialData: GameScope.shared.tutorials[index])
        }
    }
    
    static func monstersPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: Double] {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.5, .bat: 0.5]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .alamo: 0.33]
            }
        case .second:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .dragon: 0.33]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.25, .bat: 0.25, .dragon: 0.25, .alamo: 0.25]
            }
        case .third:
            switch difficulty{
            case .easy:
                return [.bat: 0.25, .dragon: 0.25, .alamo: 0.25, .wizard: 0.25]
            case .normal, .hard:
                return [.bat: 0.20, .dragon: 0.20, .alamo: 0.20, .wizard: 0.20, .lavaHorse: 0.20]
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
