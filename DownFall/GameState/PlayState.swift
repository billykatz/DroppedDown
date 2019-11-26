//
//  PlayState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct PlayState: GameState {
    
    var state: State = .playing
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .gameWin,. gameLose,. pause,
             .attack, .transformation,
             .touch, .monsterDies, .rotateCounterClockwise, .rotateClockwise,
             .boardBuilt, .touchBegan, .tutorial:
            return true
        case .animationsFinished, .play,
             .reffingFinished, .playAgain, .collectItem,
             .selectLevel, .newTurn:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        case .pause:
            return AnyGameState(PauseState())
        case .attack, .touch, .monsterDies,
             .rotateCounterClockwise, .rotateClockwise, .collectItem,
             .touchBegan:
            return AnyGameState(ComputingState())
        case .boardBuilt, .tutorial:
            return AnyGameState(PlayState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain,. selectLevel, .newTurn:
            return nil
        }
        
    }
}
