//
//  GreaterHealingPoition.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct GreaterHealingPotion: Ability {
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
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
    
    var heal: Int? { return 2 }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.player(.zero)] }
}
