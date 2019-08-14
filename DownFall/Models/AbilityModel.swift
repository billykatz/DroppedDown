//
//  AbilityModel.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct AnyAbility {
    let _ability: Ability
    init(_ ability: Ability) {
        _ability = ability
    }
}

extension AnyAbility: Ability {
    func blocksDamage(from: Direction) -> Int? {
        return _ability.blocksDamage(from: from)
    }
    
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
    var sprite: SKSpriteNode? { get }
    func blocksDamage(from: Direction) -> Int?
}

extension Ability {
    var sprite: SKSpriteNode? {
        return SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: CGSize(width: 50.0, height: 50.0))
    }
}

enum AbilityType {
    case doubleAttack
    case sheildEast
}

