//
//  GreaterHealingPoition.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct GreaterHealingPotion: Ability {
    func animatedColumns() -> Int? {
        return 5
    }
    
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "greaterHealingPotionSpriteSheet"
    }
    
    var cost: Int { return 80 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .greaterHealingPotion }
    
    var description: String {
        return "Restores 2 health."
    }
    
    var flavorText: String {
        return "I held my nose, I closed my eyes, I took a drink."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .once
    }
}
