//
//  TargetingProtocol.swift
//  DownFall
//
//  Created by Billy on 12/1/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Combine


protocol TargetingOutputs {
    var toastMessage: String { get }
    var currentTargets: AllTarget { get }
    var legallyTargeted: Bool { get }
    var inventory: [Rune] { get }
    var runeReplacementPublisher: AnyPublisher<(Pickaxe, Rune, Bool), Never> { get }
}

protocol TargetingInputs {
    
    /// Use this to choose targets
    func didTarget(_ coord: TileCoord)
    
    /// Use this to consume the item
    func didUse(_ rune: Rune?)
    
    /// Use this to select an ability
    func didSelect(_ rune: Rune?)
}

protocol Targeting: TargetingOutputs, TargetingInputs {}
