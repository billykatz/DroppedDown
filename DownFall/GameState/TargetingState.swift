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
        case .itemCanBeUsed, .itemUseSelected:
            return AnyGameState(TargetingState())
        case .itemUsed:
            return AnyGameState(ComputingState())
        case .transformation(let trans):
            guard let inputType = trans.first?.inputType else { fatalError() }
            if case InputType.itemUseSelected(_) = inputType {
                return AnyGameState(TargetingState())
            }
            return nil
        default:
            return nil
        }
    }
}
