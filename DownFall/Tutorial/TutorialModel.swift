//
//  TutorialModel.swift
//  DownFall
//
//  Created by William Katz on 11/26/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

class TutorialData {
    let steps: [TutorialStep]
    var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    var lastStep: TutorialStep? {
        return steps.last
    }
    
    var finished: Bool {
        return steps.filter { !$0.completed }.count == 0
    }
    
    init(steps: [TutorialStep]) {
        self.steps = steps
    }
    
    var currentStep: TutorialStep {
        return step(stepIndex: currentIndexPath.item)
    }
    
    func incrStepIndex() {
        currentIndexPath = IndexPath(item: min(currentIndexPath.item + 1, steps.count - 1), section: currentIndexPath.section)
    }
    
    func countStepsIn() -> Int {
        return steps.count
    }
    
    func step(stepIndex: Int) -> TutorialStep {
        guard stepIndex < steps.count else { fatalError() }
        return steps[stepIndex]
    }
    
}

class TutorialStep: Equatable {
    static func == (lhs: TutorialStep, rhs: TutorialStep) -> Bool {
        return lhs.dialog == rhs.dialog
    }
    
    var dialog: String
    var highlightType: [TileType] = []
    var showFinger: Bool = false
    var showClockwiseRotate: Bool = false
    var showCounterClockwiseRotate: Bool = false
    var highlightCoordinates: [TileCoord] = []
    
    // a flag indicate if we should display text "tap to continue"
    var tapToContinue: Bool = false
    
    // the input that allows users to move to the next step
    var inputToContinue: InputType
    var inputToEnter: InputType?
    
    var started: Bool = false
    var completed: Bool = false
    
    init(dialog: String,
         highlightType: [TileType] = [],
         showClockwiseRotate: Bool = false,
         showCounterClockwiseRotate: Bool = false,
         highlightCoordinates: [TileCoord] = [],
         tapToContinue: Bool = false,
         inputToContinue: InputType,
         inputToEnter: InputType? = nil,
         started: Bool = false,
         completed: Bool = false,
         showFinger: Bool = false)
    {
        self.dialog = dialog
        self.highlightType = highlightType
        self.showClockwiseRotate = showClockwiseRotate
        self.showCounterClockwiseRotate = showCounterClockwiseRotate
        self.highlightCoordinates = highlightCoordinates
        self.tapToContinue = tapToContinue
        self.inputToContinue = inputToContinue
        self.started = started
        self.completed = completed
        self.showFinger = showFinger
    }
    
    static var zero: TutorialStep {
        return TutorialStep(dialog: "Zeroth step", inputToContinue: .play)
    }
}


extension TutorialStep: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(dialog)
    }
}

