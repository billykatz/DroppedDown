//
//  ReffingState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct ReffingState: GameState {
    
    var state: State = .reffing
    
    func enter(_ input: Input) {
        Referee.enterRules(input.endTiles)
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .reffingFinished:
            return AnyGameState(PlayState())
        case .attack, .monsterDies, .collectItem:
            return AnyGameState(ComputingState())
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        default:
            return nil
        }
    }
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .reffingFinished, .attack, .monsterDies,
             .gameWin, .gameLose, .collectItem:
            return true
        default:
            return false
        }
    }
}

