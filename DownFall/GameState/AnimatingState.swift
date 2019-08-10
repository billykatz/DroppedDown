//
//  AnimatingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct AnimatingState: GameState {
    
    var state: State = .animating
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .animationsFinished:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .animationsFinished:
            return AnyGameState(ReffingState())
        default:
            return nil
        }
    }
    
    
}

