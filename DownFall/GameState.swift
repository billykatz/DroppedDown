//
//  GameState.swift
//  DownFall
//
//  Created by William Katz on 3/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

enum State: CaseIterable {
    case playing
    case paused
    case animating
    case gameWin
    case gameLose
}

protocol GameState {
    var state: State { get }
    func canTransition(given input: Input) -> Bool
    func transitionState(given input: Input) -> AnyGameState?
    func shouldAppend(_ input: Input) -> Bool
    func shouldBuffer(_ input: Input) -> Bool
}

final class AnyGameState: GameState {
    private var _state: State
    private let _canTransition : (Input) -> Bool
    private let _transitionState: (Input) -> AnyGameState?
    private let _shouldAppend: (Input) -> Bool
    private let _shouldBuffer: (Input) -> Bool
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
        _shouldAppend = state.shouldAppend
        _shouldBuffer = state.shouldBuffer
    }
    
    func canTransition(given input: Input) -> Bool {
        return _canTransition(input)
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        return _transitionState(input)
    }
    
    func shouldAppend(_ input: Input) -> Bool {
        return _shouldAppend(input)
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        return _shouldBuffer(input)
    }
}



struct LoseState: GameState {
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain:
            return true
        default:
            return false
        }
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        return false
    }
    
    
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

struct WinState: GameState {
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain:
            return true
        default:
            return false
        }
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        return false
    }
    
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

struct AnimatingState: GameState {
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .animationsFinished:
            return true
        default:
            return false
        }
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        switch input.type {
        case .gameWin, .gameLose,
             .monsterAttack, .monsterDies, .playerAttack:
            return !input.userGenerated
        default:
            return false
        }
    }
    
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

struct PlayState: GameState {
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .gameWin,. gameLose,. pause,
             .playerAttack, .monsterAttack,
             .touch, .monsterDies, .rotateLeft, .rotateRight:
            return true
        case .animationsFinished, .play, .playAgain:
            return false

        }
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        return false
    }
    
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



struct PauseState: GameState {
    func shouldAppend(_ input: Input) -> Bool {
        return input.type == .play
    }
    
    func shouldBuffer(_ input: Input) -> Bool {
        return false
    }
    
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
