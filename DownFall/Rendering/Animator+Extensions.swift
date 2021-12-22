//
//  Animator+Extensions.swift
//  DownFall
//
//  Created by Billy on 12/21/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

extension Animator {
    
    func createPillarTakingDamage(sprites: [[DFTileSpriteNode]], pillarsThatTakeDamage: [PillarTakesDamage]) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        for pillarsThatTakeDamage in pillarsThatTakeDamage {
            let sprite = sprites[pillarsThatTakeDamage.tileCoord]
            if let takesDamage = sprite.pillarCrumble() {
                spriteActions.append(takesDamage)
            }
        }
        return spriteActions
    }
    
}
