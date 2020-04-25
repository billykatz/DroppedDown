//
//  GreatestHealingPotion.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation
import UIKit

struct GreatestHealingPotion: Ability {
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
        return nil
    }
    
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "greaterHealingPotionSpriteSheet"
    }
    
    var cost: Int { return 399 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .greatestHealingPotion }
    
    var description: String {
        return "Restores 3 health."
    }
    
    var flavorText: String {
        return "I held my nose, I closed my eyes, I took 3 drinks."
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
    
    var heal: Int? { return 3 }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.player(.playerZero)] }
}
