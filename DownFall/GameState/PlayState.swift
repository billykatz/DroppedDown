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
             .touchBegan, .unlockExit, .goalCompleted,
             .bossTurnStart, .bossPhaseStart:
            return AnyGameState(ComputingState())
        case .boardBuilt:
            return AnyGameState(PlayState())
        case .boardLoaded:
            return AnyGameState(ReffingState())
        case .runeUseSelected:
            return AnyGameState(TargetingState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain,. selectLevel, .newTurn, .visitStore, .runeUseCanceled, .runeUsed, .decrementDynamites, .rotatePreview, .rotatePreviewFinish, .refillEmpty, .tileDetail, .runeReplacement,
             .collectOffer, .runeReplaced, .foundRuneDiscarded, .loseAndGoToStore, .tutorialPhaseEnd,
             .noMoreMoves, .noMoreMovesConfirm, .collectChestOffer
            :
            return nil
        }
        
    }
}
