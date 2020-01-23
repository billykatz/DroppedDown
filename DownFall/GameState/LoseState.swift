//
//  LoseState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct LoseState: GameState {
    
    var state: State = .gameLose
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain, .selectLevel:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain, .selectLevel:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }
}
