//
//  LevelGoalTracker.swift
//  DownFall
//
//  Created by Katz, Billy on 4/4/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct GoalTracking: Hashable {
    let tileType: TileType
    let current: Int
    let target: Int
    let levelGoalType: LevelGoalType
    let index: Int
    let minimumAmount: Int
    let grouped: Bool
    let reward: LevelGoalReward
    
    func update(with units: Int) -> GoalTracking {
        var updatedInitial = current
        if units >= minimumAmount {
            if grouped {
                updatedInitial = min(target, current+1)
            } else {
                updatedInitial = min(target, current+units)
            }
        }
        return GoalTracking(tileType: tileType, current: updatedInitial, target: target, levelGoalType: levelGoalType, index: index, minimumAmount: minimumAmount, grouped: grouped, reward: reward)
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

}

protocol LevelGoalTrackingOutputs {
    var goalUpdated: (([GoalTracking]) -> ())? { get set }
    var goalProgress: [GoalTracking] { get }
    var exitLocked: Bool { get }
    var numberOfExitGoals: Int { get }
}

protocol LevelGoalTracking: LevelGoalTrackingOutputs {}

class LevelGoalTracker: LevelGoalTracking {
    
    public var goalUpdated: (([GoalTracking]) -> ())? = nil
    public var goalProgress: [GoalTracking] = []
    
    private let level: Level
    
    /// Outuputs flase if the player has not reach the number of goals needed to unlock the exit
    var exitLocked: Bool {
        numberOfExitGoalsUnlocked < level.numberOfGoalsNeedToUnlockExit
    }
    
    /// Return the number of exit goals that the player has completed
    var numberOfExitGoalsUnlocked: Int {
        return goalProgress.filter { (goal) -> Bool in
            return goal.levelGoalType == LevelGoalType.unlockExit
                && goal.current == goal.target
        }.count

    }
    
    /// Returns the number of unlockExit goals there are on this level
    var numberOfExitGoals: Int {
        let exitGoals = goalProgress.filter { (goal) -> Bool in
            return goal.levelGoalType == LevelGoalType.unlockExit
        }
        return exitGoals.count
    }
    
    init(level: Level) {
        self.level = level
        var goalProgress: [GoalTracking] = []
        var count = 0
        for goal in level.goals {
            goalProgress.append(GoalTracking(tileType: goal.tileType, current: 0, target: goal.targetAmount, levelGoalType: goal.type, index: count, minimumAmount: goal.minimumGroupSize, grouped: goal.grouped, reward: goal.reward))
            count += 1
        }
        self.goalProgress = goalProgress
        
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input: input)
        }
    }
    
    private func handle(input: Input) {
        switch input.type {
        case .transformation(let trans):
            trackLevelGoal(with: trans)
            return
        case .newTurn:
            unlockExit()
        case .boardBuilt:
            goalUpdated?(goalProgress)
        default:
            return
        }
    }
    
    private func unlockExit() {
        if !exitLocked {
            InputQueue.append(Input(.unlockExit))
        }
    }
    
    /// Determines if the transformation advances the level goal
    private func trackLevelGoal(with trans: [Transformation]) {
        if let inputType = trans.first?.inputType {
            switch inputType {
            case InputType.touch(_, let type):
                if let count = trans.first?.tileTransformation?.first?.count {
                    advanceGoal(for: type, units: count)
                }
            case .monsterDies(_, let type):
                advanceGoal(for: .monster(EntityModel.zeroedEntity(type: type)), units: 1)
            default:
                ()
            }
        }
    }
    
    private func advanceGoal(for type: TileType, units: Int) {
        var newGoalProgess: [GoalTracking] = []
        for goal in goalProgress {
            if goal.tileType == type {
                let newGoalTracker = goal.update(with: units)
                newGoalProgess.append(newGoalTracker)
            } else {
                newGoalProgess.append(goal)
            }
        }
        if newGoalProgess != goalProgress {
            goalProgress = newGoalProgess
            goalUpdated?(goalProgress)
        }
    }
}
