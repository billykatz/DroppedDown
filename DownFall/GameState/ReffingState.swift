//
//  ReffingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct ReffingState: GameState {
    
    var state: ShiftShaft_State = .reffing
    
    func enter(_ input: Input) {
        Referee.shared.enterRules(input.endTilesStruct)
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .reffingFinished(newTurn: true):
            // When newTurn is true then we need to alert the Board by entering computing state
            // Then the board can do all the clean up necessary before starting a new turn
            return AnyGameState(ComputingState())
        case .reffingFinished(newTurn: false):
            return AnyGameState(PlayState())
        case .attack, .monsterDies, .collectItem, .decrementDynamites,
                .refillEmpty, .collectOffer, .noMoreMoves, .noMoreMovesConfirm:
            return AnyGameState(ComputingState())
        case .runeReplacement:
            return AnyGameState(PauseState())
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        default:
            return nil
        }
    }
}

