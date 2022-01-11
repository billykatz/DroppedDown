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

fileprivate var sparkleAnimation1: SpriteSheet = {
    return SpriteSheet(textureName: "boss-spider-sparkle-v1-effect-animation-7", columns: 7)
}()

fileprivate var sparkleAnimation2: SpriteSheet = {
    return SpriteSheet(textureName: "boss-spider-sparkle-v2-effect-animation-7", columns: 7)
}()

fileprivate var sparkleAnimation3: SpriteSheet = {
    return SpriteSheet(textureName: "boss-spider-sparkle-v3-effect-animation-7", columns: 7)
}()

fileprivate var sparkleAnimation4: SpriteSheet = {
    return SpriteSheet(textureName: "boss-spider-sparkle-v4-effect-animation-9", columns: 9)
}()

fileprivate var sparkleAnimation5: SpriteSheet = {
    return SpriteSheet(textureName: "boss-spider-sparkle-v5-effect-animation-7", columns: 7)
}()

fileprivate var sparkleIndex = 0
fileprivate var sparkleAnimations = [sparkleAnimation1, sparkleAnimation2, sparkleAnimation3, sparkleAnimation4, sparkleAnimation5].shuffled()

/// Boss Animations
extension Animator {
    
    // MARK: - Functions to create SpirteActions
    func createTiltingHead(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let rotateAngle: CGFloat = .pi
        let rotateSpeed: CGFloat = .pi
        let rotateDuration = rotateAngle/rotateSpeed
        
        let counterRotateCoeffcient: CGFloat  = 1 / 8
        let counterRotateAmount = -rotateAngle * counterRotateCoeffcient
        let counterRotateDuration = rotateDuration * counterRotateCoeffcient
        
        
        let counterRotateAction = SKAction.rotate(byAngle: counterRotateAmount, duration: counterRotateDuration)
        counterRotateAction.timingMode = .easeInEaseOut

        let normalRotateAction = SKAction.rotate(byAngle: rotateAngle + abs(counterRotateAmount), duration: rotateDuration)
        normalRotateAction.timingMode = .easeInEaseOut
        
        let seq = SKAction.sequence(counterRotateAction, normalRotateAction)
        var spriteAction = SpriteAction(bossSprite.spiderHead, seq)
        spriteAction.duration = rotateDuration + counterRotateDuration
        spriteActions.append(spriteAction)
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: reversed, delay: delayBefore)
        
