//
//  StoreOffer.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit


typealias StoreOfferTier = Int

struct StoreOffer: Codable, Hashable, Identifiable {
    var id: String {
        return self.textureName
    }
    
    static func ==(_ lhsOffer: StoreOffer, _ rhsOffer: StoreOffer) -> Bool {
        return lhsOffer.type == rhsOffer.type
    }
    
    static let zero = StoreOffer(type: .greaterHeal, tier: 0, textureName: "zero", currency: .gem, title: "zero", body: "zero", startingPrice: 0)
    
    
    let type: StoreOfferType
    let tier: StoreOfferTier
    let textureName: String
    let currency: Currency
    let title: String
    let body: String
    
    var sprite: SKSpriteNode {
        if hasSpriteSheet {
            let fallbackSprite = SKSpriteNode(texture: SKTexture(imageNamed: self.textureName))
            guard let columns = spriteSheetColumns else { return fallbackSprite }
            return SpriteSheet(texture: SKTexture(imageNamed: textureName), rows: 1, columns: columns).firstFrame() ?? fallbackSprite
        } else {
            return SKSpriteNode(texture: SKTexture(imageNamed: self.textureName))
        }
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
        case .dodge(let amount):
            title = "Increase Dodge Chance"
            body = "Increase your chance to dodge an enemy's attack by \(amount)%"
            textureName = "dodge"
        case .gems(let amount):
            title = "Gems"
            body = "Gain \(amount) gems."
            textureName = "crystals"
        case .luck:
            title = "Luck Up"
            body = "Increase the frequency and overall number of gems you find."
            textureName = "luck"
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
            textureName = "blankRune"
        case .plusOneMaxHealth:
            title = "Increase Max Health"
            body = "Add 1 max health."
            textureName = "plusOneHeart"
        case .lesserHeal:
            title = "Lesser Healing Potion"
            body = "Heals 1 HP."
            textureName = "lesserHealingPotionSpriteSheet"
        case .greaterHeal:
            title = "Greater Healing Potion"
            body = "Heals 2 HP."
            textureName = "greaterHealingPotionSpriteSheet"
        case .killMonsterPotion:
            title = "Death Potion"
            body = "Instantly kills a random monster"
            textureName = "killMonsterPotionSpriteSheet"
        case .transmogrifyPotion:
            title = "Trans-Mogrify Potion"
            body = "Instantly transform a random monster into another random monster"
            textureName = "transmogrificationPotionSpriteSheet"
        }
        
        return StoreOffer(type: type, tier: tier, textureName: textureName, currency: .gem, title: title, body: body, startingPrice: 0)
    }
    
    var hasSpriteSheet: Bool {
        switch self.type {
        case .killMonsterPotion, .transmogrifyPotion, .lesserHeal, .greaterHeal:
            return true
        default:
            return false
        }
    }
    
    var spriteSheetColumns: Int? {
        switch self.type {
        case .killMonsterPotion:
            return 7
        case .transmogrifyPotion:
            return 6
        case .lesserHeal, .greaterHeal:
            return 5
        default:
            return nil
        }
    }
    
    var effect: EffectModel {
        switch self.type {
        case .lesserHeal:
            let effect = EffectModel(kind: .buff, stat: .health, amount: 1, duration: Int.max, offerTier: tier)
            return effect
        case .greaterHeal:
            let effect = EffectModel(kind: .buff, stat: .health, amount: 2, duration: Int.max, offerTier: tier)
            return effect
        case .plusOneMaxHealth:
            let effect = EffectModel(kind: .buff, stat: .maxHealth, amount: 1, duration: Int.max, offerTier: tier)
            return effect
        case .plusTwoMaxHealth:
            let effect = EffectModel(kind: .buff, stat: .maxHealth, amount: 2, duration: Int.max, offerTier: tier)
            return effect
        case .rune(let rune):
            let effect = EffectModel(kind: .rune, stat: .pickaxe, amount: 0, duration: 0, rune: rune, offerTier: tier)
            return effect
        case .gems(let amount):
            let effect = EffectModel(kind: .buff, stat: .gems, amount: amount, duration: 0, offerTier: tier)
            return effect
        case .runeUpgrade:
            let effect = EffectModel(kind: .buff, stat: .pickaxe, amount: 10, duration: 0, offerTier: tier)
            return effect
        case .runeSlot:
            let effect = EffectModel(kind: .buff, stat: .runeSlot, amount: 1, duration: 0, offerTier: tier)
            return effect
        case .dodge(let amount):
            let effect = EffectModel(kind: .buff, stat: .dodge, amount: amount, duration: 0, offerTier: tier)
            return effect
        case .luck(let amount):
            let effect = EffectModel(kind: .buff, stat: .luck, amount: amount, duration: 0, offerTier: tier)
            return effect
        case .killMonsterPotion:
            let effect = EffectModel(kind: .killMonster, stat: .oneTimeUse, amount: Int.max, duration: 0, offerTier: tier)
            return effect
        case .transmogrifyPotion:
            let effect = EffectModel(kind: .transmogrify, stat: .oneTimeUse, amount: Int.max, duration: 0, offerTier: tier)
            return effect
            
        }
    }
    
    var rune: Rune? {
        if case StoreOfferType.rune(let rune) = self.type {
            return rune
        }
        return nil
    }
}

