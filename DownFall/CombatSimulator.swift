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
                         attacked from: Direction) -> (EntityModel, EntityModel, Bool) {
        let newAttacker = attacker.didAttack()
        
        let defenderDodged: Bool = defender.doesDodge()
        
        let damage = defenderDodged ? 0 : attacker.attack.damage
        
        //create new defender model reflecting new state
        let newDefender = defender.wasAttacked(for: damage, from: from)
        
        return (newAttacker, newDefender, defenderDodged)
    }
    
    static func simulate(attacker: EntityModel,
                         defender: EntityModel,
                         attacked from: Direction) -> (EntityModel, EntityModel) {
        let newAttacker = attacker.didAttack()
        
        //create new defender model reflecting new state
        let newDefender = defender.wasAttacked(for: attacker.attack.damage, from: from)
        
        return (newAttacker, newDefender)
    }

}

