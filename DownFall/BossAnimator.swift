//
//  BossAnimator.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

/// Boss Animations
extension Animator {
    
    func animateEchoEffect(completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else { return }
        var spriteActions: [SpriteAction] = []
        
        // create 3x copies of the boss sprite
        var bossSpriteCopies: [SKSpriteNode] = Array(repeating: bossSprite, count: 3)
             
        // add them to the boss sprite
        let startingAlpha = 0.65
        for (idx, sprite) in bossSpriteCopies.enumerated() {
            let newSprite = sprite.copy() as! SKSpriteNode
            newSprite.removeFromParent()
            newSprite.position = .zero
            newSprite.alpha = startingAlpha
            bossSpriteCopies[idx] = newSprite
            bossSprite.addChild(newSprite)
        }
        
        // animate them scaling to different size and fading out
        let scaleStep: CGFloat = 0.25
        let scaleDuration = 0.5
        let targetAlpha: CGFloat = 0
        let delayBetween: TimeInterval = 0.05
        let totalSprites: CGFloat = CGFloat(bossSpriteCopies.count)
        var delayStart = 0.0
        for (idx, sprite) in bossSpriteCopies.enumerated() {
            let floatIdx = CGFloat(idx)
            let scaleTarget: CGFloat = 1 + (totalSprites - floatIdx * scaleStep)
            
            
            // scale and fade
            let scaleAction = SKAction.scale(by: scaleTarget, duration: scaleDuration)
            let fadeOutAction = SKAction.fadeAlpha(to: targetAlpha, duration: scaleDuration)
            let scaleAndFade = SKAction.group(scaleAction, fadeOutAction, curve: .easeInEaseOut)
            
            // wait and group / seq
            let wait = SKAction.wait(forDuration: delayStart)
            let waitThenScaleFade = SKAction.sequence([wait, scaleAndFade, .removeFromParent()])
            spriteActions.append(.init(sprite, waitThenScaleFade))
            
            delayStart += delayBetween
            
        }
        
        let fullDuration = delayStart + scaleDuration
        let shakeTheRealSpider = self.shakeNode(node: bossSprite, duration: fullDuration, amp: 10)
        spriteActions.append(shakeTheRealSpider)
        
        animate(spriteActions, completion: completion)
        
    }
    
    func animateLegMovement(completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else { return }
        var spriteActions: [SpriteAction] = []
        
        let waitBefore = 0.4
//        let waitDuration = 0.3
        let rotateDuration = waitBefore/2
        let rotateAngle: CGFloat = -.pi/4
        let rotateAction = SKAction.rotate(byAngle: rotateAngle, duration: rotateDuration)
        let reverse = rotateAction.reversed()
        for (idx, legSprite) in bossSprite.leftLegs.enumerated() {
            let rotateBackAndForth = SKAction.sequence([rotateAction, reverse])
        
            let actualWait = idx.isMultiple(of: 2) ? 0.0 : waitBefore
            
            let allAction = rotateBackAndForth.waitBefore(delay: actualWait)
//            let squash = SKAction.scaleX(by: 0.0, y: 0.2, duration: 0.1)
            spriteActions.append(.init(legSprite, allAction))
            
//            waitBefore += waitDuration
        }
        
        animate(spriteActions, completion: completion)
    }
    
}
