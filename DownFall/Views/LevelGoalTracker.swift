//
//  LevelGoalTracker.swift
//  DownFall
//
//  Created by Katz, Billy on 4/4/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

protocol LevelGoalTrackingOutputs {
    var goalUpdated: (([GoalTracking]) -> ())? { get set }
    var goalProgress: [GoalTracking] { get }
}

protocol LevelGoalTracking: LevelGoalTrackingOutputs {}

class LevelGoalTracker: LevelGoalTracking {
    
    public var goalUpdated: (([GoalTracking]) -> ())? = nil
    public var goalProgress: [GoalTracking] = []
    
    private let level: Level
    
    init(level: Level) {
        self.level = level
        var goalProgress: [GoalTracking] = []
        var count = 0
        for goal in level.goals {
            goalProgress.append(GoalTracking(tileType: goal.tileType, current: 0, target: goal.targetAmount, levelGoalType: goal.type, minimumAmount: goal.minimumGroupSize, grouped: goal.grouped, reward: goal.reward, hasBeenRewarded: false))
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
            checkForCompletedGoals()
            
        case .boardBuilt:
            goalUpdated?(goalProgress)
        case .visitStore:
            InputQueue.append(.init(.goalProgressRecord(goalProgress)))
        default:
            return
        }
    }
    
    private func checkForCompletedGoals() {
        var awardedGoals: [LevelGoalReward] = []
        for (idx, goal) in goalProgress.enumerated(){
            if goal.isCompleted && !goal.hasBeenRewarded {
                goalProgress[idx] = goal.isAwarded()
                awardedGoals.append(goal.reward)
            }
        }
        if !awardedGoals.isEmpty {
            InputQueue.append(Input(.playerAwarded(awardedGoals)))
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
            case .collectItem(_, let item, _):
                advanceGoal(for: TileType.item(item), units: item.amount)
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
