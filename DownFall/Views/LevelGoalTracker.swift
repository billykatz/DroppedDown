//
//  LevelGoalTracker.swift
//  DownFall
//
//  Created by Katz, Billy on 4/4/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Combine

protocol LevelGoalTrackingInputs {
    func viewWasTapped()
}

protocol LevelGoalTrackingOutputs {
//    var goalUpdated: (([GoalTracking]) -> ())? { get set }
    var goalProgress: [GoalTracking] { get }
    
    /// Emits the a value when there is a goal that has been completed
    var goalCompleted: AnyPublisher<([GoalTracking]), Error> { get }
    
    /// Emits a value when a goal is updated
    var goalIsUpdated: AnyPublisher<[GoalTracking], Error> { get }
}

protocol LevelGoalTracking: LevelGoalTrackingOutputs, LevelGoalTrackingInputs {}

class LevelGoalTracker: LevelGoalTracking {

    public lazy var goalCompleted: AnyPublisher<([GoalTracking]), Error> = goalCompletedSubject.eraseToAnyPublisher()
    private lazy var goalCompletedSubject = PassthroughSubject<([GoalTracking]), Error>()
    
    public lazy var goalIsUpdated: AnyPublisher<[GoalTracking], Error> = goalIsUpdatedSubject.eraseToAnyPublisher()
    private lazy var goalIsUpdatedSubject = PassthroughSubject<[GoalTracking], Error>()
    
    public var goalProgress: [GoalTracking] = []
    
    private let level: Level
    private var pillarColor =  Set<Color>(Color.allCases)
    private var numberOfIndividualPillars: Int = 0
    private var numberOfGoalsCompleted = 0
    
    init(level: Level) {
        self.level = level
        
        // grab the current progress because the level could be saved
        self.goalProgress = level.goalProgress
        
        var index = self.goalProgress.count
        
        /// there may be goals in the level that we havent progress in yet, we need to add those
        if self.goalProgress.count != level.goals.count {
            /// add any other goals where the goal type and goal tile type are the same
            for goal in level.goals {
                /// if we do not have any saved progress for a goal, then we must add it
                if !self.goalProgress.contains(where: { innerGoal in
                    return (innerGoal.levelGoalType, innerGoal.tileType) == (goal.type, goal.tileType)
                }) {
                    self.goalProgress.append(GoalTracking(tileType: goal.tileType, current: 0, target: goal.targetAmount, levelGoalType: goal.type, minimumAmount: goal.minimumGroupSize, grouped: goal.grouped, hasBeenRewarded: false, orderCompleted: 0, index: index))
                    index += 1;
                }
            }
        }
        
        numberOfGoalsCompleted = self.goalProgress.map { $0.orderCompleted }.max() ?? 0
        
        Dispatch.shared.register { [weak self] (input) in
            self?.handle(input: input)
        }
    }
    
    func viewWasTapped() {
        InputQueue.append(Input(.levelGoalDetail(goalProgress)))
    }
    
    
    private func handle(input: Input) {
        switch input.type {
        case .transformation(let trans):
            trackLevelGoal(with: trans)
            
        case .newTurn:
            checkForCompletedGoals()
            
        case .boardBuilt, .boardLoaded:
            goalIsUpdatedSubject.send(goalProgress)
            countPillars(in: input.endTilesStruct ?? [])
            InputQueue.append(Input(.levelGoalDetail(goalProgress)))
            
        case .itemUsed:
            advanceRuneUseGoal()
            
        case .goalCompleted(let completedGoals, _):
            goalCompletedSubject.send(completedGoals)
            
        default:
            return
        }
    }
    
    private func checkForCompletedGoals() {
        var completedUnAwardedGoals: [GoalTracking] = []
        var allGoalsCompleted = true
        for (idx, goal) in goalProgress.enumerated(){
            if goal.isCompleted && !goal.hasBeenRewarded {
                
                numberOfGoalsCompleted += 1
                
                // update the data model
                goalProgress[idx] = goal.isAwarded(orderCompleted: numberOfGoalsCompleted)
                
                // keep track to send in input later
                completedUnAwardedGoals.append(goalProgress[idx])
            }
            
            if !goal.isCompleted {
                allGoalsCompleted = false
            }
        }
        
        guard !completedUnAwardedGoals.isEmpty else { return }
        
        // send input saying that goals were completed
        InputQueue.append(Input(.goalCompleted(completedUnAwardedGoals, allGoalsCompleted: allGoalsCompleted)))
    }
    
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
                if let count = trans.first?.removed?.count {
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
            goalIsUpdatedSubject.send(goalProgress)
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
            goalIsUpdatedSubject.send(goalProgress)
        }
    }
}
