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
    case computing
    case reffing
}

protocol GameState {
    var state: State { get }
    func canTransition(given input: Input) -> Bool
    func transitionState(given input: Input) -> AnyGameState?
    func shouldAppend(_ input: Input) -> Bool
    func enter(_ input: Input)
}

final class AnyGameState: GameState {
    private var _state: State
    private let _canTransition : (Input) -> Bool
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
        _canTransition = state.canTransition
        _transitionState = state.transitionState
        _shouldAppend = state.shouldAppend
        _enter = state.enter
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
    
    func enter(_ input: Input) {
        return _enter(input)
    }
}

struct LoseState: GameState {
    
    var state: State = .gameLose
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain:
            return true
        default:
            return false
        }
    }

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
        @unknown default:
            return nil
        }
    }
}

struct WinState: GameState {
    
    var state: State = .gameWin
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain:
            return true
        case .transformation(let trans):
            switch trans.inputType! {
            case .gameWin:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    func canTransition(given input: Input) -> Bool {
        switch  input.type {
        case .playAgain:
            return true
        case .transformation(let trans):
            switch trans.inputType! {
            case .gameWin:
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
        case .playAgain:
            return AnyGameState(PlayState())
        case .transformation(let trans):
            switch trans.inputType! {
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

struct AnimatingState: GameState {
    
    var state: State = .animating
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .animationsFinished:
            return true
        default:
            return false
        }
    }

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
            return AnyGameState(ReffingState())
        default:
            return nil
        }
    }


}

struct ReffingState: GameState {

    var state: State = .reffing

    func enter(_ input: Input) {
        Referee.enterRules(input.endTiles)
    }
    
    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .reffingFinished:
            return true
        case .attack, .monsterDies, .gameLose, .gameWin:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .reffingFinished:
            return AnyGameState(PlayState())
        case .attack, .monsterDies:
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
        case .reffingFinished, .attack, .monsterDies, .gameWin, .gameLose:
            return true
        default:
            return false
        }
    }
}

struct ComputingState: GameState {
    
    var state: State = .computing
    
    func enter(_ input: Input) {}
    
    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .transformation:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .transformation:
            return AnyGameState(AnimatingState())
        default:
            return nil
        }
    }
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .transformation:
            return true
        default:
            return false
        }
    }
}

struct PlayState: GameState {

    var state: State = .playing

    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .gameWin,. gameLose,. pause,
             .attack, .transformation,
             .touch, .monsterDies, .rotateLeft, .rotateRight:
            return true
        case .animationsFinished, .play, .reffingFinished, .playAgain:
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
             .rotateLeft, .rotateRight:
            return AnyGameState(ComputingState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain:
            return nil
        }

    }

    func canTransition(given input: Input) -> Bool {
        switch input.type {
        case .gameLose, .gameWin, .attack,
             .touch, .monsterDies, .rotateLeft, .rotateRight, .pause:
            return true
        case .animationsFinished, .play, .playAgain, .transformation, .reffingFinished:
            return false
        }
    }


}

struct PauseState: GameState {
    var state: State = .paused
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        return input.type == .play
    }

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
