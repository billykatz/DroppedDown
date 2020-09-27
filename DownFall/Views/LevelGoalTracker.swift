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
            goalProgress.append(GoalTracking(tileType: goal.tileType, current: 0, target: goal.targetAmount, levelGoalType: goal.type, minimumAmount: goal.minimumGroupSize, grouped: goal.grouped, hasBeenRewarded: false))
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
            countPillars(in: input.endTilesStruct ?? [])
            InputQueue.append(Input(.levelGoalDetail(goalProgress)))
        case .itemUsed:
            advanceRuneUseGoal()
        default:
            return
        }
    }
    
    private func checkForCompletedGoals() {
        var completedUnAwardedGoals: [GoalTracking] = []
        for (idx, goal) in goalProgress.enumerated(){
            if goal.isCompleted && !goal.hasBeenRewarded {
                goalProgress[idx] = goal.isAwarded()
                completedUnAwardedGoals.append(goal)
            }
        }
        
        guard !completedUnAwardedGoals.isEmpty else { return }
        InputQueue.append(Input(.goalCompleted(completedUnAwardedGoals)))
    }
    
    var pillarColor =  Set<Color>(Color.allCases)
    var numberOfIndividualPillars: Int = 0
    
    private func countPillars(in tiles: [[Tile]]) {
        var positions = Set<TileCoord>()
        for color in pillarColor {
            for health in 1...3 {
                positions = positions.union(getTilePositions(.pillar(PillarData(color: color, health: health)), tiles: tiles) ?? Set<TileCoord>())
            }
        }
        pillarColor = Set<Color>()
        var newNumberOfIndividualPillars = 0
        for position in positions {
            if case let TileType.pillar(data) = tiles[position].type {
                newNumberOfIndividualPillars += data.health
                pillarColor.insert(data.color)
            }
        }
        
        if numberOfIndividualPillars - newNumberOfIndividualPillars != 0 {
            advanceGoal(for: .pillar(PillarData(color: .blue, health: 3)), units: numberOfIndividualPillars - newNumberOfIndividualPillars)
        }
        numberOfIndividualPillars = newNumberOfIndividualPillars
    }
    
    /// Determines if the transformation advances the level goal
    private func trackLevelGoal(with trans: [Transformation]) {
        if let inputType = trans.first?.inputType {
            switch inputType {
            case InputType.touch(_, let type):
                if let count = trans.first?.tileTransformation?.first?.count {
                    advanceGoal(for: type, units: count)
                }
                countPillars(in: trans.first?.endTiles ?? [])
            case .monsterDies(_, let type):
                advanceGoal(for: .monster(EntityModel.zeroedEntity(type: type)), units: 1)
            case .collectItem(_, let item, _):
                advanceGoal(for: TileType.item(item), units: item.amount)
            default:
                ()
            }
        }
    }
    
    private func advanceRuneUseGoal() {
        var newGoalProgess: [GoalTracking] = []
        for goal in goalProgress {
            if goal.levelGoalType == .useRune {
                let newGoalTracker = goal.update(with: 1)
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
