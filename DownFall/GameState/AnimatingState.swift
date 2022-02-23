//
//  AnimatingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct AnimatingState: GameState {
    
    var state: ShiftShaft_State = .animating
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .animationsFinished(true):
            return AnyGameState(ReffingState())
        case .animationsFinished(ref: false):
            return AnyGameState(PlayState())
        case .rotatePreview:
            return AnyGameState(AnimatingState())
        case .rotatePreviewFinish:
            return AnyGameState(ComputingState())
        case .collectChestOffer:
            return AnyGameState(ComputingState())
        case .runeReplacement:
            return AnyGameState(PauseState())
        default:
            return nil
        }
    }
    
    
}

