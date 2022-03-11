//
//  Shift_ShaftUITests.swift
//  Shift-ShaftUITests
//
//  Created by Billy on 2/26/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft

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
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testScreenshotMatchThree() throws {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest", "-isMatchThreeScreenshot"]
        app.launch()
    
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        app.buttons["Start Run"].tap()
        app.otherElements["levelGoalView"].tap()

                                                                
        snapshot("01MatchThree")
        
        
    }
    
    func testScreenshotRotate() throws {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest", "-isSwipeScreenshot"]
        app.launch()
        
        // start a run
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        app.buttons["Start Run"].tap()
        app.otherElements["levelGoalView"].tap()
        
        
        let exp = expectation(description: "Test after 10 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 10)
        if result == XCTWaiter.Result.timedOut {
            XCTAssert(true)
        } else {
            XCTFail("Delay interrupted")
        }
                
        
                                                                
        snapshot("02Rotate")
    }
    
    

    func testScreenshotPowerup() throws {

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest", "-isPowerUpScreenShot"]
        app.launch()
        
        let button = app.buttons["snapShotSwipe"]
        button.tap()

        
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        
        snapshot("03Powerup")
    }

    func testScreenshotUpgrade() throws {

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest", "-isPowerUpScreenShot"]
        app.launch()
        
        let button = app.buttons["snapShotSwipe"]
        button.tap()
        
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        app.buttons["Start Run"].tap()
        app.otherElements["levelGoalView"].tap()

        snapshot("04Upgrade")
    }

    func testScreenshotCrush() throws {

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-isUITest", "-isCrushScreenShot"]
        app.launch()
    
        let newgameButton = app.buttons["newGame"]
        newgameButton.tap()
        app.buttons["Start Run"].tap()
        app.otherElements["levelGoalView"].tap()

        
        snapshot("05Crush")
    }


}
