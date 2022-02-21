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
    
    let type: StoreOfferType
    let tier: StoreOfferTier
    let textureName: String
    let title: String
    let body: String
    
    var id: String {
        return self.textureName
    }
    
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
            return "Gain \(amount) gem\(amount > 1 ? "s" : "")."
        default:
            return self.body
        }
    }
    
    var tierIndex: Int {
        return tier - 1
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
        let effect: EffectModel
        switch self.type {
        case .lesserHeal:
            effect = EffectModel(kind: .buff, stat: .health, amount: 1, duration: Int.max)
            
        case .greaterHeal:
            effect = EffectModel(kind: .buff, stat: .health, amount: 2, duration: Int.max)
            
        case .plusOneMaxHealth:
            effect = EffectModel(kind: .buff, stat: .maxHealth, amount: 1, duration: Int.max)
            
        case .plusTwoMaxHealth:
            effect = EffectModel(kind: .buff, stat: .maxHealth, amount: 2, duration: Int.max)
            
        case .rune(let rune):
            effect = EffectModel(kind: .rune, stat: .pickaxe, amount: 0, duration: 0, rune: rune)
            
        case .gems(let amount):
            effect = EffectModel(kind: .buff, stat: .gems, amount: amount, duration: 0)
            
        case .runeUpgrade:
            effect = EffectModel(kind: .buff, stat: .pickaxe, amount: 10, duration: 0)
            
        case .runeSlot:
            effect = EffectModel(kind: .buff, stat: .runeSlot, amount: 1, duration: 0)
            
        case .dodge(let amount):
            effect = EffectModel(kind: .buff, stat: .dodge, amount: amount, duration: 0)
            
        case .luck(let amount):
            effect = EffectModel(kind: .buff, stat: .luck, amount: amount, duration: 0)
            
        case .killMonsterPotion:
            effect = EffectModel(kind: .killMonster, stat: .oneTimeUse, amount: Int.max, duration: 0)
            
        case .transmogrifyPotion:
            effect = EffectModel(kind: .transmogrify, stat: .oneTimeUse, amount: Int.max, duration: 0)
            
        case .sandals, .runningShoes, .wingedBoots:
            effect = EffectModel(kind: .buff, stat: .dodge, amount: type.dodgeAmount, duration: 0)
            
        case .fourLeafClover, .horseshoe, .luckyCat:
            effect = EffectModel(kind: .buff, stat: .luck, amount: type.luckAmount, duration: 0)
            
        case .gemMagnet:
            effect = EffectModel(kind: .gemMagnet, stat: .oneTimeUse, amount: 1, duration: 0)
            
        case .infusion:
            effect = EffectModel(kind: .infusion, stat: .oneTimeUse, amount: 1, duration: 0)
            
        }
        return effect
    }
    
    var rune: Rune? {
        if case StoreOfferType.rune(let rune) = self.type {
            return rune
        }
        return nil
    }
}

extension StoreOffer {
    
    static func ==(_ lhsOffer: StoreOffer, _ rhsOffer: StoreOffer) -> Bool {
        return lhsOffer.type == rhsOffer.type
    }
    
    static let zero = StoreOffer(type: .greaterHeal, tier: 0, textureName: "zero", title: "zero", body: "zero", startingPrice: 0)
    
    
    static func offer(type: StoreOfferType, tier: StoreOfferTier) -> StoreOffer {
        let title: String
        let body: String
        let textureName: String
        switch type {
        case .dodge(let amount):
            title = "Dodge Up"
            body = "Increase your chance to dodge an enemy's attack by \(amount)%"
            textureName = "dodge"
        case .gems(let amount):
            title = "Gems"
            body = "Gain \(amount) gems."
            textureName = "crystals"
        case .luck(let amount):
            title = "Luck Up"
            body = "Increase the frequency and overall number of gems you find by \(amount)%."
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
            textureName = "pickaxe-upgrade"
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
        case .sandals:
            title = "Sandals"
            body = "Slightly better than just socks\n+\(type.dodgeAmount) dodge"
            textureName = "sandals"
        case .runningShoes:
            title = "Running Shoes"
            body = "Sleek running shoes\n+\(type.dodgeAmount) dodge"
            textureName = "runningShoes"
        case .wingedBoots:
            title = "Winged Boots"
            body = "You may be able to keep up with Teri sporting a pair of these.\n+\(type.dodgeAmount) dodge"
            textureName = "wingedBoots"
        case .fourLeafClover:
            title = "4 Leaf Clover"
            body = "Miners carry around clovers to increase their chance of striking it rich.\n+\(type.luckAmount) luck"
            textureName = "clover"
        case .horseshoe:
            title = "Horseshoe"
            body = "Miners hang these on their mantles to keep evil spirits at bay.\n+\(type.luckAmount) luck"
            textureName = "horseshoe"
        case .luckyCat:
            title = "Lucky Cat"
            body = "Teri might not appreciate you carrying this ceramic cat.\n+\(type.luckAmount) luck"
            textureName = "luckyCat"
        case .gemMagnet:
            title = "Gem Magnet"
            body = "Collect all gems on the board"
            textureName = "gemMagnet"
        case .infusion:
            title = "Infusion"
            body = "Infuse a random nearby rock with a gem."
            textureName = "infusion"
            
        }
        
        return StoreOffer(type: type, tier: tier, textureName: textureName, title: title, body: body, startingPrice: 0)
    }

    
}
