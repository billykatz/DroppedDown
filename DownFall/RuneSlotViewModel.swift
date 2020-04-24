//
//  RuneSlotViewModel.swift
//  DownFall
//
//  Created by Katz, Billy on 4/21/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol RuneSlotViewModelInputs {
    func wasTapped()
}

protocol RuneSlotViewModelOutputs {
    var charged: ((Int, Int) -> ())? { get }
    var textureName: String? { get }
    var isCharged: Bool { get }
    var runeWasTapped: ((AnyAbility?, Int) -> ())? { get }
    var progressRatio: CGFloat { get }
    var progressColor: UIColor? { get }
}

class RuneSlotViewModel: RuneSlotViewModelOutputs, RuneSlotViewModelInputs {
    
    // Output
    var charged: ((Int, Int) -> ())? = nil
    var runeWasTapped: ((AnyAbility?, Int) -> ())? = nil
    
    var progressRatio: CGFloat {
        guard let rune = rune else { return 0 }
        return CGFloat(current)/CGFloat(rune.cooldown)
    }
    
    var progressColor: UIColor? {
        guard let rune = rune else { return nil }
        return rune.progressColor
    }
    
    var textureName: String? {
        guard let rune = rune else { return nil }
        return rune.textureName
    }
    
    // State variables
    private var rune: AnyAbility?
    private var current: Int = 0 {
        didSet {
            charged?(current, rune?.cooldown ?? 0)
        }
    }
    
    init(rune: AnyAbility?, registerForUpdates: Bool = true, progress: Int = 0) {
        self.rune = rune
        self.current = progress
        
        if registerForUpdates {
            Dispatch.shared.register { [weak self] (input) in
                self?.handle(input: input)
            }
        }
    }
    
    var isCharged: Bool {
        guard let cooldown = rune?.cooldown else { return false }
        return current >= cooldown
    }
    
    func wasTapped() {
        runeWasTapped?(rune, current)
    }
    
    private func handle(input: Input) {
        switch input.type {
        case .transformation(let trans):
            trackRuneProgress(with: trans)
            return
        default:
            return
        }
    }
    
    private func trackRuneProgress(with trans: [Transformation]) {
        if let inputType = trans.first?.inputType {
            switch inputType {
            case InputType.touch(_, let type):
                if let count = trans.first?.tileTransformation?.first?.count,
                    (rune?.rechargeType.contains(type) ?? false) {
                    advanceGoal(units: count)
                }
            default:
                return
            }
        }
    }
    
    private func advanceGoal(units: Int) {
        guard let cooldown = rune?.cooldown, let minimum = rune?.rechargeMinimum else { return }
        guard units >= minimum else { return }
        current += minimum > 1 ? 1 : units
        current = min(cooldown, current)
    }
}
