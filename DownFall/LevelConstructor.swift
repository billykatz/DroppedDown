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
    
    static func buildLevels(_ difficulty: Difficulty) -> [Level]? {
        if difficulty == .tutorial1 || difficulty == .tutorial2 { return [Level.zero] }
        var levels: [Level] = []
        for levelType in LevelType.allCases {
            switch levelType {
            case .first, .second, .third:
                let maxMonstersTotal = LevelConstructor.maxMonstersTotalPer(levelType, difficulty: difficulty)
                let maxMonstersOnScreen = maxMonstersTotal/LevelConstructor.monstersOnScreenDivisor
                levels.append(
                    Level(type: levelType,
                          monsters: monstersPerLevel(levelType, difficulty: difficulty),
                          maxMonstersTotal: maxMonstersTotal,
                          maxMonstersOnScreen: maxMonstersOnScreen,
                          maxGems: 1,
                          maxTime: timePer(levelType, difficulty: difficulty),
                          boardSize: 8,
                          abilities: availableAbilities(per: levelType, difficulty: difficulty))
                )
            case .tutorial1, .tutorial2, .boss:
                levels.append(Level.zero)
            }
            
        }
        return levels
    }
    
    static func monstersPerLevel(_ levelType: LevelType, difficulty: Difficulty) -> [EntityModel.EntityType: Double] {
        switch levelType {
        case .first:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.5, .bat: 0.5]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .alamo: 0.33]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return [EntityModel.EntityType.rat: 0.33, .bat: 0.33, .dragon: 0.33]
            case .normal, .hard:
                return [EntityModel.EntityType.rat: 0.25, .bat: 0.25, .dragon: 0.25, .alamo: 0.25]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return [.bat: 0.25, .dragon: 0.25, .alamo: 0.25, .wizard: 0.25]
            case .normal, .hard:
                return [.bat: 0.20, .dragon: 0.20, .alamo: 0.20, .wizard: 0.20, .lavaHorse: 0.20]
            default:
                fatalError("Dont call this to create tutorial levels")
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
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return 8
            case .normal:
                return 15
            case .hard:
                return 25
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return 10
            case .normal:
                return 20
            case .hard:
                return 30
            default:
                fatalError("Dont call this to create tutorial levels")
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
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty{
            case .easy:
                return 60
            case .normal:
                return 50
            case .hard:
                return 45
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty{
            case .easy:
                return 70
            case .normal:
                return 55
            case .hard:
                return 50
            default:
                fatalError("Dont call this to create tutorial levels")
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
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .second:
            switch difficulty {
            case .easy, .normal, .hard:
                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion()]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .third:
            switch difficulty {
            case .easy, .normal, .hard:
                abilities = [LesserHealingPotion(), Dynamite(), GreaterHealingPotion(), ShieldEast()]
            default:
                fatalError("Dont call this to create tutorial levels")
            }
        case .boss, .tutorial1, .tutorial2:
            fatalError("Boss level not implemented yet")
        }
        
        return abilities.map { AnyAbility($0) }
    }
}