        return spriteActions
        
    }
    
    func createBeamOfPoisonAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else {
            return nil
        }
        
        let animationName = "boss-animation-posion-beam"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 6)
        let speedCoefficient: Double = 1
        let animation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: speedCoefficient * timePerFrame())
        let repeatCount = 4
        let loopAnimation = SKAction.repeat(animation, count: repeatCount)
        
        var spriteAction: SpriteAction = .init(bossSprite.spiderPoisonBeam, loopAnimation.waitBefore(delay: delayBefore))
        spriteAction.duration = (Double(spriteSheet.animationFrames().count) * (timePerFrame()*speedCoefficient)) * Double(repeatCount)
        
        return spriteAction
        
    }
    
    func createDynamiteFlyingIn(delayBefore: TimeInterval, startingPosition: CGPoint, targetPosition: CGPoint, targetSprite: DFTileSpriteNode, tileType: TileType, spriteForeground: SKNode) -> [SpriteAction]? {
        guard let tileSize = tileSize else { return nil }
        var spriteActions: [SpriteAction] = []
        
        // create a dynamite stick for each dynamiate
        let attackSprite = DFTileSpriteNode(type: tileType, height: tileSize, width: tileSize)
        if let fuseTiming = tileType.fuseTiming {
            attackSprite.showFuseTiming(fuseTiming)
        }
        
        
        // add them to the foreground
        attackSprite.position = startingPosition
        attackSprite.zPosition = 100_000
        spriteForeground.addChild(attackSprite)
        
        //stagger the initial throw of each dynamite
        var waitTime = 0.0
        // get the distance needed to travel
        let distance = targetPosition - startingPosition
        // set the speed
        let speed: Double = 750
        
        // determine the duration based on the distance to the target
        let duration = waitTime + (Double(distance.length) / speed)
        waitTime += Double.random(in: 0.25...0.35)
        
        let moveAction = SKAction.move(to: targetPosition, duration: duration)
        
        /// grow and shrink animation
        let scaleBy: CGFloat = 2
        let growAction = SKAction.scale(by: scaleBy, duration: duration/2)
        let shrinkAction = SKAction.scale(by: 1/scaleBy, duration: duration/2)
        let growSkrinkSequence = SKAction.sequence([growAction, shrinkAction])
        growSkrinkSequence.timingMode = .easeInEaseOut
        
        // "throw" it
        let moveGrowShrink = SKAction.group([moveAction, growSkrinkSequence])
        
        // run it in sequence
        let sequence = SKAction.sequence([moveGrowShrink])
        
        // crumble the rock that gets "hit"
        let spriteToRemoveOnLanding = targetSprite
        if let crumble = spriteToRemoveOnLanding.crumble() {
            let waitBeforeCrumble = SKAction.wait(forDuration: duration)
            let crumbleAction = crumble.action
            let sequence = SKAction.sequence([waitBeforeCrumble, crumbleAction])
            spriteActions.append(.init(spriteToRemoveOnLanding, sequence))
        }
        
        
        
        let attackAction: SpriteAction = .init(attackSprite, sequence.waitBefore(delay: delayBefore))
        
        spriteActions.append(attackAction)
        return spriteActions
        
    }

    
    // forward turns eyes yellow -> red
    // reverse turns eyes red -> yellow
    func createEyesTurnsRed(reverse: Bool, delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-animation-eyes-turn-red-8"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 8)
        let forardAnimation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        let animation = reverse ? forardAnimation.reversed() : forardAnimation
        
        var spriteAction: SpriteAction = .init(bossSprite.spiderEyes, animation.waitBefore(delay: delayBefore))
        spriteAction.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return spriteAction
        
    }
    
    func createSparkleAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        // move the sparkle around
        let flip: CGFloat = Bool.random() ? -1 : 1
        let randomScaleX = SKAction.scaleX(by: flip, y: 1, duration: 0.0)
        
        // logic to shuffle and reset sparkle animation index
        // makes sure we use all the sparkle animations before shuffling the array to use them again
        if sparkleIndex >= sparkleAnimations.count {
            sparkleAnimations = sparkleAnimations.shuffled()
            sparkleIndex = 0
        }
        let spriteSheet = sparkleAnimations[sparkleIndex]
        sparkleIndex += 1
        
        let sparkleAnimation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: sparkleTimePerFrame)
        let seq = SKAction.sequence(randomScaleX, sparkleAnimation)
        var spriteAction: SpriteAction = .init(bossSprite.spiderSparkle, seq.waitBefore(delay: delayBefore))
        spriteAction.duration = Double(spriteSheet.animationFrames().count) * sparkleTimePerFrame
        
        return spriteAction
    }
    
    func createBlinkAnimation(reverse: Bool, delayBefore: TimeInterval) -> SpriteAction? {
        guard let eyelids = bossSprite?.spiderEyelids else { return nil }
        
        let animationName = "boss-spider-blink-4"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 4)
        let forardAnimation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        let animation = reverse ? forardAnimation.reversed() : forardAnimation
        
        var spriteAction: SpriteAction = .init(eyelids, animation.waitBefore(delay: delayBefore))
        spriteAction.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return spriteAction
    }
    
    func createFullBlinkAnimation(delayBefore: TimeInterval) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        if let firstBlink = createBlinkAnimation(reverse: false, delayBefore: 0.0) {
            if let secondBlink = createBlinkAnimation(reverse: true, delayBefore: firstBlink.duration + delayBefore) {
                spriteActions.append(firstBlink)
                spriteActions.append(secondBlink)
            }
        }
        
        return spriteActions
    }
    
    func createToothSmallChompAnimation(delayBefore: TimeInterval) -> SpriteAction? {
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
        
        let animationName = "boss-spider-tooth-chomp-first-half-9"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 9)
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
    
    func createAngryEyebrows(reverse: Bool, waitBeforeDelay: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-angry-crystal-eyebrows"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 7)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: timePerFrame())
        
        var action = reverse ? SKAction.sequence(animate).reversed() : SKAction.sequence(animate)
        action = action.waitBefore(delay: waitBeforeDelay)
        var eyebrowAnimation: SpriteAction = .init(bossSprite.spiderEyebrowCrystals, action)
        eyebrowAnimation.duration = Double(spriteSheet.animationFrames().count) * timePerFrame()
        
        return eyebrowAnimation
    }
    
    func createAngryFace(reverse: Bool, waitBeforeDelay: TimeInterval) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        
        if let angryEyes = createAngryEyelidAnimation(reverse: reverse, waitBeforeDelay: waitBeforeDelay) {
            spriteActions.append(angryEyes)
        }
        
        if let angryEyebrows = createAngryEyebrows(reverse: reverse, waitBeforeDelay: waitBeforeDelay) {
            spriteActions.append(angryEyebrows)
        }
        
        return spriteActions
    }
    
    func createIndividualLegMovement(legSprite: SKSpriteNode, rotateAngle: CGFloat, rotateSpeed: CGFloat, delayBefore: Double, reversed: Bool = true) -> SpriteAction {
        let rotateDuration = abs(rotateAngle) / rotateSpeed
        let rotateAction = SKAction.rotate(byAngle: rotateAngle, duration: rotateDuration)
        rotateAction.timingMode = .easeInEaseOut
        let reverse = rotateAction.reversed()
        reverse.timingMode = .easeInEaseOut
        let randomWaitAction = SKAction.wait(forDuration: delayBefore)
        
        let action: SKAction
        if reversed {
            action = SKAction.sequence([randomWaitAction, rotateAction, reverse])
        } else {
            action = SKAction.sequence([randomWaitAction, rotateAction])
        }
        var spriteAction = SpriteAction.init(legSprite, action)
        spriteAction.duration = (rotateDuration * 2) + delayBefore
        return spriteAction
    }
    
    func createLegMovement(delayBefore: Double, forceEachLeg: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let rotateSpeed: CGFloat = .pi/2
        let minAngle: CGFloat = CGFloat.pi/32
        let maxAngle: CGFloat = 3*CGFloat.pi/32
        let waitActionDuration = Double.random(in: 0.0...0.5)
        func randomRange() -> CGFloat { return CGFloat.random(in: minAngle...maxAngle) }
        let evenLegs = Bool.random()
        // left leg steps
        for (idx, legSprite) in bossSprite.leftLegs.enumerated() {
            if forceEachLeg || (evenLegs && idx.isMultiple(of: 2)) || (!evenLegs && !idx.isMultiple(of: 2)) {
                let rotateAngle: CGFloat = -1 * randomRange()
                let legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: rotateSpeed, delayBefore: waitActionDuration)
                spriteActions.append(legAction.waitBefore(delay: delayBefore))
                
            }
        }
        
        // right leg steps
        for (idx, legSprite) in bossSprite.rightLegs.enumerated() {
            // boolean test reversed on the right side
            if forceEachLeg || (!evenLegs && idx.isMultiple(of: 2)) || (evenLegs && !idx.isMultiple(of: 2)) {
                let rotateAngle: CGFloat = randomRange()
                let legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: rotateSpeed, delayBefore: waitActionDuration)
                spriteActions.append(legAction.waitBefore(delay: delayBefore))
            }
        }
        
        return spriteActions
    }
    
    func createBodyShifts(numberOfShifts: Int, delayBefore: Double) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        var bodyWaitBefore = delayBefore
        for  _ in 0..<numberOfShifts {
            
            // move the body up and down
            var bodyMoveXDistance: CGFloat = CGFloat.random(in: 0.0...0.0)
            var bodyMoveYDistance: CGFloat = CGFloat.random(in: 4.0...8.0)
            let up = Bool.random()
            bodyMoveYDistance *= (up ? 1 : -1)
            bodyMoveXDistance *= (up ? 1 : -1)
            let headMoveXDistance: CGFloat = bodyMoveXDistance * 1.75
            let headMoveYDistance: CGFloat = bodyMoveYDistance * 1.75
            
            let bodyMoveDuration: TimeInterval = 0.10
            let headMoveDuration: TimeInterval = 0.10
            
            let waitBeforeBodyDown: TimeInterval = bodyMoveDuration + 0.2
            
            let bodyMoveUpAction = SKAction.moveBy(x: bodyMoveXDistance, y: bodyMoveYDistance, duration: bodyMoveDuration)
            let headMoveAction = SKAction.moveBy(x: headMoveXDistance, y: headMoveYDistance, duration: headMoveDuration)
            let bodyMoveUpReverse = bodyMoveUpAction.reversed().waitBefore(delay: waitBeforeBodyDown)
            let headMoveActionReverse = headMoveAction.reversed().waitBefore(delay: waitBeforeBodyDown)
            
            let bodyMoveUp: SpriteAction = .init(bossSprite.spiderBody, bodyMoveUpAction.waitBefore(delay: bodyWaitBefore))
            let headMoveUp: SpriteAction = .init(bossSprite.spiderHead, headMoveAction.waitBefore(delay: bodyWaitBefore))
            let bodyMoveDown: SpriteAction = .init(bossSprite.spiderBody, bodyMoveUpReverse.waitBefore(delay: bodyWaitBefore))
            let headMoveDown: SpriteAction = .init(bossSprite.spiderHead, headMoveActionReverse.waitBefore(delay: bodyWaitBefore))
            
            spriteActions.append(bodyMoveUp)
            spriteActions.append(headMoveUp)
            spriteActions.append(bodyMoveDown)
            spriteActions.append(headMoveDown)
            
            // wait for the next set
            bodyWaitBefore += bodyMoveDuration + waitBeforeBodyDown + 0.2
            
        }
        
        return spriteActions
    }
    
    
    // MARK: Functions that actually animate
    
    func animateAngryFace(completion: @escaping () -> Void) {
        let animationDelay: TimeInterval = 2.0
        if let eyeLidStartAnimation = createAngryEyelidAnimation(reverse: false, waitBeforeDelay: 0.0),
           let eyeLidEndAnimation = createAngryEyelidAnimation(reverse: true, waitBeforeDelay: animationDelay),
           let eyeBrowStartAnimation = createAngryEyebrows(reverse: false, waitBeforeDelay: 0.0),
           let eyeBrowEndAnimation = createAngryEyebrows(reverse: true, waitBeforeDelay: animationDelay)
        {
            animate([eyeLidStartAnimation, eyeLidEndAnimation, eyeBrowStartAnimation, eyeBrowEndAnimation], completion: completion)
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
            if let toothAnimation = createToothSmallChompAnimation(delayBefore: waitForPairA) {
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
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothChompAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        animate(spriteActions, completion: {
            completion()
        })
        
        
    }
    
    func animateToothSmallChomp(completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothSmallChompAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        animate(spriteActions, completion: {
            completion()
        })
        
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
    
    // After we animate the boss eating rocks we want to show the animations of the boss getting ready to attack
    func animateBossGettingReadyToAttack(delayBefore: TimeInterval, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        var extraWait: TimeInterval = 0.0
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: delayBefore)
        extraWait += undoAngryFace.maxDuration()
        spriteActions.append(contentsOf: undoAngryFace)
        
        if let bigChomp = createToothChompFirstHalfAnimation(delayBefore: delayBefore)?.reversed {
            spriteActions.append(bigChomp)
        }

        
        let blink = createFullBlinkAnimation(delayBefore: delayBefore)
        extraWait += blink.maxDuration()
        spriteActions.append(contentsOf: blink)
        
        if let eyesTurnsRed = createEyesTurnsRed(reverse: false, delayBefore: extraWait + delayBefore) {
            spriteActions.append(eyesTurnsRed)
        }
        
        animate(spriteActions, completion: completion)
    }
    
    func animateIdlePhase1(timerBeforeDelay: TimeInterval, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let blinkDown = createBlinkAnimation(reverse: false, delayBefore: timerBeforeDelay),
           let blinkUp = createBlinkAnimation(reverse: true, delayBefore: blinkDown.duration) {
            spriteActions.append(contentsOf: [blinkDown, blinkUp])
        }
        
        if let legMoves = createLegMovement(delayBefore: timerBeforeDelay, forceEachLeg: false) {
            if let legMoves2 = createLegMovement(delayBefore: timerBeforeDelay + legMoves.maxDuration(), forceEachLeg: false) {
                if let legMoves3 = createLegMovement(delayBefore: timerBeforeDelay + legMoves.maxDuration() + legMoves2.maxDuration(), forceEachLeg: false) {
                    spriteActions.append(contentsOf: legMoves)
                    spriteActions.append(contentsOf: legMoves2)
                    spriteActions.append(contentsOf: legMoves3)
                }
            }
        }
        
        if let bodyShifts = createBodyShifts(numberOfShifts: 2, delayBefore: timerBeforeDelay) {
            spriteActions.append(contentsOf: bodyShifts)
        }
        
        if let sparkle = createSparkleAnimation(delayBefore: timerBeforeDelay) {
            spriteActions.append(sparkle)
            spriteActions.append(sparkle.waitBefore(delay: sparkle.duration + 0.25))
        }
        
        animate(spriteActions, completion: completion)
    }
    
    
    func animateWaitingToEat(delayBefore: Double, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let smallChomp = createToothSmallChompAnimation(delayBefore: delayBefore) {
            var wait = delayBefore + smallChomp.duration + 0.05
            if let secondSmallChomp = createToothSmallChompAnimation(delayBefore: wait) {
                wait += secondSmallChomp.duration + 0.05
                if let bigChomp = createToothChompFirstHalfAnimation(delayBefore: wait) {
                    spriteActions.append(smallChomp)
                    spriteActions.append(secondSmallChomp)
                    spriteActions.append(bigChomp)
                }
            }
        }
        
        let angryFace = createAngryFace(reverse: false, waitBeforeDelay: delayBefore)
        
        spriteActions.append(contentsOf: angryFace)
        
        animate(spriteActions, completion: {
            completion()
        })

    }
    
    
    func createTrainAnimation(delayBefore: TimeInterval, reversed: Bool) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let trainSprite = bossSprite.spiderDynamiteTrain
//        let initialPosition = CGPoint.alignVertically(trainSprite.frame, relativeTo: bossSprite.frame, horizontalAnchor: .left, verticalAlign: .bottom, verticalPadding: -25.0, horizontalPadding: -50.0, translatedToBounds: true)
//        trainSprite.position = initialPosition
        
        let trainTargetPosition: CGPoint

        if reversed {
            trainTargetPosition = bossSprite.originalSpiderTrainPosition
        } else {
            trainTargetPosition = CGPoint.alignVertically(trainSprite.frame, relativeTo: bossSprite.spiderHead.frame, horizontalAnchor: .center, verticalAlign: .bottom, verticalPadding: -25.0, translatedToBounds: true)
        }
        
        let frames = SpriteSheet(texture: SKTexture(imageNamed: "animate-dynamite-coming-in-animation-6"), rows: 1, columns: 6).animationFrames()
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
        let loopedAnimation = SKAction.repeat(animation, count: 4)
        let trainMoveDuration: TimeInterval = timePerFrame() * 6 * 4
        let moveIn = SKAction.move(to: trainTargetPosition, duration: trainMoveDuration)
        moveIn.timingMode = .easeInEaseOut

        return .init(trainSprite, SKAction.group(loopedAnimation, moveIn).waitBefore(delay: delayBefore))
    }
    
    func createLegRotateAndMove(delayBefore: TimeInterval, reversed: Bool,  frontRotateSpeed: CGFloat, frontRotateAngle: CGFloat, backRotateSpeed: CGFloat, backRotateAngle: CGFloat, frontMoveX: CGFloat, frontMoveY: CGFloat, backMoveX: CGFloat, backMoveY: CGFloat, moveDuration: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let waitActionDuration = 0.0 // no need to wait because we arent reversing the action
        // left leg steps
        let legMoveAction = SKAction.moveBy(x: frontMoveX, y: frontMoveY, duration: moveDuration)
        for (idx, legSprite) in bossSprite.leftLegs.enumerated() {
            if idx < 2 {
                let rotateAngle: CGFloat = -1 * frontRotateAngle
                var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: frontRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                legAction.duration = abs(rotateAngle / frontRotateSpeed)
                spriteActions.append(.init(legSprite, legMoveAction))
                spriteActions.append(legAction)
                
            } else {
                let rotateAngle: CGFloat = -1 * backRotateAngle
                var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: backRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                legAction.duration = abs(rotateAngle / backRotateSpeed)
                spriteActions.append(legAction)
            }
        }
        
        for (idx, legSprite) in bossSprite.rightLegs.enumerated() {
            if idx < 2 {
                let rotateAngle: CGFloat = 1 * frontRotateAngle
                var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: frontRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                legAction.duration = abs(rotateAngle / frontRotateSpeed)
                spriteActions.append(.init(legSprite, legMoveAction))
                spriteActions.append(legAction)
            } else {
                let rotateAngle: CGFloat = 1 * backRotateAngle
                var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: backRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                legAction.duration = abs(rotateAngle / backRotateSpeed)
                spriteActions.append(legAction)
            }
        }
        
        return reverseAndDelayActions(actions: spriteActions, reversed: reversed, delay: delayBefore)
    }
    
    func createBossRecoilFromPoison(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        
        /// BODY MOVEMENT
        // body and head move down quickly.
        let moveDuration: TimeInterval = 0.1
        let bodyMoveDistance: CGFloat = -5.0
        let headMoveDistance: CGFloat = -10.0
        let bodyMoveDown = SKAction.moveBy(x: 0.0 ,y: bodyMoveDistance, duration: moveDuration)
        let headMoveDown = SKAction.moveBy(x: 0.0, y: headMoveDistance, duration: moveDuration)
        spriteActions.append(.init(bossSprite.spiderBody, bodyMoveDown).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        spriteActions.append(.init(bossSprite.spiderHead, headMoveDown).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
    
        
        // legs rotate away from the body and move down with body/head
        // animate the squatting quickly because of poison beam recoil
        let rotateSpeed: CGFloat = .pi
        let frontLegAngles: CGFloat = .pi / 16
        let backLegAngles: CGFloat = .pi / 16
        let legMoveDistance: CGFloat = headMoveDistance / 2
        
        if let legsActions = createLegRotateAndMove(delayBefore: delayBefore, reversed: reversed, frontRotateSpeed: rotateSpeed, frontRotateAngle: frontLegAngles, backRotateSpeed: rotateSpeed, backRotateAngle: backLegAngles, frontMoveX: 0.0, frontMoveY: legMoveDistance, backMoveX: 0.0, backMoveY: 0.0, moveDuration: moveDuration)
        {
            spriteActions.append(contentsOf: legsActions)
        }
        
        return spriteActions
        
    }
    
    ///
    /// Doees not reverse itself.
    /// We end up in a pose where we are ready to ground pound.
    /// Call this with reversed = true to retrun to our normal pose
    func animateBossRearingUp(delayBefore: TimeInterval, reversed: Bool, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else {
            completion();
            return
        }
        
        var spriteActions: [SpriteAction] = []
        
        /// BODY MOVEMENT
        // move the boss's head and body up
        let moveDuration: TimeInterval = 0.33
        let bodyMoveDistance: CGFloat = -50.0
        let headMoveUpDistance: CGFloat = 100.0
        let bodyMoveDown = SKAction.moveBy(x: 0.0 ,y: bodyMoveDistance, duration: moveDuration)
        let headMoveUp = SKAction.moveBy(x: 0.0, y: headMoveUpDistance, duration: moveDuration)
        
        spriteActions.append(.init(bossSprite.spiderHead, headMoveUp).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        spriteActions.append(.init(bossSprite.spiderBody, bodyMoveDown).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        
        
        /// FACE EMOTION
        let angry = createAngryFace(reverse: reversed, waitBeforeDelay: delayBefore)
        spriteActions.append(contentsOf: angry)
        
        /// LEG ANIMATION
        // animate the boss preparing to stamp it's feet
        let rotateSpeed: CGFloat = .pi/2
        let frontLegAngles: CGFloat = CGFloat.pi/3
        let backLegAngles: CGFloat = -.pi / 8
        
        if let legsActions = createLegRotateAndMove(delayBefore: delayBefore, reversed: reversed, frontRotateSpeed: rotateSpeed, frontRotateAngle: frontLegAngles, backRotateSpeed: rotateSpeed, backRotateAngle: backLegAngles, frontMoveX: 0.0, frontMoveY: headMoveUpDistance, backMoveX: 0.0, backMoveY: 0.0, moveDuration: moveDuration) {
            spriteActions.append(contentsOf: legsActions)
        }
        
        /// TRAIN ENTRANCE ANIMATION
        if let trainEntrance = createTrainAnimation(delayBefore: delayBefore, reversed: reversed) {
            spriteActions.append(trainEntrance)
        }
        
        
        animate(spriteActions, completion: completion)
    }
    
    
    func createGroundPound(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        /// HEAD ANIMATION
        // move the boss's head down fast!
        let moveDuration: TimeInterval = 0.1
        let headMoveUpDistance: CGFloat = -100.0
        let headMoveDown = SKAction.moveBy(x: 0.0, y: headMoveUpDistance, duration: moveDuration)
        let headMoveReverse = headMoveDown.reversed().waitBefore(delay: delayBefore + moveDuration)
        let headSeq = SKAction.sequence(headMoveDown, headMoveReverse, curve: .easeInEaseOut)
        spriteActions.append(.init(bossSprite.spiderHead, headSeq))
        
        /// LEG ANIMATION
        // animate the boss stomping its feet
        let rotateSpeed: CGFloat = 2 * .pi
        let frontLegAngles: CGFloat = -.pi / 2
        let backLegAngles: CGFloat = .pi / 3
        
        if let legsActions = createLegRotateAndMove(delayBefore: delayBefore, reversed: false, frontRotateSpeed: rotateSpeed, frontRotateAngle: frontLegAngles, backRotateSpeed: rotateSpeed, backRotateAngle: backLegAngles, frontMoveX: 0.0, frontMoveY: headMoveUpDistance, backMoveX: 0.0, backMoveY: 0.0, moveDuration: moveDuration) {
            spriteActions.append(contentsOf: legsActions)
            
            // bring them down and back quickly
            let reversedLegActions = legsActions.map { $0.reversed.waitBefore(delay: delayBefore +  moveDuration) }
            
            spriteActions.append(contentsOf: reversedLegActions)
        }

        if let shake = shakeScreen(duration: 0.1, amp: 50, delayBefore: delayBefore + moveDuration) {
            spriteActions.append(shake)
        }
        
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: false, delay: delayBefore)
        
        return spriteActions
    }
    
    
    /// Reverses itself.
    /// Meant to be called AFTER rear up has been called
    func animateGroundPound(delayBefore: TimeInterval,  completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let groundPound = createGroundPound(delayBefore: delayBefore) {
            spriteActions.append(contentsOf: groundPound)
        }
        
        animate(spriteActions, completion: completion)
    }
    
    func animateDynamiteFlyingIn(delayBefore: TimeInterval, targetPositions: [CGPoint], targetSprites: [DFTileSpriteNode], tileTypes: [TileType], spriteForeground: SKNode, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else {
            completion()
            return
        }
        var spriteActions: [SpriteAction] = []
        
        // animate 1 dynamite
        var staggerDyanmite: TimeInterval = 0.1
        for idx in 0..<targetSprites.count {
            let emptySprite = SKSpriteNode(color: .clear, size: .fifty)
            let startPosition1: CGPoint = CGPoint.position(emptySprite.frame, inside: bossSprite.frame, verticalAnchor: .center, horizontalAnchor: .center, yOffset: -50.0, xOffset: 0.0, translatedToBounds: true)
            let targetPosition = targetPositions[idx]
            let targetSprite = targetSprites[idx]
            let tileType = tileTypes[idx]
            if let dynamiteThrow = createDynamiteFlyingIn(delayBefore: delayBefore + staggerDyanmite, startingPosition: startPosition1, targetPosition: targetPosition, targetSprite: targetSprite, tileType: tileType, spriteForeground: spriteForeground) {
                spriteActions.append(contentsOf: dynamiteThrow)
            }
            
            // animate 1 ground pound
            if let groundPound = createGroundPound(delayBefore: delayBefore + staggerDyanmite) {
                spriteActions.append(contentsOf: groundPound)
            }
            
            staggerDyanmite += 0.3
        }
        
        
        /// TRAIN
        /// animate the train bouncing around in palce
        let frames = SpriteSheet(texture: SKTexture(imageNamed: "animate-dynamite-coming-in-animation-6"), rows: 1, columns: 6).animationFrames()
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
        let loopedAnimation = SKAction.repeat(animation, count: targetSprites.count)
        spriteActions.append(.init(sprite: bossSprite.spiderDynamiteTrain, action: loopedAnimation))
        
        
        animate(spriteActions, completion: completion)
        
        
    }
    
    func reverseAndDelayActions(actions: [SpriteAction], reversed: Bool, delay delayBefore: TimeInterval) -> [SpriteAction] {
        
        var spriteActions = actions
        
        if reversed {
            spriteActions = spriteActions.map { $0.reversed }
        }
        
        if delayBefore > 0.0 {
            spriteActions = spriteActions.map { $0.waitBefore(delay: delayBefore)}
        }
        
        return spriteActions
    }
    
    func animateGettingReadyToPoisonAttack(delayBefore: TimeInterval, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        var waitBefore: TimeInterval = delayBefore
        
        /// FACE
        // make angry face
        let angryFace = createAngryFace(reverse: false, waitBeforeDelay: waitBefore)
        spriteActions.append(contentsOf: angryFace)
        
        /// HEAD TILT
        // tilt the head 180 degress
        if let tiltHead = createTiltingHead(delayBefore: waitBefore, reversed: false) {
            spriteActions.append(contentsOf: tiltHead)
            waitBefore += tiltHead.maxDuration()
        }
        
        if let openMouth = createToothChompFirstHalfAnimation(delayBefore: waitBefore) {
            spriteActions.append(openMouth)
            waitBefore += openMouth.duration
        }
        
        animate(spriteActions, completion: completion)
    }
    
    func animateResetToOriginalPositions(delayBefore: TimeInterval, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite else {
            completion()
            return
        }
        
        var spriteActions = bossSprite.originalPositions.map { pair -> SpriteAction in
            let moveAction = SKAction.move(to: pair.1.position, duration: 0.0)
            let rotateAction = SKAction.rotate(toAngle: pair.1.rotation, duration: 0.0)
            
            return SpriteAction.init(sprite: pair.0, action: SKAction.group(moveAction, rotateAction))
        }
        
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: 0.0)
        
        spriteActions.append(contentsOf: undoAngryFace)
        
        animate(spriteActions, completion: completion)
    }
    
}

