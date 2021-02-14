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
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        case .pause, .levelGoalDetail:
            return AnyGameState(PauseState())
        case .attack, .touch, .monsterDies,
             .rotateCounterClockwise, .rotateClockwise, .collectItem,
             .touchBegan, .shuffleBoard, .unlockExit, .goalCompleted:
            return AnyGameState(ComputingState())
        case .boardBuilt:
            // TODO: I dont know the full consequences of changing this from return PlayState to Reffing State.  But basically when we load a game we need to check to see if there is anything to Ref, like if the player is 1 tile above an open exit.
            return AnyGameState(ReffingState())
        case .itemUseSelected:
            return AnyGameState(TargetingState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain,. selectLevel, .newTurn, .visitStore, .itemUseCanceled, .itemCanBeUsed, .itemUsed, .decrementDynamites, .rotatePreview, .rotatePreviewFinish, .refillEmpty, .tileDetail, .runeReplacement,
             .collectOffer, .runeReplaced, .foundRuneDiscarded:
            return nil
        }
        
    }
}
