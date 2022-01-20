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
    private var _duration: Double?
    var duration: Double {
        get {
            return _duration ?? 0.0
        }
        set {
            _duration = newValue
        }
    }
    
    var tuple: (SKNode, SKAction) {
        return (sprite, action)
    }
    
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
    
    func run() {
        sprite.run(action)
    }
    
    func stop() {
        sprite.removeAllActions()
    }
    
    func waitBefore(delay: TimeInterval) -> SpriteAction {
        guard delay > 0 else { return self }
        var newSpriteAction = SpriteAction.init(sprite, action.waitBefore(delay: delay))
        newSpriteAction.duration = self.duration
        return newSpriteAction
    }
    
    var reversed: SpriteAction {
        var newSpriteAction = SpriteAction.init(sprite, action.reversed())
        newSpriteAction.duration = self.duration
        return newSpriteAction
    }
    
    func reverseAnimation(reverse: Bool) -> SpriteAction {
        if reverse {
            var newSpriteAction = SpriteAction.init(sprite, action.reversed())
            newSpriteAction.duration = self.duration
            return newSpriteAction
        } else {
            return self
        }
    }
}
