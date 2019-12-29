//
//  SwordPickAxe.swift
//  DownFall
//
//  Created by William Katz on 12/20/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct SwordPickAxe: Ability {
    var affectsCombat: Bool {
        return true
    }
    
    var textureName: String {
        return "swordPickAxe"
    }
    
    var cost: Int { return 2 }
    
    var currency: Currency { return .gem }
    
    var type: AbilityType { return .swordPickAxe }
    
    var description: String {
        return "It looks like someone tape a sword onto the hilt of a pick axe"
    }
    
    var flavorText: String {
        return "This is always more useful than just a pick axe or just a sword."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .oneRun
    }
}
