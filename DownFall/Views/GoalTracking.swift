//
//  GoalTracking.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct GoalTracking: Codable, Hashable {
    let tileType: TileType
    let current: Int
    let target: Int
    let levelGoalType: LevelGoalType
    let minimumAmount: Int
    let grouped: Bool
    let hasBeenRewarded: Bool
    let orderCompleted: Int
    let index: Int
    
    func update(with units: Int) -> GoalTracking {
        var updatedInitial = current
        if units >= minimumAmount {
            if grouped {
                updatedInitial = min(target, current+1)
            } else {
                updatedInitial = min(target, current+units)
            }
        }
        return GoalTracking(tileType: tileType, current: updatedInitial, target: target, levelGoalType: levelGoalType, minimumAmount: minimumAmount, grouped: grouped, hasBeenRewarded: hasBeenRewarded, orderCompleted: orderCompleted, index: index)
    }
    
    func isAwarded(orderCompleted: Int) -> GoalTracking {
        return GoalTracking(tileType: tileType, current: current, target: target, levelGoalType: levelGoalType, minimumAmount: minimumAmount, grouped: grouped, hasBeenRewarded: true, orderCompleted: orderCompleted, index: index)
    }
    
    func textureName() -> String {
        var goalKeyTextureName: String {
            switch levelGoalType {
                case .unlockExit:
                    switch tileType {
                    case .rock:
                        return tileType.textureString()
                    case .monster:
                        return "skullAndCrossbones"
                    case .gem:
                        return "crystals"
                    case .pillar:
                        return "allSinglePillars"
                    default:
                        return ""
                    }
            case .useRune:
                return "blankRune"
            case .destroyBoss:
                return "skullAndCrossbones"
            }
        }
        
        return goalKeyTextureName
    }

    func description() -> String {
        var goalKeyDescription: String {
            switch levelGoalType {
            case .unlockExit:
                switch tileType {
                case .rock(let color, _, _):
                    if grouped {
                        return "Mine \(target) groups of at least \(minimumAmount) rocks"
                    } else {
                        return "Mine \(target) \(color.humanReadable.lowercased()) rocks"
                    }
                case .monster:
                    return "Destroy \(target) monster\(target > 1 ? "s" : "")"
                case .gem:
                    return "Collect \(target) gem\(target > 1 ? "s" : "")"
                case .pillar:
                    return "Destroy \(target) individual pillar\(target > 1 ? "s" : "")"
                default:
                    return ""
                }
            case .useRune:
                return "Use runes \(target) time\(target > 1 ? "s" : "")"
            case .destroyBoss:
                return "Defeat the boss on depth 10"
            }
        }
        
        return goalKeyDescription
    }
    
    var progressDescription: String {
        return "\(current) / \(target)"
    }
    
    var fillBarColor: (UIColor, UIColor) {
        switch levelGoalType {
        case .unlockExit:
            switch self.tileType {
            case .rock(.blue, _, _):
                return (.lightBarBlue, .darkBarBlue)
            case .rock(.red, _, _):
                return (.lightBarRed, .darkBarRed)
            case .rock(.purple, _, _):
                return (.lightBarPurple, .darkBarPurple)
            case .rock(.brown, _, _):
                return (.lightBarBrown, .darkBarBrown)
            case .monster:
                return (.lightBarMonster, .darkBarMonster)
            case .gem:
                return (.lightBarGem, .darkBarGem)
            case .pillar:
                return (.lightBarPillar, .darkBarPillar)
            default:
                return (.clear, .clear)
            }
        case .useRune:
            return (.lightBarRune, .darkBarRune)
        case .destroyBoss:
            return (.lightBarMonster, .darkBarMonster)
        }
    }
    
    var isCompleted: Bool {
        return current == target
    }

}
