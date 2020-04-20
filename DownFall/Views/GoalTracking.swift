//
//  GoalTracking.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct GoalTracking: Hashable {
    let tileType: TileType
    let current: Int
    let target: Int
    let levelGoalType: LevelGoalType
    let minimumAmount: Int
    let grouped: Bool
    let reward: LevelGoalReward
    let hasBeenRewarded: Bool
    
    func update(with units: Int) -> GoalTracking {
        var updatedInitial = current
        if units >= minimumAmount {
            if grouped {
                updatedInitial = min(target, current+1)
            } else {
                updatedInitial = min(target, current+units)
            }
        }
        return GoalTracking(tileType: tileType, current: updatedInitial, target: target, levelGoalType: levelGoalType, minimumAmount: minimumAmount, grouped: grouped, reward: reward, hasBeenRewarded: hasBeenRewarded)
    }
    
    func isAwarded() -> GoalTracking {
        return GoalTracking(tileType: tileType, current: current, target: target, levelGoalType: levelGoalType, minimumAmount: minimumAmount, grouped: grouped, reward: reward, hasBeenRewarded: true)
    }
    
    func textureName() -> String {
        var goalKeyTextureName: String {
            switch tileType {
            case .rock:
                return tileType.textureName
            case .monster:
                return "skullAndCrossbones"
            case .gem:
                return "gem2"
            default:
                return ""
            }
        }
        
        return goalKeyTextureName
    }

    func description() -> String {
        var goalKeyDescription: String {
            switch tileType {
            case .rock:
                if grouped {
                    return "Mine \(target) groups of \(minimumAmount) or more."
                } else {
                    return "Mine \(target) rocks."
                }
            case .monster:
                return "Destory \(target) monsters."
            case .gem:
                return "Collect \(target) gems."
            default:
                return ""
            }
        }
        
        return goalKeyDescription
    }
    
    var rewardTextureName: String {
        switch reward {
        case .gem:
            return "gem2"
        }
    }
    
    var rewardAmount: Int? {
        if case .gem(let amount) = reward {
            return amount
        }
        return nil
    }
    
    var progressDescription: String {
        return "\(current) / \(target)"
    }
    
    var fillBarColor: (UIColor, UIColor) {
        switch self.tileType {
        case .rock(.blue):
            return (.lightBarBlue, .darkBarBlue)
        case .rock(.red):
            return (.lightBarRed, .darkBarRed)
        case .rock(.purple):
            return (.lightBarPurple, .darkBarPurple)
        case .monster:
            return (.lightBarMonster, .darkBarMonster)
        case .gem:
            return (.lightBarGem, .darkBarGem)
        default:
            return (.clear, .clear)
        }
    }
    
    var isCompleted: Bool {
        return current == target
    }

}
