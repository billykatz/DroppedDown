//
//  CombatTileData.swift
//  DownFall
//
//  Created by William Katz on 5/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

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

