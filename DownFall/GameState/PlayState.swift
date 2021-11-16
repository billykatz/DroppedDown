//
//  PlayState.swift
//  DownFall
//
//  Created by William Katz on 7/28/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct PlayState: GameState {
    
    var state: ShiftShaft_State = .playing
    
    func enter(_ input: Input) {}
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        case .pause, .levelGoalDetail, .tutorialPhaseStart:
            return AnyGameState(PauseState())
        case .attack, .touch, .monsterDies,
             .rotateCounterClockwise, .rotateClockwise, .collectItem,
             .touchBegan, .shuffleBoard, .unlockExit, .goalCompleted,
             .bossTurnStart:
            return AnyGameState(ComputingState())
        case .boardBuilt:
            return AnyGameState(PlayState())
        case .boardLoaded:
            return AnyGameState(ReffingState())
        case .itemUseSelected:
            return AnyGameState(TargetingState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain,. selectLevel, .newTurn, .visitStore, .itemUseCanceled, .itemCanBeUsed, .itemUsed, .decrementDynamites, .rotatePreview, .rotatePreviewFinish, .refillEmpty, .tileDetail, .runeReplacement,
             .collectOffer, .runeReplaced, .foundRuneDiscarded, .loseAndGoToStore, .tutorialPhaseEnd:
            return nil
        }
        
    }
}
