//
//  AbilityModel.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation


struct AnyAbility {
    let _ability: Ability
    init(_ ability: Ability) {
        _ability = ability
    }
}

extension AnyAbility: Ability {
    
    var description: String {
        return _ability.description
    }
    
    var flavorText: String {
        return _ability.flavorText
    }
    
    
    var textureName: String {
         return _ability.textureName
    }
    
    var cost: Int {
        return _ability.cost
    }
    
    var affectsCombat: Bool {
        return _ability.affectsCombat
    }
    
    var type: AbilityType {
        return _ability.type
    }
    
    var grantsExtraAttacks: Int? {
        return _ability.grantsExtraAttacks
    }
}

extension AnyAbility: Equatable {
    static func == (lhs: AnyAbility, rhs: AnyAbility) -> Bool {
        return lhs.type == rhs.type
    }
}

protocol Ability {
    var affectsCombat: Bool { get }
    var type: AbilityType { get }
    var textureName: String { get }
    var cost: Int { get }
    var description: String { get }
    var flavorText: String { get }
    var grantsExtraAttacks: Int? { get }
}

enum AbilityType {
    case doubleAttack
}

struct DoubleAttack: Ability {
    var affectsCombat: Bool {
        return true
    }
    
    var textureName: String {
        return "doubleAttack"
    }
    
    var cost: Int { return 2 }
    
    var type: AbilityType { return .doubleAttack }
    
    var description: String {
        return "Swing at your foes twice in one turn with this two headed pickaxe."
    }
    
    var flavorText: String {
        return "Gives whole new meaning to the ol' saying 'kill two birds with one pickaxe.'"
    }
    
    var grantsExtraAttacks: Int? {
        return 1
    }
}
