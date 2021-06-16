//
//  StoreOffer.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

enum StoreOfferType: Codable, Hashable {
    static func ==(lhs: StoreOfferType, rhs: StoreOfferType) -> Bool {
        switch (lhs, rhs) {
        case (.plusOneMaxHealth, .plusOneMaxHealth): return true
        case (.plusTwoMaxHealth, .plusTwoMaxHealth): return true
            
        case (.runeUpgrade, .runeUpgrade): return true
        case (.runeSlot, .runeSlot): return true
        case (.rune(let lhsRune), .rune(let rhsRune)): return lhsRune == rhsRune
            
        case (.gems(_), .gems(_)): return true
        case (.dodge(_), .dodge(_)): return true
        case (.luck(_), .luck(_)): return true
            
        case (.greaterHeal, .greaterHeal): return true
        case (.lesserHeal, .lesserHeal): return true
            
        case (.killMonsterPotion, killMonsterPotion): return true
        case (.transmogrifyPotion, .transmogrifyPotion): return true
            
        // default cases to catch and return false for any other comparisons
        case (.plusOneMaxHealth, _): return false
        case (.plusTwoMaxHealth, _): return false
        case (.runeUpgrade, _): return false
        case (.runeSlot, _): return false
        case (.rune(_), _): return false
        case (.gems(_), _): return false
        case (.dodge(_), _): return false
        case (.luck(_), _): return false
        case (.greaterHeal, _): return false
        case (.lesserHeal, _): return false
        case (.killMonsterPotion,_): return false
        case (.transmogrifyPotion, _): return false
    
        }
    }
    
    case plusTwoMaxHealth
    case plusOneMaxHealth
    case rune(Rune)
    case runeUpgrade
    case runeSlot
    case gems(amount: Int)
    case dodge(amount: Int)
    case luck(amount: Int)
    case lesserHeal
    case greaterHeal
    case killMonsterPotion
    case transmogrifyPotion
    
    enum CodingKeys: String, CodingKey {
        case base
        case runeModel
        case gemAmount
        case dodgeAmount
        case luckAmount
    }
    
    private enum Base: String, Codable {
        case plusTwoMaxHealth
        case rune
        case runeUpgrade
        case runeSlot
        case gems
        case dodge
        case luck
        case plusOneMaxHealth
        case lesserHeal
        case greaterHeal
        case killMonsterPotion
        case transmogrifyPotion
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .plusTwoMaxHealth:
            self = .plusTwoMaxHealth
        case .rune:
            let data = try container.decode(Rune.self, forKey: .runeModel)
            self = .rune(data)
        case .runeUpgrade:
            self = .runeUpgrade
        case .runeSlot:
            self = .runeSlot
        case .gems:
            let amount = try container.decode(Int.self, forKey: .gemAmount)
            self = .gems(amount: amount)
        case .dodge:
            let amount = try container.decode(Int.self, forKey: .dodgeAmount)
            self = .dodge(amount: amount)
        case .luck:
            let amount = try container.decode(Int.self, forKey: .luckAmount)
            self = .luck(amount: amount)
        case .plusOneMaxHealth:
            self = .plusOneMaxHealth
        case .lesserHeal:
            self = .lesserHeal
        case .greaterHeal:
            self = .greaterHeal
        case .transmogrifyPotion:
            self = .transmogrifyPotion
        case .killMonsterPotion:
            self = .killMonsterPotion
        }
    }
    
    /// This implementation is written about in https://medium.com/@hllmandel/codable-enum-with-associated-values-swift-4-e7d75d6f4370
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .plusTwoMaxHealth:
            try container.encode(Base.plusTwoMaxHealth, forKey: .base)
        case .rune(let runeModel):
            try container.encode(Base.rune, forKey: .base)
            try container.encode(runeModel, forKey: .runeModel)
        case .runeUpgrade:
            try container.encode(Base.runeUpgrade, forKey: .base)
        case .runeSlot:
            try container.encode(Base.runeSlot, forKey: .base)
        case .gems(let amount):
            try container.encode(Base.gems, forKey: .base)
            try container.encode(amount, forKey: .gemAmount)
        case .dodge(let amount):
            try container.encode(Base.dodge, forKey: .base)
            try container.encode(amount, forKey: .dodgeAmount)
        case .luck(let amount):
            try container.encode(Base.luck, forKey: .base)
            try container.encode(amount, forKey: .luckAmount)
        case .lesserHeal:
            try container.encode(Base.lesserHeal, forKey: .base)
        case .greaterHeal:
            try container.encode(Base.greaterHeal, forKey: .base)
        case .plusOneMaxHealth:
            try container.encode(Base.plusOneMaxHealth, forKey: .base)
        case .killMonsterPotion:
            try container.encode(Base.killMonsterPotion, forKey: .base)
        case .transmogrifyPotion:
            try container.encode(Base.transmogrifyPotion, forKey: .base)
        }
    }
    
}

typealias StoreOfferTier = Int

struct StoreOffer: Codable, Hashable {
    static func ==(_ lhsOffer: StoreOffer, _ rhsOffer: StoreOffer) -> Bool {
        return lhsOffer.type == rhsOffer.type
    }
    
    
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
    
    
    /// All the offers in a given tier
    static func offers(in tier: StoreOfferTier, from offers: [StoreOffer]) -> [StoreOffer] {
        return offers.filter { $0.tier == tier }
    }
    
    /// the number of tiers in all of the offers
    static func numberOfTiers(in offers: [StoreOffer]) -> Int {
        return offers.map { $0.tier }.removingDuplicates().count
    }
    
    /// Remove any player runes from the offers so we dont offer the same rune
    static func removePlayerRunes(storeOffers: [StoreOffer], playerData: EntityModel) -> [StoreOffer] {
        guard let runes = playerData.runes else { return storeOffers }
        let newOffers = storeOffers.filter { offer in
            if case StoreOfferType.rune(let rune) = offer.type {
                return !runes.contains(where: { $0.type == rune.type } )
            }
            return true
        }
        return newOffers
    }
    
    /// Trim down the store offers so that we offer a maximum of two
    static func trimStoreOffers(storeOffers: [StoreOffer], playerData: EntityModel) -> [StoreOffer] {
        let maximumPerTier = 2
        var newOffers: [StoreOffer] = []
        for tier in 1..<numberOfTiers(in: storeOffers)+1 {
            let tierOffers = offers(in: tier, from: storeOffers)
            var tierOffersWithoutPlayerRunes = removePlayerRunes(storeOffers: tierOffers, playerData: playerData)
            if tierOffersWithoutPlayerRunes.count > maximumPerTier {
                tierOffersWithoutPlayerRunes = tierOffersWithoutPlayerRunes.choose(random: 2)
            }
            newOffers.append(contentsOf: tierOffersWithoutPlayerRunes)
        }
        
        return newOffers
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
            textureName = "trustMe"
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
            title = "Transmogrify Potion"
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

