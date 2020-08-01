//
//  StoreOffer.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

enum StoreOfferType: Hashable {
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
}

