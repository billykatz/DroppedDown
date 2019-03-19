//
//  InputQueueTests.swift
//  DownFallTests
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall

/// These tests are to verify the rules we enforced for
/// deciding when and where certain Input are queued

extension InputQueue: Resets {
    static func reset(to startingGameState: AnyGameState) {
        queue = []
        bufferQueue = []
        gameState = startingGameState
        
        
        XCTAssertEqual(InputQueue.gameState, gameState, "After reset, we start at \(gameState.state)")
        XCTAssertTrue(InputQueue.queue.isEmpty, "After reset, we have nothing in the input queue")
        XCTAssertTrue(InputQueue.bufferQueue.isEmpty, "After reset, we have nothing in the buffer queue")
    }
}

class InputQueueTests: XCTestCase {
    let pause = Input(.pause, true)
    let playingState = AnyGameState(PlayState())
    let pauseState = AnyGameState(PauseState())
    let animatingState = AnyGameState(AnimatingState())
    let winState = AnyGameState(WinState())
    let loseState = AnyGameState(LoseState())
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
                var input = Input(inputType, false)
                InputQueue.append(input)
                var expectedQueueCount = (gameState.shouldAppend(input) ? 1 : 0)
                var expectedBufferCount = (gameState.shouldBuffer(input) ? 1 : 0)
                XCTAssertEqual(InputQueue.queue.count, expectedQueueCount, "After appending \(input.type) in the \(gameState.state), our queue should have \(expectedQueueCount) input")
                XCTAssertEqual(InputQueue.bufferQueue.count, expectedBufferCount, "After appending \(input.type) in the \(gameState.state), our buffer should have \(expectedBufferCount) input")
                
                
                InputQueue.reset(to: gameState)
                XCTAssertEqual(InputQueue.gameState, gameState, "After reset, we start at \(gameState.state)")
                XCTAssertTrue(InputQueue.queue.isEmpty, "After reset, we have nothing in the input queue")
                XCTAssertTrue(InputQueue.bufferQueue.isEmpty, "After reset, we have nothing in the buffer queue")
                input = Input(inputType, true)
                InputQueue.append(input)
                expectedQueueCount = (gameState.shouldAppend(input) ? 1 : 0)
                expectedBufferCount = (gameState.shouldBuffer(input) ? 1 : 0)
                XCTAssertEqual(InputQueue.queue.count, expectedQueueCount, "After appending \(input.type) in the \(gameState.state), our queue should have \(expectedQueueCount) input")
                XCTAssertEqual(InputQueue.bufferQueue.count, expectedBufferCount, "After appending \(input.type) in the \(gameState.state), our buffer should have \(expectedBufferCount) input")
            }
        }
    }
    
    func testInputQueuePop() {
        for gameState in gameStates {
            for inputType in InputType.allCases {
                InputQueue.reset(to: gameState)
                
                var input = Input(inputType, false)
                InputQueue.append(input)
                
                if gameState.shouldAppend(input) {
                    XCTAssertEqual(InputQueue.queue.count, 1)
                    if gameState.canTransition(given: input) {
                        let _ = InputQueue.pop()
                        XCTAssertEqual(InputQueue.queue.count, 0)
                    } else {
                        XCTAssertEqual(InputQueue.queue.count, 1)
                    }
                }
                
                
                InputQueue.reset(to: gameState)
                
                input = Input(inputType, true)
                InputQueue.append(input)
                
                if gameState.shouldAppend(input) {
                    XCTAssertEqual(InputQueue.queue.count, 1)
                    if gameState.canTransition(given: input) {
                        let _ = InputQueue.pop()
                        XCTAssertEqual(InputQueue.queue.count, 0)
                    } else {
                        XCTAssertEqual(InputQueue.queue.count, 1)
                    }
                    
                }
            }
        }
    }
    
    func testInputBufferQueue() {
        InputQueue.reset(to: animatingState)
        
        InputQueue.append(Input(.playerAttack, false))
        InputQueue.append(Input(.monsterAttack(TileCoord(0,0)), false))
        
        XCTAssertTrue(InputQueue.queue.isEmpty, "While in \(animatingState.state), we do not append inputs where input.canBeNonUserGenerated is false")
        XCTAssertEqual(InputQueue.bufferQueue.count, 2, "While in \(animatingState.state), we can buffer inputs where input.canBeNonUserGenerated is true")
        
        InputQueue.append(Input(.animationsFinished, false))
        XCTAssertEqual(InputQueue.queue.count, 1, "While in \(animatingState.state), we can append animationsFinished input")
        
        let _ = InputQueue.pop()
        XCTAssertEqual(InputQueue.queue.count, 2, "While in \(animatingState.state), we can pop animationsFinished input and the buffered inputs get added to the queue")
        XCTAssertEqual(InputQueue.bufferQueue.count, 0, "While in \(animatingState.state), after popping an animationsFinished input, we move buffered input to the queue")
        
        
    }

}
