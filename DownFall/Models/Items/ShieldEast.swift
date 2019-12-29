//
//  ShieldEast.swift
//  DownFall
//
//  Created by William Katz on 8/11/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

struct ShieldEast: Ability {
    var affectsCombat: Bool {
        return true
    }
    
    var type: AbilityType {
        return .sheildEast
    }
    
    var textureName: String {
        return "shieldBlank"
    }
    
    var cost: Int {
        return 5
    }
    
    var currency: Currency { return .gold }
    
    var description: String {
        return "A shield that blocks 1 damage from attacks to your right"
    }
    
    var flavorText: String {
        return "It would certainly help to learn to use this on my left side"
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        if from == .east { return 1 }
        return nil
    }
    
    var sprite: SKSpriteNode? {
        let blankShield = SKTexture(imageNamed: textureName)
        let arrowEast = SKTexture(imageNamed: "arrowEast")
        let compositeSprite = SKSpriteNode(texture: blankShield, size: CGSize(width: 50, height: 50))
        compositeSprite.addChild(SKSpriteNode(texture: arrowEast, size: CGSize(width: 20, height: 20)))
        return compositeSprite
    }
    
    var usage: Usage {
        return .oneRun
    }
}
