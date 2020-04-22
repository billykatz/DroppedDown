//
//  FreeRainEmbers.swift
//  DownFall
//
//  Created by Katz, Billy on 4/19/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Foundation

struct FreeRainEmbers: Ability {
    
    var cooldown: Int { return 20 }
    
    var rechargeType: [TileType] { return [TileType.rock(.red)] }
    
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
        return "rainEmbers"
    }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .rainEmbers }
    
    var description: String {
        return "Fling a fireball at a monster"
    }
    
    var flavorText: String {
        return "Fire is my second favorite word, second only to `combustion.` - Macrkarel the Fish Wizard"
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .permanent
    }
    
    var heal: Int? { return nil }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return [TileType.monster(.zero)] }
}

