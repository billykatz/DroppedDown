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
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain, .selectLevel, .visitStore, .runeProgressRecord:
            return true
        case .transformation(let trans):
            guard let inputType = trans.first?.inputType else { return false }
            switch inputType {
            case .gameWin, .runeProgressRecord:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain, .selectLevel:
            return AnyGameState(PlayState())
        case .visitStore, .runeProgressRecord:
            return AnyGameState(WinState())
        case .transformation(let trans):
            switch trans.first?.inputType! {
            case .gameWin, .runeProgressRecord:
                return AnyGameState(WinState())
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

