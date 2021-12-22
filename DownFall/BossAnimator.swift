//
//  BossAnimator.swift
//  DownFall
//
//  Created by Billy on 12/15/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftUI

/// Boss Animations
extension Animator {
    
    // MARK: - Functions to create SpirteActions
    
    func createToothAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let toothSprite = bossSprite?.spiderTooth else { return nil }
        
        let animationName = "tooth-close-animation"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 4)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        let reverse = animate.reversed()
        
        let action = SKAction.sequence(animate, reverse)
        
        var toothAnimation: SpriteAction = .init(toothSprite, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return toothAnimation
    }
    
    func createToothChompAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-tooth-chomp-animation-18"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 18)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        
        let action = SKAction.sequence(animate)
        
        var toothAnimation: SpriteAction = .init(bossSprite.spiderTooth, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return toothAnimation
    }
    
    func createToothChompFirstHalfAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-tooth-chomp-first-half-8"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 8)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        
        let action = SKAction.sequence(animate)
        
        var toothAnimation: SpriteAction = .init(bossSprite.spiderTooth, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return toothAnimation
    }
    
    func createToothChompSecondHalfAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-tooth-chomp-second-half-10"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 10)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        
        let action = SKAction.sequence(animate)
        
        var toothAnimation: SpriteAction = .init(bossSprite.spiderTooth, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return toothAnimation
    }
    
    func createAngryEyelidAnimation(reverse: Bool, waitBeforeDelay: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-angry-eyelids"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 7)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        
        var action = reverse ? SKAction.sequence(animate).reversed() : SKAction.sequence(animate)
        action = action.waitBefore(delay: waitBeforeDelay)
        var eyelidAnimation: SpriteAction = .init(bossSprite.spiderEyelids, action)
        eyelidAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return eyelidAnimation
        
        
        
    }

    
    // MARK: Functions that actually animate
    
    func animateAngryEyelids(completion: @escaping () -> Void) {
        if let animation = createAngryEyelidAnimation(reverse: false, waitBeforeDelay: 0.0) {
            
            if let animation2 = createAngryEyelidAnimation(reverse: true, waitBeforeDelay: 2.0) {
                let animations = [animation, animation2]
                animate(animations, completion: completion)
            }
            
            
        } else {
            completion()
        }
        
    }
    
    func animateTwistingHead(completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else { return }
        var spriteActions: [SpriteAction] = []
        
        // twist the head one way
        // then the other
        // then back to normal
        let rotateAngle: CGFloat = .pi/4
        let rotateSpeed: CGFloat = .pi/2
        let rotateDuration = rotateAngle / rotateSpeed
        let counterRotateAmount: CGFloat = rotateAngle/4
        let rotateClockwise: CGFloat = -rotateAngle
        let rotateCounterClockwise: CGFloat = rotateAngle
        let waitBetween: TimeInterval = 0.1
        let rotateTimes: Int = 1
        var delayBetween: TimeInterval = 0.0
        for idx in 0..<rotateTimes {
            
            // main rotate + reverse
            let rotateAmount = idx.isMultiple(of: 2) ? rotateClockwise : rotateCounterClockwise
            let rotateAction = SKAction.rotate(byAngle: rotateAmount, duration: rotateDuration)
            rotateAction.timingMode = .easeInEaseOut
            let reverse = rotateAction.reversed()
            reverse.timingMode = .easeInEaseOut
            
            // small counter rotate + reverse
            let counterRotateAction = SKAction.rotate(byAngle: counterRotateAmount, duration: rotateDuration/4)
            let reverseCounterRotate = counterRotateAction.reversed()
            reverseCounterRotate.timingMode = .easeOut
            counterRotateAction.timingMode = .easeIn
            
            // waiting and delaying
            let waitAction = SKAction.wait(forDuration: waitBetween)
            let delayBefore = SKAction.wait(forDuration: delayBetween)
            
            // sequence them all
            let action = SKAction.sequence([delayBefore, waitAction, counterRotateAction, rotateAction, waitAction, reverse, reverseCounterRotate])
            //            let action = SKAction.sequence([delayBefore, waitAction, rotateAction, waitAction, reverse])
            spriteActions.append(.init(bossSprite.spiderHead, action))
            
            delayBetween += (0.1 + 0.1 + 0.2 + 0.2)
        }
        
        
        
        animate(spriteActions, completion: completion)
    }
    
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
    
    func animateWalkingAnimation(moveVector: CGVector) -> [SpriteAction] {
        guard let bossSprite = bossSprite else { return [] }
        var spriteActions: [SpriteAction] = []
        
        let maxDistancePerStep: Double = 50
        let numberOfSteps = Int(Double(abs(moveVector.max) / maxDistancePerStep).rounded( .up))
        
        // shared variables
        let waitBetween = 0.2
        let waitBetweenAction = SKAction.wait(forDuration: waitBetween)
        var waitForPairA = 0.0
        var waitForPairB = 0.0
        let rotateSpeed: CGFloat = .pi*2
        var averageRotateDuration = 0.0
        func randomRange() -> CGFloat { return CGFloat.random(in: (CGFloat.pi/8)...(3*CGFloat.pi/8)) }
        
        // step aniations
        for _ in 0..<numberOfSteps {
            // left leg steps
            for (idx, legSprite) in bossSprite.leftLegs.enumerated() {
                let rotateAngle: CGFloat = -1 * randomRange()
                let rotateDuration = abs(rotateAngle) / rotateSpeed
                let rotateAction = SKAction.rotate(byAngle: rotateAngle, duration: rotateDuration)
                let reverse = rotateAction.reversed()
                let rotateBackAndForth = SKAction.sequence([rotateAction, waitBetweenAction, reverse])
                averageRotateDuration += (rotateDuration*2) + waitBetween
                if waitForPairB == 0 {
                    waitForPairB = rotateDuration * 2 + waitBetween
                }
                
                let actualWait = idx.isMultiple(of: 2) ? waitForPairA : waitForPairB
                
                let allAction = rotateBackAndForth.waitBefore(delay: actualWait)
                spriteActions.append(.init(legSprite, allAction))
            }
            
            // right leg steps
            for (idx, legSprite) in bossSprite.rightLegs.enumerated() {
                let otherSideRotateAngle: CGFloat = randomRange()
                let rotateDuration = otherSideRotateAngle / rotateSpeed
                let otherRotateAction = SKAction.rotate(byAngle: otherSideRotateAngle, duration: rotateDuration)
                let otherReverse = otherRotateAction.reversed()
                let rotateBackAndForth = SKAction.sequence([otherRotateAction, waitBetweenAction, otherReverse])
                
                let actualWait = idx.isMultiple(of: 2) ? waitForPairB : waitForPairA
                
                let allAction = rotateBackAndForth.waitBefore(delay: actualWait)
                spriteActions.append(.init(legSprite, allAction))
            }
            
            // tooth animation
            if let toothAnimation = createToothAnimation(delayBefore: waitForPairA) {
                spriteActions.append(toothAnimation)
            }
            
            waitForPairA += 1.0
            waitForPairB += 1.0
        }
        
        averageRotateDuration = averageRotateDuration/Double(bossSprite.leftLegs.count*numberOfSteps)

        let moveVector = CGVector(dx: moveVector.dx/CGFloat(numberOfSteps*2), dy: moveVector.dy/CGFloat(numberOfSteps*2))
        let bodyDuration = 0.25
        var bodyWaitBefore = 0.0
        for  _ in 0..<numberOfSteps*2 {
            let move = SKAction.move(by: moveVector, duration: bodyDuration)
            move.timingMode = .easeInEaseOut
            spriteActions.append(.init(bossSprite, move.waitBefore(delay: bodyWaitBefore)))
            
            // move the body up and down
            let bodyMoveYDistance: CGFloat = 10.0
            let bodyMoveDuration: TimeInterval = 0.10
            let waitBeforeBodyDown: TimeInterval = bodyMoveDuration + 0.2
            let bodyMoveUp = SKAction.moveBy(x: 0.0, y: bodyMoveYDistance, duration: bodyMoveDuration)
            let bodyMoveUpReverse = bodyMoveUp.reversed().waitBefore(delay: waitBeforeBodyDown)
            spriteActions.append(.init(bossSprite.spiderBody, bodyMoveUp.waitBefore(delay: bodyWaitBefore)))
            spriteActions.append(.init(bossSprite.spiderHead, bodyMoveUp.waitBefore(delay: bodyWaitBefore)))
            spriteActions.append(.init(bossSprite.spiderBody, bodyMoveUpReverse.waitBefore(delay: bodyWaitBefore)))
            spriteActions.append(.init(bossSprite.spiderHead, bodyMoveUpReverse.waitBefore(delay: bodyWaitBefore)))
            
            // wait for the next set
            bodyWaitBefore += bodyDuration + 0.2
            
        }
        
        return spriteActions
    }
    
    func animateLegMovement(completion: @escaping () -> Void) {
        let moveAmount = 75
        let moveLeft = animateWalkingAnimation(moveVector: CGVector(dx: -moveAmount, dy: 0))
        animate(moveLeft) {
            let up = animateWalkingAnimation(moveVector: CGVector(dx: 0, dy: moveAmount))
            animate(up) {
                let right = animateWalkingAnimation(moveVector: CGVector(dx: moveAmount, dy: 0))
                animate(right) {
                    let down = animateWalkingAnimation(moveVector: CGVector(dx: 0, dy: -moveAmount))
                    animate(down, completion: completion)
                }
            }
        }
    }
    
    func animateToothChomp(completion: @escaping () -> Void) {
//        guard let bossSprite = bossSprite else { return }
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothChompAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func animateToothClose(completion: @escaping () -> Void) {
//        guard let bossSprite = bossSprite else { return }
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func animateBossEatingRocks(sprites: [[DFTileSpriteNode]], foreground: SKNode, transformation: Transformation, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite,
              let firstHalfteethChomp = createToothChompFirstHalfAnimation(delayBefore: 0.0),
              let secondHalfTeethChomp = createToothChompSecondHalfAnimation(delayBefore: 0.0) else {
            completion()
            return
        }
        
        var spriteActions: [SpriteAction] = []
        
        /// get the rock sprites
        /// animate then to move to the spiders mouth
        /// animate them to explode
        let moveSpeed: CGFloat = 600.0
        var currentStagger: TimeInterval = 0.0
        let stagger: TimeInterval = 0.5
        if let rockCoords = transformation.tileTransformation?.map({ $0.initial }).sorted(by: { $0.row > $1.row }) {
            
            
            /// animate the teeth opening
            let delayedTeethChomp = firstHalfteethChomp.waitBefore(delay: currentStagger)
            spriteActions.append(delayedTeethChomp)
            
            // create the rock animations
            for coord in rockCoords {
                // recreate the sprite to remove the background indicator
                let sprite = sprites[coord.row][coord.col]
                let newSprite = DFTileSpriteNode(type: sprite.type, height: sprite.frame.height, width: sprite.frame.width)
                newSprite.position = sprite.position
                sprite.removeFromParent()
                foreground.addChild(newSprite)
                
                // action variables
                let moveTarget: CGPoint = bossSprite.convert(bossSprite.spiderTooth.centerRect.center.translateVertically(-100), to: foreground)
                let moveDistance = moveTarget - sprite.position
                let moveDuration = moveDistance.length / moveSpeed
                let spinSpeed: CGFloat = 8 * .pi
                let spinAngle = moveDuration * spinSpeed
                
                // create actions
                let spin = SKAction.rotate(byAngle: spinAngle, duration: moveDuration)
                let move = SKAction.move(to: moveTarget, duration: moveDuration)
                let spinAndMove = SKAction.group(spin, move, curve: .easeIn)
                
                spriteActions.append(.init(newSprite, spinAndMove.waitBefore(delay: currentStagger)))
                                
                let delayedTeethChompSecondHalf = secondHalfTeethChomp.waitBefore(delay: currentStagger + moveDuration)
                spriteActions.append(delayedTeethChompSecondHalf)
                
                
                if let crumble = newSprite.crumble(true, delayBefore: currentStagger + moveDuration) {
                    spriteActions.append(crumble)
                }
                
                currentStagger += stagger
            }
        }
        
        /// call the completion
        animate(spriteActions, completion: completion)
    }
    
    

}
