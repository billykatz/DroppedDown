//
//  GameState.swift
//  DownFall
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

enum State: CaseIterable, Equatable {
    case playing
    case paused
    case animating
    case gameWin
    case gameLose
    case computing
    case reffing
}

protocol GameState: Equatable {
    var state: State { get }
    func transitionState(given input: Input) -> AnyGameState?
    func shouldAppend(_ input: Input) -> Bool
    func enter(_ input: Input)
}

final class AnyGameState: GameState {
    private var _state: State
    private let _transitionState: (Input) -> AnyGameState?
    private let _shouldAppend: (Input) -> Bool
    private let _enter: (Input) -> ()
    var state: State {
        get {
            return _state
        }
        set {
            _state = newValue
        }
    }

    init<T>(_ state: T) where T: GameState {
        _state = state.state
        _transitionState = state.transitionState
        _shouldAppend = state.shouldAppend
        _enter = state.enter
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        return _transitionState(input)
    }
    
    func shouldAppend(_ input: Input) -> Bool {
        return _shouldAppend(input)
    }
    
    func enter(_ input: Input) {
        return _enter(input)
    }
    
    static var playState: AnyGameState {
        return GameScope.shared.difficulty == Difficulty.tutorial1 ? AnyGameState(TutorialState()) : AnyGameState(PlayState())
    }
}

extension AnyGameState: Equatable {
    static func == (lhs: AnyGameState, rhs: AnyGameState) -> Bool {
        return lhs.state == rhs.state
    }
}
    





