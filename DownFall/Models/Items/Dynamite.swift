//
//  Dynamite.swift
//  DownFall
//
//  Created by William Katz on 12/19/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

struct Dynamite: Ability {
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "dynamite"
    }
    
    var cost: Int { return 14 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .dynamite }
    
    var description: String {
        return "Destroys rocks in a 3x3 grid."
    }
    
    var flavorText: String {
        return "Boom boom boom boom, I want you to go boom."
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

