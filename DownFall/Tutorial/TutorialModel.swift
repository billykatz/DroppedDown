//
//  TutorialModel.swift
//  DownFall
//
//  Created by William Katz on 11/26/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

extension IndexPath {
    mutating func incrStepIndex() {
        self = IndexPath(item: item+1, section: section)
    }

    mutating func incrSectionIndex() {
        self = IndexPath(item: item, section: section+1)
    }
}

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
    
    func incrSectionIndex() {
        //make sure we dont go out of bounds
        if currentSection < sections.count - 1 {
            currentIndexPath.incrSectionIndex()
            currentIndexPath = IndexPath(item: 0, section: currentIndexPath.section)
        }
    }
    
    func incrStepIndex() {
        currentIndexPath.incrStepIndex()
        if currentIndexPath.item >= countStepsIn(sectionIndex: currentIndexPath.section) {
            currentIndexPath = IndexPath(item: currentIndexPath.item - 1, section: currentIndexPath.section)
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

