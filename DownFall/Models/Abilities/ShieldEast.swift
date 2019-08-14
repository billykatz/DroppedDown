//
//  ShieldEast.swift
//  DownFall
//
//  Created by William Katz on 8/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

struct ShieldEast: Ability {
    var affectsCombat: Bool {
        return true
    }
    
    var type: AbilityType {
        return .sheildEast
    }
    
    var textureName: String {
        return "shieldEast"
    }
    
    var cost: Int {
        return 5
    }
    
    var description: String {
        return "A shield that blocks 1 damage from attacks to your right"
    }
    
    var flavorText: String {
        return "It would certainly help to learn to use this on my left side"
    }
    
    var grantsExtraAttacks: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        if from == .east { return 1 }
        return nil
    }
    
    
}
