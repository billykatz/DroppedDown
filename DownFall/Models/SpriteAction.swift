//
//  SpriteAction.swift
//  DownFall
//
//  Created by Katz, Billy on 3/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

struct SpriteAction: Hashable {
    let sprite: SKNode
    let action: SKAction
    
    init(_ sprite: SKSpriteNode, _ action: SKAction) {
        self.sprite = sprite
        self.action = action
    }
    
    init(_ node: SKNode, _ action: SKAction) {
        self.sprite = node
        self.action = action
    }
    
    init(sprite: SKSpriteNode, action: SKAction) {
        self.sprite = sprite
        self.action = action
    }
}
