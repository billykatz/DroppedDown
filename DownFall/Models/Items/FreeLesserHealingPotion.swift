//
//  FreeLesserHealingPotion.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct FreeLesserHealingPotion: Ability {
    
    var distanceBetweenTargets: Int? { return nil }
    
    var rechargeMinimum: Int {
        return 1
    }
    
    var progressColor: UIColor {
        return UIColor.darkBarRed
    }
    
    var cooldown: Int { return 0 }
    
    var rechargeType: [TileType] { return [] }
    
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
        return "lesserHealingPotionSpriteSheet"
    }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .lesserHealingPotion }
    
    var description: String {
        return "Restores 1 health."
    }
    
    var flavorText: String {
        return "It smells like turpentine."
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
    var heal: Int? { return 1 }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.player(.playerZero)] }
}

