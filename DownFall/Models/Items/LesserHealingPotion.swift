//
//  LesserHealingPotion.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct LesserHealingPotion: Ability {
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "lesserHealingPotion"
    }
    
    var cost: Int { return 8 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .lesserHealingPotion }
    
    var description: String {
        return "Restores 1 health."
    }
    
    var flavorText: String {
        return "It smells like turpentine."
    }
    
    var grantsExtraAttacks: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .once
    }
}

