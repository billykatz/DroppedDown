//
//  AbilityModel.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct AnyAbility: Hashable {
    let _ability: Ability
    init(_ ability: Ability) {
        _ability = ability
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_ability.textureName.hashValue)
    }
    
    //TODO: make hack better
    static let zero: AnyAbility = AnyAbility(DoubleAttack())
}

extension AnyAbility: Ability {
    func animatedColumns() -> Int? {
        return _ability.animatedColumns()
    }
    
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
    
    var currency: Currency {
        return _ability.currency
    }
    
    var affectsCombat: Bool {
        return _ability.affectsCombat
    }
    
    var type: AbilityType {
        return _ability.type
    }
    
    var extraAttacksGranted: Int? {
        return _ability.extraAttacksGranted
    }
    
    var usage: Usage {
        return _ability.usage
    }
    
    var heal: Int? {
        return _ability.heal
    }
    
    
    var targets: Int? { return _ability.targets }
    var targetTypes: [TileType]? { _ability.targetTypes }
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
    var currency: Currency { get }
    var description: String { get }
    var flavorText: String { get }
    var extraAttacksGranted: Int? { get }
    var sprite: SKSpriteNode? { get }
    var usage: Usage { get }
    var targets: Int? { get }
    var targetTypes: [TileType]? { get }
    var heal: Int? { get }
    
    func blocksDamage(from: Direction) -> Int?
    func animatedColumns() -> Int?
}

extension Ability {
    var sprite: SKSpriteNode? {
        return SKSpriteNode(texture: SKTexture(imageNamed: textureName), size: CGSize(width: 50.0, height: 50.0))
    }
    
    var spriteSheet: SpriteSheet?  {
        guard let cols = animatedColumns() else { return nil }
        return SpriteSheet.init(texture: SKTexture(imageNamed: textureName), rows: 1, columns: cols)
    }
}

enum AbilityType: String, Decodable {
    case doubleAttack
    case sheildEast
    case rockASwap
    case dynamite
    case lesserHealingPotion
    case greaterHealingPotion
    case swordPickAxe
    case transmogrificationPotion
    case killMonsterPotion
}

enum Usage {
    case once
    case oneRun
    case permanent
}

enum Currency: String, CaseIterable  {
    case gold
    case gem = "gem2"
    
    var itemTyp: Item.ItemType {
        switch self {
        case .gold:
            return Item.ItemType.gold
        case .gem:
            return Item.ItemType.gem
        }
    }
}
