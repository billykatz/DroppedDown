//
//  TargetingState.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

struct TargetingState: GameState {

    var state: ShiftShaft_State = .targeting

    func enter(_ input: Input) {}

    func transitionState(given input: Input) -> AnyGameState? {
        switch input.type {
        case .runeUseCanceled:
            return AnyGameState(PlayState())
        case .runeUseSelected:
            return AnyGameState(TargetingState())
        case .runeUsed:
            return AnyGameState(ComputingState())
        case .transformation(let trans):
            guard let inputType = trans.first?.inputType else { fatalError() }
            if case InputType.runeUseSelected(_) = inputType {
                return AnyGameState(TargetingState())
            }
            return nil
        default:
            return nil
        }
    }
}
