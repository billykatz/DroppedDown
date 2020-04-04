//
//  ThreatLevelController.swift
//  DownFall
//
//  Created by Katz, Billy on 3/26/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit

/// The purpose of this class is to model threat and advance threat where certain criteria are met.
/// This is a prototype, so the criteria is not completely clear right now.  I can imagine that that threat would increase with killing monsters, taking turns, and clearing rocks.  Threat affects how the damage and gold multipliers.  You get more gold but also take more damage when the threat is higher.  There are three different levels of threat.  Yellow, Orange and Red.  Yellow is how we play today, 1x gold 1x damage.  Orange 2x everything and red 3x everything.  There time spent in each threat level is non-linear- the exact numbers we have not found yet. A good place to start would be 50 in Yellow and 30 in Orange and the rest in Red.

struct ThreatLevel {
    
    let unitsAccrued: Int
    let yellowRange: Range<Int>
    let orangeRange: Range<Int>
    let redRange: Range<Int>
    var color: ThreatColor {
        if yellowRange.contains(unitsAccrued) {
            return .yellow
        } else if orangeRange.contains(unitsAccrued) {
            return .orange
        } else {
            return .red
        }
    }
    
    init(unitsAccrued: Int, yellowRange: Range<Int>, orangeRange: Range<Int>, redRange: Range<Int>) {
        self.unitsAccrued = unitsAccrued
        self.yellowRange = yellowRange
        self.orangeRange = orangeRange
        self.redRange = redRange
    }
    
    enum ThreatColor: CaseIterable {
        case yellow
        case orange
        case red
        
        var goldDamageMultiplier: Int {
            switch self {
            case .yellow:
                return 1
            case .orange:
                return 2
            case .red:
                return 3
            }
        }
        
        var uicolor: UIColor {
            switch self {
            case .yellow:
                return .yellow
            case .orange:
                return .orange
            case .red:
                return .red
            }
        }
    }
    
    func threatLevel(plus units: Int) -> ThreatLevel {
        return ThreatLevel(unitsAccrued: unitsAccrued + units, yellowRange: self.yellowRange, orangeRange: self.orangeRange, redRange: self.redRange)
    }
    
    
    static func threatUnits(for input: InputType) -> Int {
        switch input {
        case .monsterDies:
            return 5
        case .touch:
            return 2
        default:
            return 0
        }
    }
}


class ThreatLevelController {
    
    var threatLevel: ThreatLevel
    
    init(yellowRange: Range<Int> = 0..<50, orangeRange: Range<Int> = 50..<100, redRange: Range<Int> = 100..<Int.max) {
        self.threatLevel = ThreatLevel(unitsAccrued: 1, yellowRange: yellowRange, orangeRange: orangeRange, redRange: redRange)
        
        Dispatch.shared.register { [weak self] input in
            self?.handle(input)
        }
    }
    
    func reset() {
        threatLevel = ThreatLevel(unitsAccrued: 1, yellowRange: threatLevel.yellowRange, orangeRange: threatLevel.orangeRange, redRange: threatLevel.redRange)
        
        Dispatch.shared.register { [weak self] input in
            self?.handle(input)
        }
    }
    
    func handle(_ input: Input) {
        let units = ThreatLevel.threatUnits(for: input.type)
        threatLevel = threatLevel.threatLevel(plus: units)
    }
}
