//
//  ComputingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct ComputingState: GameState {
    
    var state: State = .computing
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .transformation:
            return AnyGameState(AnimatingState())
        default:
            return nil
        }
    }
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .transformation:
            return true
        default:
            return false
        }
    }
}


