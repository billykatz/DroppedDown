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
    var textureName: String? { get }
    var isCharged: Bool { get }
    var runeWasTapped: ((Rune?, Int) -> ())? { get }
    var progressColor: UIColor? { get }
    var rune: Rune? { get }
}

class RuneSlotViewModel: RuneSlotViewModelOutputs, RuneSlotViewModelInputs {
    
    // Output
    var runeWasTapped: ((Rune?, Int) -> ())? = nil
    
    var progressColor: UIColor? {
        guard let rune = rune else { return nil }
        return rune.progressColor.forUI
    }
    
    var textureName: String? {
        guard let rune = rune else { return nil }
        return rune.textureName
    }
    
    // State variables
    let rune: Rune?
    let current: Int
    
    init(rune: Rune?) {
        self.rune = rune
        self.current = rune?.rechargeCurrent ?? 0
    }
    
    var isCharged: Bool {
        guard let cooldown = rune?.cooldown else { return false }
        return current >= cooldown
    }
    
    func wasTapped() {
        runeWasTapped?(rune, current)
    }
}
