//
//  ComputingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct ComputingState: GameState {
    
    var state: ShiftShaft_State = .computing
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .transformation(let trans):
            if case .reffingFinished(_)? = trans.first?.inputType {
                return AnyGameState(ComputingState())
            } else if case .touchBegan? = trans.first?.inputType {
                return AnyGameState(PlayState())
            } else if case .noMoreMoves = trans.first?.inputType {
                return AnyGameState(PauseState())
            }
            else {
                return AnyGameState(AnimatingState())
            }
        case .tileDetail:
            return AnyGameState(PauseState())
        case .newTurn:
            // The Board creates the newTurn when it receives a transformation with the input type "reffing finished"
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }
}


