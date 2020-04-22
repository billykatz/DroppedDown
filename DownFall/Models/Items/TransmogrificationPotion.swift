//
//  TransmogrificationPotion.swift
//  DownFall
//
//  Created by Katz, Billy on 1/16/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct TransmogrificationPotion: Ability {
    
    var cooldown: Int { return 0 }
    
    var rechargeType: [TileType] { return [] }
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return 6
    }
    
    var affectsCombat: Bool {
        false
    }
    
    var type: AbilityType { return .transmogrificationPotion }
    
    var textureName: String {
        return "transmogrificationPotionSpriteSheet"
    }
    
    var cost: Int { return 79 }
    
    var currency: Currency {
        return .gold
    }
    
    var description: String {
        return "Transform any monster into another random monster."
    }
    
    var flavorText: String {
        return "Archmaester Killian stumbled upon this in search for a potion to cure this father-in-law of idiocy."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    var usage: Usage {
        .once
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var heal: Int? { return nil }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.monster(.zero)] }
}


