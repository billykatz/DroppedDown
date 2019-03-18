//
//  GameState.swift
//  DownFall
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

enum State {
    case playing
    case paused
    case animating
    case gameWin
    case gameLose
}

protocol GameState: class {
    var state: State { get }
    func canTransition(given input: Input) -> Bool
    func transitionState(given input: Input) -> AnyGameState?
}

final class AnyGameState {
    private var _state: State
    private let _canTransition : (Input) -> Bool
    private let _transitionState: (Input) -> AnyGameState?
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
        _canTransition = state.canTransition
        _transitionState = state.transitionState
    }
    
    func canTransition(given input: Input) -> Bool {
        return _canTransition(input)
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        return _transitionState(input)
    }
}



class LoseState: GameState {
    
    var state: State = .gameLose
    
    func canTransition(given input: Input) -> Bool {
        switch  input.type {
        case .playAgain:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain:
            return AnyGameState(PlayState())
        default:
            return nil
        }
        
        
    }
}

class WinState: GameState {
    var state: State = .gameWin
    
    func canTransition(given input: Input) -> Bool {
        switch  input.type {
        case .playAgain:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }
}

class AnimatingState: GameState {
    typealias StateType = State
    var state: State = .animating

    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .animationsFinished:
            return true
        default:
            return false
        }
    }

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .animationsFinished:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }


}
//
class PlayState: GameState {
    typealias StateType = PlayState
    var state: State = .playing

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .gameWin:
            return AnyGameState(WinState())
        case .gameLose:
            return AnyGameState(LoseState())
        case .pause:
            return AnyGameState(PauseState())
        case .playerAttack, .monsterAttack,
             .touch, .monsterDies, .rotateLeft, .rotateRight:
            return AnyGameState(AnimatingState())
        case .animationsFinished, .play, .playAgain:
            return nil
        }

    }

    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .gameLose, .gameWin, .playerAttack, .monsterAttack,
             .touch, .monsterDies, .rotateLeft, .rotateRight, .pause:
            return true
        case .animationsFinished, .play, .playAgain:
            return false
        }
    }


}



class PauseState: GameState {
    typealias StateType = State
    var state: State = .paused

    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .play:
            return true
        default:
            return false
        }
    }

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .play:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }
}
