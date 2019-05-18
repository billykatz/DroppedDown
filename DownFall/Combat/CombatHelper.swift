//
//  CombatHelper.swift
//  DownFall
//
//  Created by William Katz on 4/1/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

protocol Option: RawRepresentable, Hashable, CaseIterable {}

enum Direction: String, Option {
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

struct CombatTileData: Equatable, Hashable {
    
    let hp: Int
    let attacksThisTurn: Int
    let attacksPerTurn = 1
    let weapon: Weapon
    let hasGem: Bool
    
    static func monster() -> CombatTileData {
        return CombatTileData(hp: 1,
                              attacksThisTurn: 0,
                              weapon: .mouth,
                              hasGem: false)
    }

    static func player() -> CombatTileData {
        return CombatTileData(hp: 3,
                              attacksThisTurn: 0,
                              weapon: .pickAxe,
                              hasGem: false)
    }
    
    // collects gem
    func collectsGem() -> CombatTileData {
        return CombatTileData(hp: self.hp,
                              attacksThisTurn: 0,
                              weapon: self.weapon,
                              hasGem: true)
    }
    
    /// resets attacks
    func resetAttacksThisTurn() -> CombatTileData {
        return CombatTileData(hp: self.hp,
                              attacksThisTurn: 0,
                              weapon: self.weapon,
                              hasGem: self.hasGem)
    }
    
    ///updates the attacker
    func attacks(_ defender: CombatTileData) -> CombatTileData {
        let attacker = CombatTileData(hp: self.hp,
                                      attacksThisTurn: self.attacksThisTurn + 1,
                                      weapon: self.weapon,
                                      hasGem: self.hasGem)
        return attacker
    }
    
    /// updates the defender
    func attacked(by attacker: CombatTileData) -> CombatTileData {
        let defender = CombatTileData(hp: self.hp - attacker.weapon.damage,
                                      attacksThisTurn: self.attacksThisTurn,
                                      weapon: self.weapon,
                                      hasGem: self.hasGem)
        return defender
    }
    
    /// Computes a range of tiles that the weapon hits
    
    private var attackRange: ClosedRange<Int> {
        // the minimum range should be 1 so we cant attack or hurt ourselves
        return 1...self.weapon.range
    }
    

    var attackVector: Vector {
        return (self.weapon.direction, attackRange)
    }
    
    var canAttack: Bool {
        return attacksThisTurn < attacksPerTurn
    }
}


struct CombatSimulator {
    static func simulate(attacker: CombatTileData, defender: CombatTileData) -> (CombatTileData, CombatTileData) {
        let newAttacker = attacker.attacks(defender)
        let newDefender = defender.attacked(by: attacker)
        return (newAttacker, newDefender)
    }
}

