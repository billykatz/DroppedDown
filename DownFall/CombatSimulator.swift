//
//  CombatHelper.swift
//  DownFall
//
//  Created by William Katz on 4/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation


struct CombatSimulator {
    static func simulate(attacker: EntityModel,
                         defender: EntityModel,
                         attacked from: Direction) -> (EntityModel, EntityModel) {
        let newAttacker = attacker.didAttack()
        
        //create new defender model reflecting new state
        let newDefender = defender.wasAttacked(for: attacker.attack.damage, from: from)
        
        return (newAttacker, newDefender)
    }
    
    static func simulate(attacker: EntityModel,
                         defender: EntityModel,
                         attacked from: Direction,
                         threatLevel: ThreatLevel) -> (EntityModel, EntityModel) {
        let newAttacker = attacker.didAttack()
        
        //create new defender model reflecting new state
        let newDefender = defender.wasAttacked(for: attacker.attack.damage * threatLevel.color.goldDamageMultiplier, from: from)
        
        return (newAttacker, newDefender)
    }

}

