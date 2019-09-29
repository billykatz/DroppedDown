//
//  HapticGenerator.swift
//  DownFall
//
//  Created by William Katz on 6/17/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit


class HapticGenerator {
    
    let lightGenerator: UIImpactFeedbackGenerator
    let heavyGenerator: UIImpactFeedbackGenerator
    
    init() {
        lightGenerator = UIImpactFeedbackGenerator(style: .light)
        lightGenerator.prepare()
        
        heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.prepare()
        Dispatch.shared.register { [weak self] input in
            self?.playFeedback(for: input)
        }
    }
}

extension HapticGenerator {
    func playFeedback(for input: Input) {
        switch input.type {
        case .touch:
            lightGenerator.impactOccurred()
        case .attack:
            heavyGenerator.impactOccurred()
        default:
            ()
        }
    }
}
