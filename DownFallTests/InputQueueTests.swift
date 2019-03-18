//
//  InputQueueTests.swift
//  DownFallTests
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

private protocol Resets {
    static var queue: [Input] { get set }
    static var bufferQueue: [Input] { get set }
    static var gameState: GameState { get set }
    static func resetGameState()
}

extension InputQueue: Resets {
    static func resetGameState() {
        queue = []
        bufferQueue = []
        gameState = .playing
    }
}

/// The purpose of these tests is to verfiy our state machine
/// There are 5 nodes or states represented in the GameState enum type
/// There are 12 edges or inputs represented in the InputType enum
/// Depending on the state there are rules describing:
///    - what edges exist between nodes
///    - if and where we append incoming input
///    - if and when we can pop outgoing input
/// The following is a graphical representation of our FSM
/*
 
                            DroppedDown's Finite State Machine
 
       Input: playAgain
+-------^---------------------+
|       |                     |
|  +----+----+  Inputs:       |
|  |         |  gameLose      |                   Inputs: animationsFinished
|  |Game Lose+<-------------+ |  +----------------------------------------------------------------------+
|  |         |              | |  |                                                                      |
|  +---------+              | |  |                                                                      |
|                           | |  |                                                                      |
|                           | v  v                                                                      |
|  +---------+  Inputs:  +--+-+--+-----+                                                         +------+-----+
|  |         |  gameWin  |             |      Inputs: touch, monsterAttach, monsterDies,         |            |
+--+ Game Win+<----------+  Playing    +-------------------------------------------------------->+ Animating  |
   |         |           |             |      rotateRight, rotateLeft, playerAttack              |            |
   +---------+           +-+--------+--+                                                         +------------+
                           |        ^
                           |        |
                           |        |
                   Inputs: |        |Inputs:
                   pause   |        |play
                           |        |
                           |        |
                           v        |
                         +-+--------+--+
                         |             |
                         |   Pause     |
                         |             |
                         +-------------+
 */







class InputQueueTests: XCTestCase {
    let pause = Input(.pause, true)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        InputQueue.resetGameState()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInputQueuePause() {
        InputQueue.append(pause)
        let _ = InputQueue.pop()
        
        for inputType in InputType.allCases {
            XCTAssertTrue(InputQueue.gameState == .paused)
            
            InputQueue.gameState = InputQueue.gameState(given: Input(inputType, false))
            switch inputType{
            case .play:
               XCTAssertTrue(InputQueue.gameState == .playing)
            default:
                XCTAssertTrue(InputQueue.gameState == .paused, "\(inputType) traversed from .paused To \(InputQueue.gameState)")
            }
            
            //Reset before the next test
            InputQueue.gameState = .paused
        }
        
    }

}
