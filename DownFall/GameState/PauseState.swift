//
//  PauseState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct PauseState: GameState {
    var state: ShiftShaft_State = .paused
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .play, .selectLevel, .playAgain, .tutorialPhaseEnd:
            return AnyGameState(PlayState())
        case .runeReplaced, .foundRuneDiscarded, .noMoreMovesConfirm:
            return AnyGameState(ComputingState())
        case .gameWin:
            #if DEBUG
            return AnyGameState(WinState())
            #endif
            return nil
        default:
            return nil
        }
    }
}
