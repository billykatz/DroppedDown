//
//  TutorialModel.swift
//  DownFall
//
//  Created by William Katz on 11/26/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

class TutorialData {
    let sections: [TutorialSection]
    var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    init(sections: [TutorialSection]) {
        self.sections = sections
    }
    
    var currentStep: TutorialStep {
        return step(sectionIndex: currentIndexPath.section, stepIndex: currentIndexPath.item)
    }
    
    var currentSection: Int {
        return currentIndexPath.section
    }
    
    /// Try to increment that section index.
    /// Note: If the currentSection is the last section this resets the index to be the last item in the last section
    func incrSectionIndex() {
        //make sure we dont go out of bounds
        if currentSection < sections.count - 1 {
            currentIndexPath.incrSectionIndex()
            currentIndexPath = IndexPath(item: 0, section: currentIndexPath.section)
        } else {
            // lets reset the item index to be in bounds
            currentIndexPath = IndexPath(item: currentIndexPath.item - 1, section: currentIndexPath.section)
        }
    }
    
    func incrStepIndex() {
        currentIndexPath.incrStepIndex()
        if currentIndexPath.item >= countStepsIn(sectionIndex: currentIndexPath.section) {
            // NOTE: This may not increment the section index because we dont increment when there are no sections left
            incrSectionIndex()
        }
        
    }
    
    func countStepsIn(sectionIndex: Int) -> Int {
        guard sectionIndex < sections.count else { return 0 }
        return sections[sectionIndex].steps.count
    }
    
    func step(sectionIndex: Int, stepIndex: Int) -> TutorialStep {
        guard sectionIndex < sections.count else { fatalError() }
        guard stepIndex < sections[sectionIndex].steps.count else { fatalError() }
        
        return sections[sectionIndex].steps[stepIndex]
    }

}

struct TutorialSection: Equatable {
    let steps: [TutorialStep]
}

struct TutorialStep: Equatable, Hashable {
    var dialog: String
    var highlightType: [TileType]
    var showClockwiseRotate: Bool = false
    var showCounterClockwiseRotate: Bool = false
    
    // a flag indicate if we should display text "tap to continue"
    var tapToContinue: Bool = false
    
    // the input that allows users to move to the next step
    var inputToContinue: InputType
    
    static var zero: TutorialStep {
        return TutorialStep(dialog: "", highlightType: [], inputToContinue: .play)
    }
}

