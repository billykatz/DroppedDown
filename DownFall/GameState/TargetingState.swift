//
//  TargetingState.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct TargetingState: GameState {

    var state: State = .targeting

    func enter(_ input: Input) {}

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .itemUseCanceled:
            return AnyGameState(PlayState())
        default:
            return nil
        }
    }

    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .itemUseCanceled:
            return true
        default:
            return false
        }
    }

}
