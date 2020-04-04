//
//  InputQueueTests.swift
//  DownFallTests
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest

@testable import Shift_Shaft

/// These tests are to verify the rules we enforced for
/// deciding when and where certain Input are queued

extension InputQueue {
    static func reset(to startingGameState: AnyGameState) {
        queue = []
        gameState = startingGameState
        
        
        XCTAssertEqual(InputQueue.gameState, gameState, "After reset, we start at \(gameState.state)")
        XCTAssertTrue(InputQueue.queue.isEmpty, "After reset, we have nothing in the input queue")
    }
}

class InputQueueTests: XCTestCase {
    let pause = Input(.pause)
    let playingState = AnyGameState(PlayState())
    let pauseState = AnyGameState(PauseState())
    let animatingState = AnyGameState(AnimatingState())
    let winState = AnyGameState(WinState())
    let loseState = AnyGameState(LoseState())
    let reffingState = AnyGameState(ReffingState())
    var gameStates: [AnyGameState] = []
    
    override func setUp() {
        gameStates = [pauseState,
                      playingState,
                      winState,
                      loseState,
                      animatingState]
    }

    func testInputQueueAppendsPause() {
        for gameState in gameStates {
            for inputType in InputType.allCases {
                
                InputQueue.reset(to: gameState)
                var input = Input(inputType)
                InputQueue.append(input)
                var expectedQueueCount = (gameState.shouldAppend(input) ? 1 : 0)
                XCTAssertEqual(InputQueue.queue.count, expectedQueueCount, "After appending \(input.type) in the \(gameState.state), our queue should have \(expectedQueueCount) input")
                
                
                InputQueue.reset(to: gameState)
                XCTAssertEqual(InputQueue.gameState, gameState, "After reset, we start at \(gameState.state)")
                XCTAssertTrue(InputQueue.queue.isEmpty, "After reset, we have nothing in the input queue")
                
                input = Input(inputType)
                InputQueue.append(input)
                expectedQueueCount = (gameState.shouldAppend(input) ? 1 : 0)
                XCTAssertEqual(InputQueue.queue.count, expectedQueueCount, "After appending \(input.type) in the \(gameState.state), our queue should have \(expectedQueueCount) input")
            }
        }
    }
    
    func testInputQueuePop() {
        func shouldPopOrNot(_ input: Input, gameState: AnyGameState) {
            InputQueue.reset(to: gameState)
            if gameState.shouldAppend(input) {
                InputQueue.append(input)
                XCTAssertEqual(InputQueue.queue.count, 1)
                if let popped = InputQueue.pop() {
                    XCTAssertEqual(InputQueue.queue.count, 0, "\(input) should be popped from \(gameState.state). \(popped) was popped")
                } else {
                    XCTAssertEqual(InputQueue.queue.count, 1)
                }
            }
        }
        
        for gameState in gameStates {
            for inputType in InputType.allCases {
                var input = Input(inputType)
                shouldPopOrNot(input, gameState: gameState)
                input = Input(inputType)
                shouldPopOrNot(input, gameState: gameState)
            }
        }
    }
}
