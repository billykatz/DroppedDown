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
    case gems(amount: Int)
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
}
