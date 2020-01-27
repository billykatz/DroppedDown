//
//  RockASwap.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct RockASwap: Ability {
    
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
        return "rockaswap"
    }
    
    var cost: Int { return 99 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .rockASwap }
    
    var description: String {
        return "Swap one rock with any other rock."
    }
    
    var flavorText: String {
        return "Goblins use this spell all the time to swap goblin husbands."
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
    
    var heal: Int? { return nil }
    var targets: Int? { return 2 }
    var targetTypes: [TileType]? { return TileType.rockCases }
}

