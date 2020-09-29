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
    
    enum CodingKeys: String, CodingKey {
        case base
        case runeModel
        case gemAmount
        
    }
    
    private enum Base: String, Codable {
        case fullHeal
        case plusTwoMaxHealth
        case rune
        case runeUpgrade
        case runeSlot
        case gems
        case dodge
        case luck
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .fullHeal:
            self = .fullHeal
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
            self = .dodge
        case .luck:
            self = .luck
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
        case .dodge:
            try container.encode(Base.dodge, forKey: .base)
        case .luck:
            try container.encode(Base.luck, forKey: .base)
        case .fullHeal:
            try container.encode(Base.fullHeal, forKey: .base)
        }
    }
    
}

typealias StoreOfferTier = Int

struct StoreOffer: Codable, Hashable {
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
    
    
    static func storeOffer(depth: Depth) -> [StoreOffer] {
        
        /// Baseline offers for every level after the first
        var storeOffers: [StoreOffer] = [
            StoreOffer.offer(type: .fullHeal, tier: 1),
            StoreOffer.offer(type: .plusTwoMaxHealth, tier: 1)
        ]
        
        /// some tier two offers
        let dodgeUp = StoreOffer.offer(type: .dodge, tier: 2)
        let luckUp = StoreOffer.offer(type: .luck, tier: 2)
        let gemsOffer = StoreOffer.offer(type: .gems(amount: 3), tier: 2)
        
        /// rune offerings
        let getSwifty = StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 3)
        let rainEmbers = StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 3)
        let transform = StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 3)
        let vortex = StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 3)
        let bubbleUp = StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 3)
        let flameWall = StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 3)
        
        switch depth {
        /// 1 Rune Slot
        case 0:
            /// This is a special case where we want to start our play testers with a rune
            let getSwifty = StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 1)
            let rainEmbers = StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 1)
            let transform = StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 1)
            return [getSwifty, rainEmbers, transform]
        case 1:
            // two goals
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            
        case 2:
            // Two Rune Slots
            /// two goals
            let getSwifty = StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 2)
            let rainEmbers = StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2)
            let transform = StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 2)
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform])
        case 3:
            /// offer a rune slot or gems
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            let gemOffer = StoreOffer.offer(type: .gems(amount: 5), tier: 3)
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform, vortex, bubbleUp, flameWall, gemOffer])
            
        case 4:
            /// Three Rune Slots
            /// give the player chance to fill their last rune slot or just gems
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform, transform, vortex, bubbleUp, flameWall])
        case 5:
            /// give the player a chance at the rune slot
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            let gemOffer = StoreOffer.offer(type: .gems(amount: 10), tier: 3)
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform, transform, vortex, bubbleUp, flameWall, gemOffer])
            
        case 6:
            /// Four Rune Slots
            /// give the player a chance to fill their last rune slot or just gems
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            let gemOffer = StoreOffer.offer(type: .gems(amount: 10), tier: 3)
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform, transform, vortex, bubbleUp, flameWall, gemOffer])
            
        case (7...Int.max):
            /// give the player a chance to fill their last rune slot or just gems
            storeOffers.append(contentsOf: [dodgeUp, luckUp, gemsOffer])
            let gemOffer = StoreOffer.offer(type: .gems(amount: 12), tier: 3)
            storeOffers.append(contentsOf: [getSwifty, rainEmbers, transform, transform, vortex, bubbleUp, flameWall, gemOffer])
        default:
            fatalError("Depth must be postitive Int")
        }
        
        return storeOffers
    }
    
    var effect: EffectModel {
        switch self.type {
        case .fullHeal:
            let effect = EffectModel(kind: .refill, stat: .health, amount: 0, duration: 0, offerTier: tier)
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
        case .dodge:
            let effect = EffectModel(kind: .buff, stat: .dodge, amount: 5, duration: 0, offerTier: tier)
            return effect
        case .luck:
            let effect = EffectModel(kind: .buff, stat: .luck, amount: 5, duration: 0, offerTier: tier)
            return effect
            
        }
    }
}

