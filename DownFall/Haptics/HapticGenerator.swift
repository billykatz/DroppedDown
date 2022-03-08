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
    
    static let shared: HapticGenerator = HapticGenerator()
    
    let lightGenerator: UIImpactFeedbackGenerator
    let mediumGenerator: UIImpactFeedbackGenerator
    let heavyGenerator: UIImpactFeedbackGenerator
    let softGenerator: UIImpactFeedbackGenerator
    let rigidGenerator: UIImpactFeedbackGenerator
    
    init() {
        lightGenerator = UIImpactFeedbackGenerator(style: .light)
        lightGenerator.prepare()
        mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
        mediumGenerator.prepare()
        heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.prepare()
        softGenerator = UIImpactFeedbackGenerator(style: .soft)
        softGenerator.prepare()
        rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
        rigidGenerator.prepare()
        
    }
    
    func register() {
        Dispatch.shared.register { [weak self] input in
            self?.playFeedback(for: input)
        }
        
    }
}

extension HapticGenerator {
    
    func playStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .heavy:
            heavyGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .light:
            lightGenerator.impactOccurred()
        case .soft:
            softGenerator.impactOccurred()
        case .rigid:
            rigidGenerator.impactOccurred()
            
        @unknown default:
            fatalError()
        }
    }
    
    func playFeedback(for input: Input) {
        switch input.type {
        case .touch:
            playStyle(.light)
        case .attack:
            playStyle(.heavy)
        case .transformation(let trans):
            if let first = trans.first {
                if first.playerTookDamage != nil {
                    playStyle(.heavy)
                }
            }
        default:
            ()
        }
    }
}
