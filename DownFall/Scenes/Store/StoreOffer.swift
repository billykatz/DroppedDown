//
//  StoreOffer.swift
//  DownFall
//
//  Created by Katz, Billy on 5/2/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

enum StoreOfferType {
    case fullHeal
    case plusTwoMaxHealth
}

typealias StoreOfferTier = Int

struct StoreOffer {
    let type: StoreOfferType
    let tier: StoreOfferTier
    let textureName: String
    let currency: Currency
    var sprite: SKSpriteNode {
        return SKSpriteNode(texture: SKTexture(imageNamed: self.textureName))
    }
    let startingPrice: Int
}
