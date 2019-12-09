//
//  TutorialModelTests.swift
//  DownFallTests
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

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
                                     highlightType: [.blackRock],
                                     inputToContinue: InputType.tutorial(.zero))
    static let fifth = TutorialStep(dialog: "Fifth",
                                    highlightType: [.gold],
                                    inputToContinue: InputType.tutorial(.zero))
    static let sixth = TutorialStep(dialog: "Sixth",
                                    highlightType: [.player(.zero)],
                                    inputToContinue: InputType.tutorial(.zero))
    
    static let firstSection = TutorialSection(steps:
        [
            TutorialModelTests.first,
            TutorialModelTests.second,
            TutorialModelTests.third
        ]
    )
    
    static let secondSection = TutorialSection(steps:
        [
            TutorialModelTests.fourth,
            TutorialModelTests.fifth,
            TutorialModelTests.sixth
        ]
    )
    
    
    static var tutorialSections: [TutorialSection] =
        [
            firstSection,
            secondSection
    ]
    
    func testIncrStep() {
        let tutorialData = TutorialData(sections: TutorialModelTests.tutorialSections)

        var expectedCurrentSection = 0
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.first)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.second)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.third)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        tutorialData.incrStepIndex()
        expectedCurrentSection = 1
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.fourth)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.fifth)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.sixth)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
        
        
        // Once we reach the last index we should stay at the last index
        tutorialData.incrStepIndex()
        
        XCTAssertEqual(tutorialData.currentStep, TutorialModelTests.sixth)
        XCTAssertEqual(tutorialData.currentSection, expectedCurrentSection)
    }
}
