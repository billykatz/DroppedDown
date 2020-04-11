//
//  LevelGoalTracker.swift
//  DownFall
//
//  Created by Katz, Billy on 4/4/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct GoalTracking {
    let initial: Int
    let target: Int
    let levelGoalType: LevelGoalType
    
    func update(with units: Int) -> GoalTracking {
        return GoalTracking(initial: min(target, initial+units), target: target, levelGoalType: levelGoalType)
    }
}

protocol LevelGoalTrackingOutputs {
    var goalUpdated: ((TileType, GoalTracking) -> ())? { get set }
    var goalProgress: [TileType: GoalTracking] { get }
}

protocol LevelGoalTracking: LevelGoalTrackingOutputs {}

class LevelGoalTracker: LevelGoalTracking {
    
    public var goalUpdated: ((TileType, GoalTracking) -> ())? = nil
    public var goalProgress: [TileType: GoalTracking] = [:]
    
    private let level: Level
    
    init(level: Level) {
        self.level = level
        var goalProgress: [TileType: GoalTracking] = [:]
        for goal in level.goals {
            for (key, value) in goal.typeAmounts {
                goalProgress[key] = GoalTracking(initial: 0, target: value, levelGoalType: goal.type)
            }
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
        default:
            return
        }
    }
    
    private func unlockExit() {
        var finished = false
        for (_, goal) in goalProgress {
            if goal.levelGoalType == .unlockExit {
                finished = goal.initial == goal.target
            }
        }
        if finished {
            InputQueue.append(Input(.unlockExit))
        }
    }
    
    /// Determines if the transformation advances the level goal
    private func trackLevelGoal(with trans: [Transformation]) {
        if let first = trans.first,
            case InputType.touch(_, let type)? = first.inputType,
            let firstRemovedCount = first.tileTransformation?.first?.count,
            firstRemovedCount > 0 {
            advanceGoal(for: type, units: firstRemovedCount)
        }
    }
    
    private func advanceGoal(for type: TileType, units: Int) {
        let newGoalTracker = goalProgress[type]?.update(with: units)
        goalProgress[type] = newGoalTracker
        guard let updatedGoalTracker = newGoalTracker else { return }
        goalUpdated?(type, updatedGoalTracker)
    }
}
