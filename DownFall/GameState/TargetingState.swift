//
//  TargetingState.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

struct TargetingState: GameState {

    var state: State = .targeting

    func enter(_ input: Input) {}

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .itemUseCanceled:
            return AnyGameState(PlayState())
        case .itemCanBeUsed:
            return AnyGameState(TargetingState())
        case .transformation(let trans):
            guard let inputType = trans.inputType else { fatalError() }
            if case InputType.itemUseSelected(_) = inputType {
                return AnyGameState(TargetingState())
            }
            return nil
        default:
            return nil
        }
    }

    func shouldAppend(_ input: Input) -> Bool {
        switch input.type {
        case .itemUseCanceled, .itemCanBeUsed:
            return true
        case .transformation(let trans):
            guard let inputType = trans.inputType else { fatalError() }
            if case InputType.itemUseSelected(_) = inputType {
                return true
            }
            return false

        default:
            return false
        }
    }

}
