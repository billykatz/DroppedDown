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
        Referee.enterRules(input.endTilesStruct)
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .reffingFinished(true):
            // check the global Turn Counter,
            // that knows whether or not a "turn" happened
            return AnyGameState(ComputingState())
        case .reffingFinished(newTurn: false):
            return AnyGameState(PlayState())
        case .attack, .monsterDies, .collectItem, .decrementDynamites, .refillEmpty, .collectOffer:
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

