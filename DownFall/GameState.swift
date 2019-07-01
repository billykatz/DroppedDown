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
}

extension AnyGameState: Equatable {
    static func == (lhs: AnyGameState, rhs: AnyGameState) -> Bool {
        return lhs.state == rhs.state
    }
}
    

struct LoseState: GameState {
    
    var state: State = .gameLose
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .playAgain, .selectLevel:
            return true
        default:
            return false
        }
    }
    
    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .playAgain, .selectLevel:
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
        case .playAgain, .selectLevel:
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
        case .playAgain, .selectLevel:
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

struct ComputingState: GameState {
    
    var state: State = .computing
    
    func enter(_ input: Input) {}
    
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
             .touch, .monsterDies, .rotateLeft, .rotateRight,
             .boardBuilt:
            return true
        case .animationsFinished, .play,
             .reffingFinished, .playAgain, .collectItem, .selectLevel:
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
             .rotateLeft, .rotateRight, .collectItem:
            return AnyGameState(ComputingState())
        case .boardBuilt:
            return AnyGameState(PlayState())
        case .animationsFinished, .play, .transformation, .reffingFinished, .playAgain,. selectLevel:
            return nil
        }

    }
}

struct PauseState: GameState {
    var state: State = .paused
    
    func enter(_ input: Input) {}
    
    func shouldAppend(_ input: Input) -> Bool {
        return input.type == .play || input.type == .selectLevel
    }

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .play, .selectLevel:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }
}
