//
//  MassMineAbility.swift
//  DownFall
//
//  Created by Katz, Billy on 3/30/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct MassMinePickaxe: Ability {
    
    var cooldown: Int { return 0 }
    
    var rechargeType: [TileType] { return [] }
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return 3
    }
    
    var affectsCombat: Bool {
        false
    }
    
    var type: AbilityType { return .massMineRock }
    
    var textureName: String {
        return "explodeAnimation"
    }
    
    var cost: Int { return 299 }
    
    var currency: Currency {
        return .gold
    }
    
    var description: String {
        return "Destory all rocks of one color"
    }
    
    var flavorText: String {
        return "Boom a color of the rainbow"
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
    var targetTypes: [TileType]? { return TileType.rockCases }
}
