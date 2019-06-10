//
//  CombatHelper.swift
//  DownFall
//
//  Created by William Katz on 4/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

protocol Option: RawRepresentable, Hashable, CaseIterable {}

enum Direction: String, Option, Codable {
    case north, south, east, west
}

typealias Directions = Set<Direction>
typealias Vector = (Directions, ClosedRange<Int>)

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }
        
        return rawValue
    }
}

extension Set where Element == Direction {
    static var sideways: Set<Direction> {
        return [.east, .west]
    }
    
    static var upDown: Set<Direction> {
        return [.north, .south]
    }
    
    static var all: Set<Direction> {
        return Set(Element.allCases)
    }
}

struct Weapon: Equatable, Hashable {
    enum Durability: Equatable, Hashable {
        case unlimited
        case limited(Int)
    }
    
    enum AttackType: Equatable, Hashable {
        case melee, ranged
    }
    
    let range: Int
    let damage: Int
    let direction: Directions
    let attackType: AttackType
    let durability: Durability
    let chargeTime: Int
    let currentCharge: Int
    
    static let pickAxe: Weapon = Weapon(range: 1,
                                        damage: 1,
                                        direction: [.south],
                                        attackType: .melee,
                                        durability: .unlimited,
                                        chargeTime: 0,
                                        currentCharge: 0)
    
    static let mouth: Weapon = Weapon(range: 1,
                                      damage: 1,
                                      direction: .sideways,
                                      attackType: .melee,
                                      durability: .unlimited,
                                      chargeTime: 0,
                                      currentCharge: 0)
}

struct Attack {
    let damage: Int
}


struct CombatSimulator {
    static func simulate(attacker: EntityModel, defender: EntityModel) -> (EntityModel, EntityModel) {
        // get the attack damage
        let attackDamage = attacker.attack.damage
        
        //create new attacker models reflecting updated state
        let newAttackerAttack = AttackModel(frequency: attacker.attack.frequency,
                                            range: attacker.attack.range,
                                            damage: attacker.attack.damage,
                                            directions: attacker.attack.directions,
                                            animationPaths: attacker.attack.animationPaths,
                                            hasAttacked: true)
        
        let newAttacker = EntityModel(hp: attacker.hp,
                                      name: attacker.name,
                                      attack: newAttackerAttack,
                                      type: attacker.type,
                                      carry: attacker.carry)
        
        //create new defender model reflecting new state
        let newDefender = EntityModel(hp: defender.hp - attackDamage,
                                      name: defender.name,
                                      attack: defender.attack,
                                      type: defender.type,
                                      carry: defender.carry)
        
        return (newAttacker, newDefender)
    }
}

