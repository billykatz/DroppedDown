//
//  WinState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct WinState: GameState {
    
    var state: State = .gameWin
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain, .selectLevel:
            return AnyGameState(PlayState())
        case .visitStore:
            return AnyGameState(WinState())
        case .transformation(let trans):
            switch trans.first?.inputType! {
            case .gameWin:
                return AnyGameState(WinState())
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

