//
//  CombatHelper.swift
//  DownFall
//
//  Created by William Katz on 4/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation


struct CombatSimulator {
    static func simulate(attacker: EntityModel, defender: EntityModel) -> (EntityModel, EntityModel) {
        // get the attack damage
        let attackDamage = attacker.attack.damage
        
        //create new attacker models reflecting updated state
        let newAttackerAttack = AttackModel(frequency: attacker.attack.frequency,
                                            range: attacker.attack.range,
                                            damage: attacker.attack.damage,
                                            directions: attacker.attack.directions,
                                            hasAttacked: true)
        
        let newAttacker = EntityModel(hp: attacker.hp,
                                      name: attacker.name,
                                      attack: newAttackerAttack,
                                      type: attacker.type,
                                      carry: attacker.carry,
                                      animations: attacker.animations)
        
        //create new defender model reflecting new state
        let newDefender = EntityModel(hp: defender.hp - attackDamage,
                                      name: defender.name,
                                      attack: defender.attack,
                                      type: defender.type,
                                      carry: defender.carry,
                                      animations: defender.animations)
        
        return (newAttacker, newDefender)
    }
}

