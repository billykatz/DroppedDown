//
//  StoreOffer.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

enum StoreOfferType: Equatable {
    static func ==(lhs: StoreOfferType, rhs: StoreOfferType) -> Bool {
        switch (lhs, rhs) {
        case (.fullHeal, .fullHeal): return true
        case (.plusTwoMaxHealth, .plusTwoMaxHealth): return true
        case (.runeUpgrade, .runeUpgrade): return true
        case (.gems(_), .gems(_)): return true
        case (.rune, .rune):
            return true
        default: return false
        }
    }
    
    case fullHeal
    case plusTwoMaxHealth
    case rune(Rune)
    case runeUpgrade
    case runeSlot
    case gems(amount: Int)
    case dodge
    case luck
}

typealias StoreOfferTier = Int

struct StoreOffer {
    let type: StoreOfferType
    let tier: StoreOfferTier
    let textureName: String
    let currency: Currency
    let title: String
    let body: String
    var sprite: SKSpriteNode {
        return SKSpriteNode(texture: SKTexture(imageNamed: self.textureName))
    }
    let startingPrice: Int
    
    var description: String {
        switch self.type {
        case .rune(let rune):
            return rune.fullDescription
        case .gems(amount: let amount):
            return "Immediately gain \(amount) gem\(amount > 1 ? "s" : "")."
        default:
            return self.body
        }
    }
    
    var tierIndex: Int {
        return tier - 1
    }
    
    static func offer(type: StoreOfferType, tier: StoreOfferTier) -> StoreOffer {
        let title: String
        let body: String
        let textureName: String
        switch type {
        case .dodge:
            textureName = "dodgeUp"
            title = "Increase Dodge Chance"
            body = "Increase your chance to dodge an enemy's attack by 5%"
        case .fullHeal:
            title = "Greater Healing Potion"
            body = "Fully heals you."
            textureName = "greaterHealingPotion"
        case .gems(let amount):
            title = "Gems"
            body = "Gain \(amount) gems."
            textureName = "crystals"
        case .luck:
            title = "Luck Up"
            body = "Increase the frequency and overall number of gems you find."
            textureName = "luckUp"
        case .plusTwoMaxHealth:
            title = "Increase Max Health"
            body = "Add 2 max health."
            textureName = "twoMaxHealth"
        case .rune(let rune):
            title = rune.type.humanReadable
            body = rune.fullDescription
            textureName = rune.textureName
        case .runeSlot:
            title = "+1 Rune Slot"
            body = "Add a rune slot to your pickaxe handle"
            textureName = "runeSlot"
        case .runeUpgrade:
            title = "Rune Upgrade"
            body = "Your runes will be better"
            textureName = "trustMe"
        }
        
        return StoreOffer(type: type, tier: tier, textureName: textureName, currency: .gem, title: title, body: body, startingPrice: 0)
    }
}

