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
/// There are 6 nodes or states represented in the GameState enum type
/// There are 12 edges or inputs represented in the InputType enum

extension AnyGameState {
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
    let computingState = AnyGameState(ComputingState())
    let reffingState = AnyGameState(ReffingState())

    var gameStates: [AnyGameState] = []

    var testInputs: [Input] = []

    override func setUp() {
        gameStates = [pauseState,
                      playingState,
                      winState,
                      loseState,
                      animatingState,
                      computingState,
                      reffingState]
    }

    func testWinLoseStateTransitions(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .playAgain, .selectLevel:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .animationsFinished, .gameLose, .gameWin, .attack,
                 .monsterDies, .pause, .play, .touch, .rotateClockwise,
                 .rotateCounterClockwise, .transformation, .reffingFinished,
                 .boardBuilt, .collectItem,. newTurn, .touchBegan, .tutorial:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }

    func testAnimatingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished:
                XCTAssertEqual(AnyGameState(ReffingState()), gameState.transitionState(given: Input(input)))
            case .playAgain, .gameLose, .gameWin, .boardBuilt,
                 .monsterDies, .pause, .play, .touch, .rotateClockwise,
                 .rotateCounterClockwise, .attack, .transformation, .reffingFinished,
                 .collectItem, .selectLevel, .newTurn, .touchBegan, .tutorial:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
            }
        }
    }


    func testPausedStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play, .selectLevel:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .playAgain, .gameLose, .gameWin, .boardBuilt,
                 .monsterDies, .animationsFinished, .touch, .rotateClockwise,
                 .rotateCounterClockwise, .attack, .pause, .transformation,
                 .reffingFinished, .collectItem, .newTurn, .touchBegan, .tutorial:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }

    func testPlayingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .gameWin:
                XCTAssertEqual(AnyGameState(WinState()),
                               gameState.transitionState(given: Input(input)))
            case .gameLose:
                XCTAssertEqual(AnyGameState(LoseState()),
                               gameState.transitionState(given: Input(input)))
            case .touch, .monsterDies, .touchBegan,
                 .attack, .rotateCounterClockwise, .rotateClockwise, .collectItem:
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            case .pause:
                XCTAssertEqual(AnyGameState(PauseState()),
                               gameState.transitionState(given: Input(input)))
            case .boardBuilt, .tutorial:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .play, .playAgain, .animationsFinished,
                 .transformation, .reffingFinished, .selectLevel,
                 .newTurn:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
            }
        }
    }

    func testComputingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .transformation, .newTurn:
                XCTAssertEqual(AnyGameState(AnimatingState()),
                               gameState.transitionState(given: Input(input)))
            case .playAgain, .gameLose, .gameWin, .attack, .boardBuilt,
                 .monsterDies, .animationsFinished, .touch, .rotateClockwise,
                 .rotateCounterClockwise, .pause, .play, .reffingFinished,
                 .collectItem, .selectLevel,. touchBegan, .tutorial:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }

    func testRefStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .reffingFinished(true):
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            case .reffingFinished(false):
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .attack, .monsterDies, .collectItem:
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            case .gameWin:
                XCTAssertEqual(AnyGameState(WinState()),
                               gameState.transitionState(given: Input(input)))
            case .gameLose:
                XCTAssertEqual(AnyGameState(LoseState()),
                               gameState.transitionState(given: Input(input)))
            case .touch, .rotateCounterClockwise, .rotateClockwise, .play, .pause, .animationsFinished, .playAgain, .transformation, .boardBuilt, .selectLevel, .newTurn, .touchBegan, .tutorial:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
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
            case .computing:
                testComputingStateTransition(gameState)
            case .reffing:
                testRefStateTransition(gameState)
            }
        }
    }

    func testWinLoseStateShouldAppend(_ gameState: AnyGameState) {
         for input in InputType.allCases {
            switch input {
            case .playAgain:
                XCTAssertTrue(gameState.shouldAppend(Input(input)))
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)))
            }
        }
    }

    func testPlayingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .attack, .monsterDies, .gameLose, .touchBegan,
                 .gameWin, .pause, .rotateCounterClockwise,
                 .rotateClockwise, .touch, .tutorial:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }


    func testComputingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .transformation:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testAnimatingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished:
                XCTAssertTrue(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testPauseStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play:
                XCTAssertTrue(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testReffingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .reffingFinished, .attack, .monsterDies, .gameWin, .gameLose, .collectItem:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")

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
            case .computing:
                testComputingStateShouldAppend(gameState)
            case .reffing:
                testReffingStateShouldAppend(gameState)
                
            }
        }
    }
}
