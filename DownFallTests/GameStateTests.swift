//
//  GameStateTests.swift
//  DownFallTests
//
//  Created by William Katz on 3/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import DownFall


/// The purpose of these tests is to verfiy our state machine
/// There are 5 nodes or states represented in the GameState enum type
/// There are 12 edges or inputs represented in the InputType enum
///
/*
 
 DroppedDown's FSM
 
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

extension AnyGameState: Equatable {
    public static func ==(_ lhs: AnyGameState, _ rhs: AnyGameState) -> Bool {
        return lhs.state == rhs.state
    }
}

class GameStateTests: XCTestCase {
    
    let playingState = AnyGameState(PlayState())
    let pauseState = AnyGameState(PauseState())
    let animatingState = AnyGameState(AnimatingState())
    let winState = AnyGameState(WinState())
    let loseState = AnyGameState(LoseState())
    
    var gameStates: [AnyGameState] = []
    
    var testInputs: [Input] = []
    
    override func setUp() {
        gameStates = [pauseState,
                      playingState,
                      winState,
                      loseState,
                      animatingState]
    }
    
    func testWinLoseStateTransitions(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .playAgain:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input, true)))
            case .animationsFinished, .gameLose, .gameWin, .monsterAttack,
                 .monsterDies, .pause, .play, .touch, .rotateRight,
                 .rotateLeft, .playerAttack:
                XCTAssertNil(gameState.transitionState(given: Input(input, true)))
            }
        }
    }
    
    func testAnimatingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input, true)))
            case .playAgain, .gameLose, .gameWin, .monsterAttack,
                 .monsterDies, .pause, .play, .touch, .rotateRight,
                 .rotateLeft, .playerAttack:
                XCTAssertNil(gameState.transitionState(given: Input(input, true)))
            }
        }
    }
    
    
    func testPausedStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input, true)))
            case .playAgain, .gameLose, .gameWin, .monsterAttack,
                 .monsterDies, .animationsFinished, .touch, .rotateRight,
                 .rotateLeft, .playerAttack, .pause:
                XCTAssertNil(gameState.transitionState(given: Input(input, true)))
            }
        }
    }

    func testPlayingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .gameWin:
                XCTAssertEqual(AnyGameState(WinState()),
                               gameState.transitionState(given: Input(input, true)))
            case .gameLose:
                XCTAssertEqual(AnyGameState(LoseState()),
                               gameState.transitionState(given: Input(input, true)))
            case .touch, .monsterAttack, .monsterDies,
                 .playerAttack, .rotateLeft, .rotateRight:
                XCTAssertEqual(AnyGameState(AnimatingState()),
                               gameState.transitionState(given: Input(input, true)))
            case .pause:
                XCTAssertEqual(AnyGameState(PauseState()),
                               gameState.transitionState(given: Input(input, true)))
            case .play, .playAgain, .animationsFinished:
                XCTAssertNil(gameState.transitionState(given: Input(input, false)))
            }
        }
    }

    
    func testTransitionState() {
        for gameState in gameStates {
            switch gameState.state {
            case .gameLose, .gameWin:
                testWinLoseStateTransitions(gameState)
            case .playing:
                testPlayingStateTransition(gameState)
            case .animating:
                testAnimatingStateTransition(gameState)
            case .paused:
                testPausedStateTransition(gameState)
            }
        }
    }
    
    func testWinLoseStateShouldAppend(_ gameState: AnyGameState) {
         for input in InputType.allCases {
            switch input {
            case .playAgain:
                XCTAssertTrue(gameState.shouldAppend(Input(input, true)))
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input, true)))
            }
        }
    }
    
    func testPlayingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .playerAttack, .monsterDies, .monsterAttack, .gameLose,
                 .gameWin, .pause, .rotateLeft, .rotateRight, .touch:
                XCTAssertTrue(gameState.shouldAppend(Input(input, true)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input, true)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }
    
    func testAnimatingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished:
                XCTAssertTrue(gameState.shouldAppend(Input(input, false)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input, false)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }
    
    func testPauseStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play:
                XCTAssertTrue(gameState.shouldAppend(Input(input, true)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input, false)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }
        
    
    func testShouldAppend() {
        for gameState in gameStates {
            switch gameState.state {
            case .gameLose, .gameWin:
                testWinLoseStateShouldAppend(gameState)
            case .playing:
                testPlayingStateShouldAppend(gameState)
            case .animating:
                testAnimatingStateShouldAppend(gameState)
            case .paused:
                testPauseStateShouldAppend(gameState)
            }
        }
    }
    
    func testWinLosePlayPauseShouldBuffer(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            XCTAssertFalse(gameState.shouldBuffer(Input(input, false)))
        }
    }
    
    func testAnimatingShouldBuffer(_ gameState: AnyGameState) {
        for inputType in InputType.allCases {
            let notUserGeneratedInput = Input(inputType, false)
            let userGeneratedInput = Input(inputType, true)
            switch inputType {
            case .monsterAttack, .monsterDies, .playerAttack, .gameLose, .gameWin:
                XCTAssertTrue(gameState.shouldBuffer(notUserGeneratedInput), "\(gameState.state) should buffer \(inputType)")
                XCTAssertFalse(gameState.shouldBuffer(userGeneratedInput), "\(gameState.state) should not buffer \(inputType)")
            default:
                XCTAssertFalse(gameState.shouldBuffer(notUserGeneratedInput), "\(gameState.state) should not buffer \(inputType)")
                XCTAssertFalse(gameState.shouldBuffer(userGeneratedInput), "\(gameState.state) should not buffer \(inputType)")
            }
        }
    }
    
    func testShouldBuffer() {
        for gameState in gameStates {
            switch gameState.state {
            case .gameLose, .gameWin, .playing, .paused:
                testWinLosePlayPauseShouldBuffer(gameState)
            case .animating:
                testAnimatingShouldBuffer(gameState)
            }
        }
    }
}
