//
//  GameStateTests.swift
//  DownFallTests
//
//  Created by William Katz on 3/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import XCTest
@testable import Shift_Shaft


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

    func testWinStateTransitions(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .playAgain, .selectLevel:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .visitStore:
                XCTAssertEqual(AnyGameState(WinState()),
                gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }
    
    func testLoseStateTransitions(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .playAgain, .selectLevel:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }


    func testAnimatingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished:
                XCTAssertEqual(AnyGameState(ReffingState()), gameState.transitionState(given: Input(input)))
            case .rotatePreview:
                XCTAssertEqual(AnyGameState(AnimatingState()), gameState.transitionState(given: Input(input)))
            case .rotatePreviewFinish:
                XCTAssertEqual(AnyGameState(ComputingState()), gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
            }
        }
    }


    func testPausedStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play, .selectLevel, .playAgain:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .runeReplaced, .foundRuneDiscarded:
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")

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
                 .attack, .rotateCounterClockwise, .rotateClockwise, .collectItem, .unlockExit,
                 .goalCompleted:
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            case .pause, .levelGoalDetail:
                XCTAssertEqual(AnyGameState(PauseState()),
                               gameState.transitionState(given: Input(input)))
            case .boardBuilt:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .itemUseSelected:
                XCTAssertEqual(AnyGameState(TargetingState()),
                               gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
            
            }
        }
    }

    func testComputingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .transformation:
                XCTAssertEqual(AnyGameState(AnimatingState()),
                               gameState.transitionState(given: Input(input)))
            case .newTurn:
                XCTAssertEqual(AnyGameState(PlayState()),
                gameState.transitionState(given: Input(input)))
            case .tileDetail:
                XCTAssertEqual(AnyGameState(PauseState()),
                               gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
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
            case .attack, .monsterDies, .collectItem, .decrementDynamites, .refillEmpty, .collectOffer:
                XCTAssertEqual(AnyGameState(ComputingState()),
                               gameState.transitionState(given: Input(input)))
            case .gameWin:
                XCTAssertEqual(AnyGameState(WinState()),
                               gameState.transitionState(given: Input(input)))
            case .gameLose:
                XCTAssertEqual(AnyGameState(LoseState()),
                               gameState.transitionState(given: Input(input)))
            case .runeReplacement:
                XCTAssertEqual(AnyGameState(PauseState()),
                               gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)), "\(gameState.state) should not transition to \(input)")
            }
        }
    }
    
    func testTargetingStateTransition(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .itemCanBeUsed:
                XCTAssertEqual(AnyGameState(TargetingState()),
                gameState.transitionState(given: Input(input)))
            case .itemUseCanceled:
                XCTAssertEqual(AnyGameState(PlayState()),
                               gameState.transitionState(given: Input(input)))
            case .itemUsed:
                XCTAssertEqual(AnyGameState(ComputingState()),
                gameState.transitionState(given: Input(input)))
            default:
                XCTAssertNil(gameState.transitionState(given: Input(input)))
            }
        }
    }



    func testTransitionState() {
        for gameState in gameStates {
            switch gameState.state {
            case .gameLose:
                testLoseStateTransitions(gameState)
            case .gameWin:
                testWinStateTransitions(gameState)
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
            case .targeting:
                testTargetingStateTransition(gameState)
            }
        }
    }

    func testWinStateShouldAppend(_ gameState: AnyGameState) {
         for input in InputType.allCases {
            switch input {
            case .playAgain, .selectLevel, .visitStore:
                XCTAssertTrue(gameState.shouldAppend(Input(input)))
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)))
            }
        }
    }
    
    func testLoseStateShouldAppend(_ gameState: AnyGameState) {
            for input in InputType.allCases {
               switch input {
               case .playAgain, .selectLevel:
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
                 .rotateClockwise, .touch, .itemUseSelected,
                 .boardBuilt, .unlockExit,. levelGoalDetail,
                 .goalCompleted, .collectItem:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }


    func testComputingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .transformation, .tileDetail:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testAnimatingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .animationsFinished, .rotatePreviewFinish, .rotatePreview:
                XCTAssertTrue(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testPauseStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .play, .playAgain, .runeReplaced:
                XCTAssertTrue(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")
            }
        }
    }

    func testReffingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .reffingFinished, .attack, .monsterDies, .gameWin, .gameLose, .collectItem, .decrementDynamites, .refillEmpty, .collectOffer, .runeReplacement:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")

            }
        }
    }
    
    func testTargetingStateShouldAppend(_ gameState: AnyGameState) {
        for input in InputType.allCases {
            switch input {
            case .itemUseCanceled:
                XCTAssertTrue(gameState.shouldAppend(Input(input)), "\(gameState.state) ought to append \(input)")
            default:
                XCTAssertFalse(gameState.shouldAppend(Input(input)),  "\(gameState.state) ought not to append \(input)")

            }
        }
    }

    

    func testShouldAppend() {
        for gameState in gameStates {
            switch gameState.state {
            case .gameLose:
                testLoseStateShouldAppend(gameState)
            case .gameWin:
                testWinStateShouldAppend(gameState)
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
            case .targeting:
                testTargetingStateShouldAppend(gameState)
                
            }
        }
    }
}
