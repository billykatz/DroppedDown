//
//  AbilityModel.swift
//  DownFall
//
//  Created by William Katz on 8/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

struct AnyAbility: Hashable {
    var _ability: Ability
    init(_ ability: Ability) {
        _ability = ability
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_ability.textureName.hashValue)
    }
    
    //TODO: make hack better
    static let zero: AnyAbility = AnyAbility(Empty())
}

extension AnyAbility: Ability {
    var distanceBetweenTargets: Int? {
        return _ability.distanceBetweenTargets
    }
    
    var cooldown: Int {
        return _ability.cooldown
    }
    
    var rechargeType: [TileType] {
        return _ability.rechargeType
    }
    
    var rechargeMinimum: Int {
        return _ability.rechargeMinimum
    }
    
    var progressColor: UIColor {
        return _ability.progressColor
    }
    
    
    var count : Int {
        set {
            _ability.count = newValue
        }
        get {
            return _ability.count
        }
    }
    
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
    var count: Int { get set }
    var cooldown: Int { get }
    var rechargeType: [TileType] { get }
    var rechargeMinimum: Int { get }
    var progressColor: UIColor { get }
    var distanceBetweenTargets: Int? { get }
    
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

enum AbilityType: Equatable {
    
    case doubleAttack
    case sheildEast
    case rockASwap
    case dynamite
    case lesserHealingPotion
    case greaterHealingPotion
    case greatestHealingPotion
    case swordPickAxe
    case transmogrificationPotion
    case killMonsterPotion
    case tapAwayMonster
    case massMineRock
    case rainEmbers
    case getSwifty
    case transformRock
    
    var humanReadable: String {
        switch self {
        case .doubleAttack: return "Double Attack"
        case .sheildEast: return "Side Shield East"
        case .rockASwap: return "Rock a Swap"
        case .dynamite: return "Dynamite"
        case .lesserHealingPotion: return "Lesser Healing Potion"
        case .greaterHealingPotion: return "Greater Healing Potion"
        case .greatestHealingPotion: return "Greatest Healing Potion"
        case .swordPickAxe: return "Sword Pick Axe"
        case .transmogrificationPotion: return "Transmogrification Potion"
        case .killMonsterPotion: return "Kill Monster Potion"
        case .tapAwayMonster: return "Destory Monster Group"
        case .massMineRock: return "Mass Mine"
        case .rainEmbers: return "Rain Embers"
        case .getSwifty: return "Swift Shift"
        case .transformRock: return "Transform Rock"
            
        }
    }
}

enum Usage {
    case once
    case oneRun
    case permanent
    
    var message: String {
        switch self {
        case .once:
            return "One time use"
        case .oneRun:
            return "Passive ability for one run"
        case .permanent:
            return "Permanent upgrade"
        }
    }
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
