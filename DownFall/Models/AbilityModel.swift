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

class Ability: Equatable {
    
    //TODO: Actually implement
    static func == (lhs: Ability, rhs: Ability) -> Bool {
        return true
    }
    
    var affectsCombat: Bool
    var type: AbilityType
    var textureName: String
    var cost: Int
    var currency: Currency
    var description: String
    var flavorText: String
    var extraAttacksGranted: Int?
    var sprite: SKSpriteNode?
    var usage: Usage
    var targets: Int?
    var targetTypes: [TileType]?
    var heal: Int?
    var count: Int
    var cooldown: Int
    var rechargeType: [TileType]
    var rechargeMinimum: Int
    var progressColor: UIColor
    var distanceBetweenTargets: Int?
    var spriteSheet: SpriteSheet?
    
    func blocksDamage(from: Direction) -> Int? {
        return 0
    }
    func animatedColumns() -> Int? {
        return 0
    }
    
    /// Intenionally Empty. subclass must override
    init(
        affectsCombat: Bool,
        type: AbilityType,
        textureName: String,
        cost: Int,
        currency: Currency,
        description: String,
        flavorText: String,
        extraAttacksGranted: Int?,
        sprite: SKSpriteNode?,
        usage: Usage,
        targets: Int?,
        targetTypes: [TileType]?,
        heal: Int?,
        count: Int,
        cooldown: Int,
        rechargeType: [TileType],
        rechargeMinimum: Int,
        progressColor: UIColor,
        distanceBetweenTargets: Int?,
        spriteSheet: SpriteSheet?
    ) {
        self.affectsCombat = affectsCombat
        self.type = type
        self.textureName = textureName
        self.cost = cost
        self.currency = currency
        self.description = description
        self.flavorText = flavorText
        self.extraAttacksGranted = extraAttacksGranted
        self.sprite = sprite
        self.usage = usage
        self.targets = targets
        self.targetTypes = targetTypes
        self.heal = heal
        self.count = count
        self.cooldown = cooldown
        self.rechargeType = rechargeType
        self.rechargeMinimum = rechargeMinimum
        self.progressColor = progressColor
        self.distanceBetweenTargets = distanceBetweenTargets
        self.spriteSheet = spriteSheet
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
        case .tapAwayMonster: return "Destroy Monster Group"
        case .massMineRock: return "Mass Mine"
        case .rainEmbers: return "Rain Embers"
        case .getSwifty: return "Swift Shift"
        case .transformRock: return "Transform Rock"
            
        }
    }
}
