//
//  TutorialModelTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft

class TutorialModelTests: XCTestCase {
    
    static let first = TutorialStep(dialog: "First",
                                    highlightType: [],
                                    inputToContinue: InputType.tutorial(.zero))
    
    static let second = TutorialStep(dialog: "Second",
                                     highlightType: [],
                                     inputToContinue: InputType.tutorial(.zero))
    
    static let third = TutorialStep(dialog: "Third",
                                    highlightType: [],
                                    inputToContinue: InputType.tutorial(.zero))
    
    static let fourth = TutorialStep(dialog: "Fourth",
                                     highlightType: [TileType.rock(.blue)],
                                     inputToContinue: InputType.tutorial(.zero))
    static let fifth = TutorialStep(dialog: "Fifth",
                                    highlightType: [.gold],
                                    inputToContinue: InputType.tutorial(.zero))
    static let sixth = TutorialStep(dialog: "Sixth",
                                    highlightType: [.player(.zero)],
                                    inputToContinue: InputType.tutorial(.zero))
    
    static let tutorial = TutorialData(steps:
            [
                TutorialModelTests.first,
                TutorialModelTests.second,
                TutorialModelTests.third,
                TutorialModelTests.fourth,
                TutorialModelTests.fifth,
                TutorialModelTests.sixth
        ]
    )

    
    func testIncrStep() {
        let tutorialData = TutorialModelTests.tutorial
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.first)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.second)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.third)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.fourth)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.fifth)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.sixth)
        
        
        // Once we reach the last index we should stay at the last index
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.sixth)
    }
}
