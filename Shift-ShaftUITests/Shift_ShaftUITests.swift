//
//  Shift_ShaftUITests.swift
//  Shift-ShaftUITests
//
//  Created by Billy on 2/26/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.tap()
    }
}

class Shift_ShaftUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest"]
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        
        
        
        let app = XCUIApplication()
    
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        app.buttons["Start Run"].tap()
        app.otherElements["levelGoalView"].tap()

                                                                
        snapshot("01FirstLevel")
        
        
    }
    
//    func testExample2() throws {
//        
//        
//        
//        
//        
//    }
//

}
