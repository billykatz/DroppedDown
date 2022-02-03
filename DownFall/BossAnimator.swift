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


fileprivate let eye7Frames = SpriteSheet(textureName: "boss-spider-animation-worried-eye-7-6frames", columns: 6).animationFrames()
fileprivate let eye8Frames = SpriteSheet(textureName: "boss-spider-animation-worried-eye-8-6frames", columns: 6).animationFrames()
fileprivate let eyelidFrames = SpriteSheet(textureName: "boss-spider-animation-worried-eyelids-6", columns: 6).animationFrames()
fileprivate let eyebrowFrames = SpriteSheet(textureName: "boss-spider-animation-worried-eyebrows-6", columns: 6).animationFrames()
fileprivate let headFrames = SpriteSheet(textureName: "boss-spider-animation-worried-head-6", columns: 6).animationFrames()

/// Small and Medium Rock debris
fileprivate let smallRockDebrisAnimationNames: [String] = ["blue-rock-falling-animation-14", "purple-rock-falling-animation-14", "red-rock-falling-animation-14"]
fileprivate let mediumRockDebrisAnimationNames: [String] = ["rock-debris-medium-blue-16", "rock-debris-medium-purple-16", "rock-debris-medium-red-16"]

/// Boss Animations
extension Animator {
    
    // MARK: - Functions to create SpirteActions
    func createBossWorriedAnimation(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let animateTimePerFrame = timePerFrame()
        
        // create eye-7 animation
        let eye7Animation = SKAction.animate(with: eye7Frames, timePerFrame: animateTimePerFrame)
        // eye 7 is 6 in the 0 index array
        let eye7SpriteAction = SpriteAction.init(bossSprite.spiderIndividualEyes[6], eye7Animation)
        spriteActions.append(eye7SpriteAction)
        
        // create eye-8 animation
        let eye8Animation = SKAction.animate(with: eye8Frames, timePerFrame: animateTimePerFrame)
        // eye 8 is 7 in the 0 index array
        let eye8SpriteAction = SpriteAction.init(bossSprite.spiderIndividualEyes[7], eye8Animation)
        spriteActions.append(eye8SpriteAction)
        
        
        // create the eyelid animation
        let eyelidAnimation = SKAction.animate(with: eyelidFrames, timePerFrame: animateTimePerFrame)
        let eyelidSpriteAction = SpriteAction.init(bossSprite.spiderEyelids, eyelidAnimation)
        spriteActions.append(eyelidSpriteAction)
        
        // create the eyebrow animation
        let eyebrowAnimation = SKAction.animate(with: eyebrowFrames, timePerFrame: animateTimePerFrame)
        let eyebrowSpriteAction = SpriteAction.init(bossSprite.spiderEyebrowCrystals, eyebrowAnimation)
        spriteActions.append(eyebrowSpriteAction)
        
        
        // create the head animation
        let headAnimation = SKAction.animate(with: headFrames, timePerFrame: animateTimePerFrame)
        let headSpriteAction = SpriteAction.init(bossSprite.spiderHead, headAnimation)
        spriteActions.append(headSpriteAction)
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: reversed, delay: delayBefore)
        
        return spriteActions
    }
    
    func createWebShootingAniamtion(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        func toggleWebAttack(delayBeforeTime: TimeInterval, sprite: SKSpriteNode, onOff: Bool, onAlpha: CGFloat) -> SKAction {
            let toggleWebAttack = SKAction.run {
                sprite.alpha = onOff ? onAlpha : 0.0
                sprite.xScale = 1
            }
            return toggleWebAttack.waitBefore(delay: delayBeforeTime)
        }
        
        let delayBetween = 0.02
        var slightDelay = delayBefore
        let yScale: CGFloat = 1.0
        var horizontalFlip: CGFloat = 1
        var alpha: CGFloat = 1.0
        let timePerFrame: TimeInterval = timePerFrame() / 2 / 2
        for webAttack in bossSprite.spiderWebAttacks {
            
            let frames = SpriteSheet(texture: SKTexture(imageNamed: "boss-web-attack-animation-23"), rows: 1, columns: 23).animationFrames()
            let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame).waitBefore(delay: slightDelay)
            let scale = SKAction.scaleX(by: horizontalFlip, y: yScale, duration: 0.0)
            let animationDuration = Double(frames.count) * timePerFrame
            let showWeb = toggleWebAttack(delayBeforeTime: slightDelay, sprite: webAttack, onOff: true, onAlpha: alpha)
            let hideWeb = toggleWebAttack(delayBeforeTime: slightDelay + animationDuration, sprite: webAttack, onOff: false, onAlpha: alpha)
            
            let seq = SKAction.sequence(showWeb, scale, animation, hideWeb)
            
            spriteActions.append(.init(webAttack, seq))
            
            horizontalFlip = horizontalFlip * -1
            alpha -= 0.33
            slightDelay += delayBetween
        }
        
        return spriteActions
    }
    
    func createEyeAnimation(eyeNumber: Int, delayBefore: TimeInterval, reversed: Bool, animationSpeed: Double) -> SpriteAction? {
        guard let bossSprite = bossSprite,
              eyeNumber >= 1,
              eyeNumber <= 8
        else { return nil }
        
        let animationName = "boss-glowing-red-eye-\(eyeNumber)"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 8)
        let animation = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: animationSpeed)
        
        var spriteAction: SpriteAction = .init(bossSprite.spiderIndividualEyes[eyeNumber-1], animation)
        
        spriteAction.duration = Double(spriteSheet.animationFrames().count) * animationSpeed
        
        spriteAction = spriteAction.reverseAnimation(reverse: reversed)
        spriteAction = spriteAction.waitBefore(delay: delayBefore)
        
        return spriteAction
        
    }
    
    func createAllEyesRed(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        for idx in 1...8 {
            if let eyeAnimation = createEyeAnimation(eyeNumber: idx, delayBefore: delayBefore, reversed: reversed, animationSpeed: timePerFrame()) {
                spriteActions.append(eyeAnimation)
            }
        }
        
        return spriteActions
    }
    
    // Meant to instantly turn an eye from yellow to red
    func createSingleEyeRed(delayBefore: TimeInterval, reversed: Bool, animationSpeed: Double, eyeIndex: Int) -> [SpriteAction] {
        var spriteActions: [SpriteAction] = []
        if let eyeAnimation = createEyeAnimation(eyeNumber: eyeIndex, delayBefore: delayBefore, reversed: reversed, animationSpeed: animationSpeed) {
            spriteActions.append(eyeAnimation)
        }
        return spriteActions
    }
    func createTiltingHead(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let rotateAngle: CGFloat = .pi
        let rotateSpeed: CGFloat = .pi * 4
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
    
    func createToothChompFirstHalfAnimation(delayBefore: TimeInterval, animationSpeed: Double? = nil ) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        
        let animationSpeed = animationSpeed ?? timePerFrame()
        let animationName = "boss-spider-tooth-chomp-first-half-9"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 9)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: animationSpeed)
        
        let action = SKAction.sequence(animate)
        
        var toothAnimation: SpriteAction = .init(bossSprite.spiderTooth, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * animationSpeed
        
        return toothAnimation
    }
    
    func createToothChompSecondHalfAnimation(delayBefore: TimeInterval, animationSpeed: Double) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-tooth-chomp-second-half-10"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 10)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: animationSpeed)
        
        let action = SKAction.sequence(animate)
        
        var toothAnimation: SpriteAction = .init(bossSprite.spiderTooth, action.waitBefore(delay: delayBefore))
        toothAnimation.duration = Double(spriteSheet.animationFrames().count) * animationSpeed
        
        return toothAnimation
    }
    
    func createAngryEyelidAnimation(reverse: Bool, waitBeforeDelay: TimeInterval, animationSpeed: Double) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-angry-eyelids"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 7)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: animationSpeed)
        
        var action = reverse ? SKAction.sequence(animate).reversed() : SKAction.sequence(animate)
        action = action.waitBefore(delay: waitBeforeDelay)
        var eyelidAnimation: SpriteAction = .init(bossSprite.spiderEyelids, action)
        eyelidAnimation.duration = Double(spriteSheet.animationFrames().count) * animationSpeed
        
        return eyelidAnimation
    }
    
    func createAngryEyebrows(reverse: Bool, waitBeforeDelay: TimeInterval, animationSpeed: Double) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let animationName = "boss-spider-angry-crystal-eyebrows"
        let spriteSheet = SpriteSheet(textureName: animationName, columns: 7)
        let animate = SKAction.animate(with: spriteSheet.animationFrames(), timePerFrame: animationSpeed)
        
        var action = reverse ? SKAction.sequence(animate).reversed() : SKAction.sequence(animate)
        action = action.waitBefore(delay: waitBeforeDelay)
        var eyebrowAnimation: SpriteAction = .init(bossSprite.spiderEyebrowCrystals, action)
        eyebrowAnimation.duration = Double(spriteSheet.animationFrames().count) * animationSpeed
        
        return eyebrowAnimation
    }
    
    func createAngryFace(reverse: Bool, waitBeforeDelay: TimeInterval, animationSpeed: Double? = nil
    ) -> [SpriteAction] {
        let newAnimationSpeed: Double = animationSpeed ?? timePerFrame()
        var spriteActions: [SpriteAction] = []
        
        if let angryEyes = createAngryEyelidAnimation(reverse: reverse, waitBeforeDelay: waitBeforeDelay, animationSpeed: newAnimationSpeed) {
            spriteActions.append(angryEyes)
        }
        
        if let angryEyebrows = createAngryEyebrows(reverse: reverse, waitBeforeDelay: waitBeforeDelay, animationSpeed: newAnimationSpeed) {
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
    
    func createAnimationRopesPullingAway(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else {
            return nil
        }
        let compositeSprites = bossSprite.monstersInWebs
        var spriteActions: [SpriteAction] = []
        
        for compositeSprite in compositeSprites {
            
            /// play animation
            let frames = SpriteSheet(texture: SKTexture(imageNamed: "boss-web-destroyed-animation-10"), rows: 1, columns: 10).animationFrames()
            let webDestroyAnimation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
            var animationAction = SpriteAction.init(compositeSprite.1.webSprite, webDestroyAnimation)
            animationAction.duration = Double(frames.count) * timePerFrame()
            spriteActions.append(animationAction)
            
            let hideMonsterSprite = SKAction.fadeOut(withDuration: 0.0)
            spriteActions.append(.init(compositeSprite.1.monsterSprite, hideMonsterSprite))
            
            let ropePullUp = SKAction.move(by: CGVector(dx: 0.0, dy: 500), duration: 1.0)
            spriteActions.append(.init(compositeSprite.1.ropeSprite, ropePullUp.waitBefore(delay: 0.7)))
            
            
        }
        
        let cleanUpAction = SKAction.run {
            bossSprite.monstersInWebs = []
        }
        
        spriteActions.append(.init(bossSprite, cleanUpAction.waitBefore(delay: 1.0)))
        
        return spriteActions
        
    }
    
    func createShakingRocks(delayBefore: TimeInterval, shakeDuration: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        for rockSprite in bossSprite.rockSprites {
            let shakeNode0 = shakeNode(node: rockSprite, duration: shakeDuration, amp: 50, delayBefore: delayBefore)
            let shakeNode1 = shakeNode(node: rockSprite, duration: shakeDuration, amp: 50, delayBefore: delayBefore + 1.0)
            let shakeNode2 = shakeNode(node: rockSprite, duration: shakeDuration, amp: 50, delayBefore: delayBefore + 2.0)
            spriteActions.append(shakeNode0)
            spriteActions.append(shakeNode1)
            spriteActions.append(shakeNode2)
        }
        
        return spriteActions
    }
    
    
    func createLargeRockFallingAnimation(delayBefore: TimeInterval) -> SpriteAction? {
        guard let bossSprite = bossSprite else { return nil }
        
        let sprite = bossSprite.createLargeRockAnimation()
        let frames = SpriteSheet(textureName: "large-rock-debris-13", columns: 13).animationFrames()
        
        let wait = SKAction.wait(forDuration: delayBefore)
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
        let seq = SKAction.sequence(wait, animation)
        
        return .init(sprite, seq)
        
    }
    
    func createAllRocksCleared(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        if let rockCleared = createLargeRockCleared(delayBefore: delayBefore) {
            let clearLargeRocks = SKAction.run { [bossSprite] in
                bossSprite.hideLargeRock()
            }
            let waitBeforeClearing = SKAction.wait(forDuration: delayBefore + (12.0 * timePerFrame()))
            let waitThenRemove = SKAction.sequence(waitBeforeClearing, clearLargeRocks)
            
            spriteActions.append(rockCleared)
            spriteActions.append(.init(rockCleared.sprite, waitThenRemove))
        }
        
        let clearSmallAndMediumRocks = SKAction.run { [bossSprite] in
            bossSprite.hideSmallMediumRocks()
        }
        let waitBeforeClearing = SKAction.wait(forDuration: delayBefore + 0.35)
        let seq = SKAction.sequence(waitBeforeClearing, clearSmallAndMediumRocks)
        let spriteAction = SpriteAction(bossSprite, seq)
        
        spriteActions.append(spriteAction)
        
        
        return spriteActions
    }
    
    func createLargeRockCleared(delayBefore: TimeInterval) -> SpriteAction? {
        guard let largeRockSprite = bossSprite?.largeRockAnimationSprite else { return nil }
        
        let frames = SpriteSheet(textureName: "large-rock-debris-cleared-12", columns: 12).animationFrames()
        
        let wait = SKAction.wait(forDuration: delayBefore)
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
        let seq = SKAction.sequence(wait, animation)
        
        
        var spriteAction: SpriteAction = .init(largeRockSprite, seq)
        spriteAction.duration = 12 * timePerFrame()
        return spriteAction
    }
    
    func createBossBendsUnderPressure(delayBefore: TimeInterval, reversed: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite  else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        /// BODY MOVEMENT
        // move the boss's head and body up
        let moveDuration: TimeInterval = 0.15
        let bodyMoveDistance: CGFloat = -140.0
        let headMoveUpDistance: CGFloat = -70.0
        let bodyMoveDown = SKAction.moveBy(x: 0.0 ,y: bodyMoveDistance, duration: moveDuration)
        let headMoveUp = SKAction.moveBy(x: 0.0, y: headMoveUpDistance, duration: moveDuration)
        
        spriteActions.append(.init(bossSprite.spiderHead, headMoveUp).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        spriteActions.append(.init(bossSprite.spiderBody, bodyMoveDown).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        
        /// LEG ANIMATION
        // animate the boss preparing to stamp it's feet
        let rotateSpeed: CGFloat = .pi / 2 * 2
        let frontLegAngles: CGFloat = .pi / 8
        let backLegAngles: CGFloat = -.pi / 8
        let backMoveY: CGFloat = -125
        let frontMoveY: CGFloat = -125
        
        if let legsActions = createLegRotateAndMove(delayBefore: delayBefore, reversed: reversed, frontRotateSpeed: rotateSpeed, frontRotateAngle: frontLegAngles, backRotateSpeed: rotateSpeed, backRotateAngle: backLegAngles, frontMoveX: 0.0, frontMoveY: frontMoveY, backMoveX: 0.0, backMoveY: backMoveY, moveDuration: moveDuration, moveBackLegs: true) {
            spriteActions.append(contentsOf: legsActions)
        }
        
        
        return spriteActions
    }
    
    func createRockFallingAnimation(delayBefore: TimeInterval, numberOfRocks: Int, rockSize: BossSprite.RockSize? = nil) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        for index in 0..<numberOfRocks {
            let stagger: TimeInterval = Double.random(in: 0...0.0)
            let newRockSize: BossSprite.RockSize = rockSize ?? (index.isEven ? .medium : .small)
            let rockSprite = bossSprite.createRockAnimationContainer(rockSize: newRockSize)
            
            let rockAnimationName: String
            let frameNumber: Int
            switch newRockSize {
            case .small:
                rockAnimationName = smallRockDebrisAnimationNames.randomElement()!
                frameNumber = 14
            case .medium:
                rockAnimationName = mediumRockDebrisAnimationNames.randomElement()!
                frameNumber = 16
            }
            
            let frames = SpriteSheet(textureName: rockAnimationName, columns: frameNumber).animationFrames()
            let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame())
            let waitAction = SKAction.wait(forDuration: delayBefore + stagger)
            let seq = SKAction.sequence(waitAction, animation)
            let spriteAction = SpriteAction(rockSprite, seq)
            
            spriteActions.append(spriteAction)
            
        }
        
        return spriteActions
        
    }
    
    func createShakingBuildUp(duration: TimeInterval, targetAmplitiude: Int, delayBefore: TimeInterval) -> [SpriteAction]? {
        var spriteActions: [SpriteAction] = []
        
        let steps: Int = 10
        let durationSteps = duration / Double(steps)
        let amplitudeSteps = Double(targetAmplitiude) / Double(steps)
        
        for stepIndex in 0..<steps {
            let duration = durationSteps
            let amplitudeSteps = amplitudeSteps + (amplitudeSteps * Double(stepIndex))
            let delayBefore = Double(stepIndex) * durationSteps
            if let shakeScreen = shakeScreen(duration: duration, amp: Int(amplitudeSteps), delayBefore: delayBefore) {
                spriteActions.append(shakeScreen)
            }
        }
        
        return spriteActions
    }
    
    func createMonstersHangingFromCeiling(delayBefore: TimeInterval, monsterTypes: [EntityModel.EntityType]) -> [SpriteAction]? {
        guard let bossSprite = bossSprite,
              let playableRect = playableRect,
              let tileSize = tileSize else { return nil }
        var spriteActions: [SpriteAction] = []
        
        // choose a random X along the screen to show the monster
        var xSlots: [CGFloat] = []
        let monsterTypeCount = monsterTypes.count
        let zoneSpacing = playableRect.width / CGFloat(monsterTypeCount)
        for zoneIdx in 0..<monsterTypeCount {
            let xPosition = playableRect.minX + (CGFloat(zoneIdx) * zoneSpacing) + zoneSpacing/2
            xSlots.append(xPosition)
        }
        
        // choose a random Y on the screen to show the monster
        let randomYSlots: [CGFloat] = [5, 10, 16, 8]
        
        let staggerBetween: TimeInterval = 0.075
        var waitBefore = 0.0
        
        for (monsterIndex, monsterType) in monsterTypes.enumerated() {
            let monsterSprite = SKSpriteNode(texture: SKTexture(imageNamed: monsterType.textureString), size: CGSize(widthHeight: tileSize*1.25))
            let startingYPosition = CGPoint.alignHorizontally(monsterSprite.frame, relativeTo: bossSprite.spiderHead.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: 400, translatedToBounds: true)
            let startingXPosition = xSlots[monsterIndex]
            let startPosition = CGPoint(x: startingXPosition, y: startingYPosition.y)
            
            let randomPositionY = randomYSlots.randomElement()
            let endPositionY = CGPoint.alignHorizontally(monsterSprite.frame, relativeTo: bossSprite.spiderHead.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: randomPositionY!, translatedToBounds: true)
            let endPosition = CGPoint(x: startingXPosition, y: endPositionY.y)
            
            // attach the long rope to the back of the monster
            let ropeSize = CGSize(width: tileSize, height: 400 / (32/tileSize))
            let ropeSprite = SKSpriteNode(texture: SKTexture(imageNamed: "boss-full-web-strand"), size: ropeSize)
            let webSize = CGSize(widthHeight: tileSize)
            let webSprite = SKSpriteNode(texture: SKTexture(imageNamed: "boss-web-spawn-monsters"), size: webSize)
            
            ropeSprite.position = startPosition
            monsterSprite.position = startPosition
            webSprite.position = startPosition
            
            ropeSprite.zPosition = 2_980_000
            ropeSprite.anchorPoint = CGPoint(x: 0.5, y: 0.05)
            monsterSprite.zPosition = 3_000_000
            webSprite.zPosition = 3_020_000
            webSprite.yScale = 0.8
            webSprite.xScale = 1.2
            
            bossSprite.addChild(ropeSprite)
            bossSprite.addChild(monsterSprite)
            bossSprite.addChild(webSprite)
            
            bossSprite.monstersInWebs.append((monsterType, CompositeWebSprite(ropeSprite: ropeSprite, webSprite: webSprite, monsterSprite: monsterSprite)))
            
            // bounce the monster into position
            let rateUp: Double = 0.25 / 3 / 70
            let rateDown: Double = 1.0 / 3  / 100
            let moveAction = SKAction.moveTo(y: endPosition.y - 50, duration: 1.0 / 3)
            moveAction.timingMode = .easeInEaseOut
            let move2Action = SKAction.moveTo(y: endPosition.y + 20, duration: rateUp * 70)
            move2Action.timingMode = .easeOut
            let move3Action = SKAction.moveTo(y: endPosition.y - 20, duration: rateDown * 40 * 1.1)
            move3Action.timingMode = .easeOut
            let move4Action = SKAction.moveTo(y: endPosition.y + 5, duration: rateUp * 25 * 2)
            move4Action.timingMode = .easeOut
            let move5Action = SKAction.moveTo(y: endPosition.y - 10, duration: rateDown * 15 * 1.4)
            move5Action.timingMode = .easeOut
            
            let seq = SKAction.sequence([moveAction, move2Action, move3Action, move4Action, move5Action])
            
            spriteActions.append(.init(monsterSprite, seq.waitBefore(delay: waitBefore)))
            spriteActions.append(.init(ropeSprite, seq.waitBefore(delay: waitBefore)))
            spriteActions.append(.init(webSprite, seq.waitBefore(delay: waitBefore)))
            waitBefore += staggerBetween
        }
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: false, delay: delayBefore)
        
        return spriteActions
    }
    
    func createResetToOriginalPositionsAnimations(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else {
            return nil
        }
        
        var spriteActions: [SpriteAction] = bossSprite.originalPositions.map { pair -> SpriteAction in
            let moveAction = SKAction.move(to: pair.1.position, duration: 0.0)
            let rotateAction = SKAction.rotate(toAngle: pair.1.rotation, duration: 0.0)
            
            return SpriteAction.init(sprite: pair.0, action: SKAction.group(moveAction, rotateAction))
        }
        
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: 0.0, animationSpeed: 0.0)
        spriteActions.append(contentsOf: undoAngryFace)
        
        if let undoChomp = createToothChompSecondHalfAnimation(delayBefore: 0.0, animationSpeed: 0.0)
        {
            spriteActions.append(undoChomp)
        }
        
        bossSprite.activeSpriteActions.forEach {
            $0.stop()
        }
        
        let returnToPosition = CGPoint.position(bossSprite.frame, inside: playableRect, verticalAlign: .top, horizontalAnchor: .center, yOffset: 240)
        let returnBossSpriteToOriginalPosition = SKAction.move(to: returnToPosition, duration: 0.0)
        spriteActions.append(.init(bossSprite, returnBossSpriteToOriginalPosition))
        
        if let turnEyesCorrectColor = turnEyeCorrectColor(delayBefore: 0.0) {
            spriteActions.append(contentsOf: turnEyesCorrectColor)
        }
        
        return spriteActions
    }
    
    func createEchoEffect(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        // add them to the boss sprite
        let startingAlpha = 0.65
        // create 3x copies of the boss sprite
        var bossSpriteCopies: [SKSpriteNode] = Array(repeating: bossSprite, count: 3)
        for (idx, sprite) in bossSpriteCopies.enumerated() {
            let newSprite = sprite.copy() as! BossSprite
            newSprite.clearRocks()
            newSprite.removeFromParent()
            newSprite.position = .zero
            newSprite.alpha = startingAlpha
            bossSpriteCopies[idx] = newSprite
        }
        
        let addCopiesAction = SKAction.run { [bossSpriteCopies, bossSprite] in
            for (idx, sprite) in bossSpriteCopies.enumerated() {
                bossSprite.addChild(sprite)
            }
        }
        let waitBeforeAdd = SKAction.wait(forDuration: delayBefore)
        let seq = SKAction.sequence(waitBeforeAdd, addCopiesAction)
        spriteActions.append(.init(bossSprite, seq))
        
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
        
        //        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: false, delay: delayBefore)
        
        return spriteActions
    }
    
    func createPhaseChangeAttackAnimations(delayBefore: TimeInterval, tileAttacks: [BossTileAttack], spriteForeground: SKNode, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint) -> [SpriteAction]? {
        guard let bossSprite = bossSprite,
              let tileSize = tileSize
        else { return nil }
        var spriteActions: [SpriteAction] = []
        
        for bossTileAttack in tileAttacks {
            
            let targetCoord = bossTileAttack.tileCoord
            let targetPositionInForeground = positionInForeground(targetCoord)
            
            // create the sprite
            let sprite = DFTileSpriteNode(type: bossTileAttack.tileType, height: tileSize*2, width: tileSize*2)
            sprite.zPosition = 3_000_000
            
            // align the Y
            sprite.position = CGPoint.alignHorizontally(sprite.frame, relativeTo: bossSprite.frame, horizontalAnchor: .center, verticalAlign: .top, verticalPadding: 250.0, horizontalPadding: 0.0, translatedToBounds: true)
            
            // align the X
            sprite.position.x = targetPositionInForeground.x
            
            // add it to the foreground
            spriteForeground.addChild(sprite)
            
            // move it to the target position
            let moveSpeed: CGFloat = 1200
            let moveDistance = (sprite.position - targetPositionInForeground).length
            let moveDuration = moveDistance / moveSpeed
            let moveAction = SKAction.move(to: targetPositionInForeground, duration: moveDuration)
            moveAction.timingMode = .easeIn
            let scaleAction = SKAction.scale(to: CGSize(widthHeight: tileSize), duration: moveDuration)
            scaleAction.timingMode = .easeIn
            let group = SKAction.group(moveAction, scaleAction)
            let moveSpriteAction: SpriteAction = .init(sprite, group)
            spriteActions.append(moveSpriteAction)
            
            // destroy the targeted tile if we can (can't if targeted an empty tile
            let spriteToDestroy = sprites[targetCoord]
            if let crumble = spriteToDestroy.crumble(true, delayBefore: moveDuration - 0.1) {
                spriteActions.append(crumble)
            }
        }
        
        spriteActions = reverseAndDelayActions(actions: spriteActions, reversed: false, delay: delayBefore)
        
        return spriteActions
    }
    
    func createBossStomp(delayBefore: TimeInterval, reversed: Bool, myLeftSide: Bool) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        var spriteActions: [SpriteAction] = []
        
        /// BODY MOVEMENT
        // move the boss's head and body up
        let moveDuration: TimeInterval = 0.15
        let bodyMoveDistance: CGFloat = -50.0
        let headMoveUpDistance: CGFloat = 100.0
        let bodyMoveDown = SKAction.moveBy(x: 0.0 ,y: bodyMoveDistance, duration: moveDuration)
        let headMoveUp = SKAction.moveBy(x: 0.0, y: headMoveUpDistance, duration: moveDuration)
        headMoveUp.timingMode = .easeInEaseOut
        bodyMoveDown.timingMode = .easeInEaseOut
        
        spriteActions.append(.init(bossSprite.spiderHead, headMoveUp).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        spriteActions.append(.init(bossSprite.spiderBody, bodyMoveDown).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore))
        
        /// BODY HEAD TILTING
        // tilt the head and body based on the leftside vs righ side
        var headBodyRotateAngle: CGFloat = .pi/8
        headBodyRotateAngle *= myLeftSide ? -1 : 1
        var headBodyRotateSpeed: CGFloat = .pi
        headBodyRotateSpeed *= myLeftSide ? -1 : 1
        let headBodyRotateDuration = headBodyRotateAngle/headBodyRotateSpeed
        
        let headRotateAction = SKAction.rotate(byAngle: headBodyRotateAngle, duration: headBodyRotateDuration)
        headRotateAction.timingMode = .easeInEaseOut
        let bodyRotateAction = SKAction.rotate(byAngle: headBodyRotateAngle/2, duration: headBodyRotateDuration/4)
        bodyRotateAction.timingMode = .easeInEaseOut
        
        let seq = SKAction.sequence(headRotateAction)
        let headRotateSpriteAction = SpriteAction(bossSprite.spiderHead, seq).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore)
        let bodyRotateSpriteAction = SpriteAction(bossSprite.spiderBody, bodyRotateAction).reverseAnimation(reverse: reversed).waitBefore(delay: delayBefore)
        spriteActions.append(headRotateSpriteAction)
        spriteActions.append(bodyRotateSpriteAction)
        
        
        /// LEG ANIMATION
        ///
        /// POSTIVE MOVEMENT
        // animate the boss preparing to stamp it's feet
        let rotateSpeed: CGFloat = .pi / 2 * 2
        let frontLegAngles: CGFloat = .pi / 2
        // back legs rotate away from front legs a little
        let backLegAngles: CGFloat = -.pi / 8
        let backMoveY: CGFloat = 25
        let frontMoveY: CGFloat = 120
        let frontMoveX: CGFloat = myLeftSide ? 20 : -20
        
        if let legsActions = createOneSideLegRotateAndMove(delayBefore: delayBefore, reversed: reversed, frontRotateSpeed: rotateSpeed, frontRotateAngle: frontLegAngles, backRotateSpeed: rotateSpeed, backRotateAngle: backLegAngles, frontMoveX: frontMoveX, frontMoveY: frontMoveY, backMoveX: 0.0, backMoveY: backMoveY, moveDuration: moveDuration, leftSide: myLeftSide, animationSpeedCoefficient: reversed ? 4.0 : 1.0, moveBackLegs: true) {
            spriteActions.append(contentsOf: legsActions)
        }
        
        /// NEGATIVE MOVEMENT
        let otherSideRotateSpeed: CGFloat = .pi / 2 * 2
        let otherSideFrontLegAngles: CGFloat = -.pi / 16
        let otherSideBackLegAngles: CGFloat = -.pi / 8
        let otherSideBackMoveY: CGFloat = 15
        let otherSideFrontMoveY: CGFloat = 20
        let otherSideFrontMoveX: CGFloat = myLeftSide ? -20 : 20
        
        if let negativeLegsActions = createOneSideLegRotateAndMove(delayBefore: delayBefore, reversed: reversed, frontRotateSpeed: otherSideRotateSpeed, frontRotateAngle: otherSideFrontLegAngles, backRotateSpeed: otherSideRotateSpeed, backRotateAngle: otherSideBackLegAngles, frontMoveX: otherSideFrontMoveX, frontMoveY: otherSideFrontMoveY, backMoveX: 0.0, backMoveY: otherSideBackMoveY, moveDuration: moveDuration, leftSide: !myLeftSide, animationSpeedCoefficient: reversed ? 4.0 : 1.0, moveBackLegs: true) {
            spriteActions.append(contentsOf: negativeLegsActions)
        }
        
        return spriteActions
    }
    
    
    func createOneSideLegRotateAndMove(delayBefore: TimeInterval, reversed: Bool,  frontRotateSpeed: CGFloat, frontRotateAngle: CGFloat, backRotateSpeed: CGFloat, backRotateAngle: CGFloat, frontMoveX: CGFloat, frontMoveY: CGFloat, backMoveX: CGFloat, backMoveY: CGFloat, moveDuration: TimeInterval, leftSide: Bool, animationSpeedCoefficient: Double, moveBackLegs: Bool = false) -> [SpriteAction]? {
        guard let bossSprite = bossSprite else { return nil }
        
        var spriteActions: [SpriteAction] = []
        
        let moveDuration = moveDuration / animationSpeedCoefficient
        let frontRotateSpeed = frontRotateSpeed * animationSpeedCoefficient
        let backRotateSpeed = backRotateSpeed * animationSpeedCoefficient
        let waitActionDuration = 0.0 // no need to wait because we arent reversing the action
        // left leg steps
        let legMoveAction = SKAction.moveBy(x: frontMoveX, y: frontMoveY, duration: moveDuration)
        if leftSide {
            for (idx, legSprite) in bossSprite.leftLegs.enumerated() {
                // FRONT
                if idx < 2 {
                    let rotateAngle: CGFloat = -1 * frontRotateAngle
                    var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: frontRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                    legAction.duration = abs(rotateAngle / frontRotateSpeed)
                    spriteActions.append(.init(legSprite, legMoveAction))
                    spriteActions.append(legAction)
                    
                }
                // BACK
                else {
                    let rotateAngle: CGFloat = -1 * backRotateAngle
                    var legAction = createIndividualLegMovement(legSprite: legSprite, rotateAngle: rotateAngle, rotateSpeed: backRotateSpeed, delayBefore: waitActionDuration, reversed: false)
                    legAction.duration = abs(rotateAngle / backRotateSpeed)
                    spriteActions.append(legAction)
                    if moveBackLegs {
                        spriteActions.append(.init(legSprite, legMoveAction))
                    }
                }
            }
        }
        else {
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
                    if moveBackLegs {
                        spriteActions.append(.init(legSprite, legMoveAction))
                    }
                }
            }
        }
        
        return reverseAndDelayActions(actions: spriteActions, reversed: reversed, delay: delayBefore)
    }
    
    
    
    
    // MARK: Functions that actually animate
    
    func animateAngryFace(completion: @escaping () -> Void) {
        let animationDelay: TimeInterval = 2.0
        let animationSpeed = timePerFrame()
        if let eyeLidStartAnimation = createAngryEyelidAnimation(reverse: false, waitBeforeDelay: 0.0, animationSpeed: animationSpeed),
           let eyeLidEndAnimation = createAngryEyelidAnimation(reverse: true, waitBeforeDelay: animationDelay, animationSpeed: animationSpeed),
           let eyeBrowStartAnimation = createAngryEyebrows(reverse: false, waitBeforeDelay: 0.0, animationSpeed: animationSpeed),
           let eyeBrowEndAnimation = createAngryEyebrows(reverse: true, waitBeforeDelay: animationDelay, animationSpeed: animationSpeed)
        {
            resetBossThenAnimate([eyeLidStartAnimation, eyeLidEndAnimation, eyeBrowStartAnimation, eyeBrowEndAnimation], completion: completion)
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
        
        
        
        resetBossThenAnimate(spriteActions, completion: completion)
    }
    
    
    func animateEchoEffect(completion: @escaping () -> Void) {
        guard let spriteActions = createEchoEffect(delayBefore: 0.0) else { return }
        
        resetBossThenAnimate(spriteActions, completion: completion)
        
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
        let moveAmount = 150
        let moveLeft = animateWalkingAnimation(moveVector: CGVector(dx: -moveAmount, dy: 0))
        resetBossThenAnimate(moveLeft) {
            completion()
            //            let up = animateWalkingAnimation(moveVector: CGVector(dx: 0, dy: moveAmount))
            //            animate(up) {
            //                let right = animateWalkingAnimation(moveVector: CGVector(dx: moveAmount, dy: 0))
            //                animate(right) {
            //                    let down = animateWalkingAnimation(moveVector: CGVector(dx: 0, dy: -moveAmount))
            //                    animate(down, completion: completion)
            //                }
            //            }
        }
    }
    
    func animateToothChomp(completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothChompAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        resetBossThenAnimate(spriteActions, completion: {
            completion()
        })
        
        
    }
    
    func animateToothSmallChomp(completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        if let chomp = createToothSmallChompAnimation(delayBefore: 0.0) {
            spriteActions.append(chomp)
        }
        
        resetBossThenAnimate(spriteActions, completion: {
            completion()
        })
        
    }
    
    func animateBossEatingRocks(sprites: [[DFTileSpriteNode]], foreground: SKNode, transformation: Transformation, completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite,
              let firstHalfteethChomp = createToothChompFirstHalfAnimation(delayBefore: 0.0),
              let secondHalfTeethChomp = createToothChompSecondHalfAnimation(delayBefore: 0.0, animationSpeed: timePerFrame()) else {
                  completion()
                  return
              }
        
        var spriteActions: [SpriteAction] = []
        
        /// get the rock sprites
        /// animate then to move to the spiders mouth
        /// animate them to explode
        let moveSpeed: CGFloat = 1200.0
        var currentStagger: TimeInterval = 0.0
        let stagger: TimeInterval = Double.random(in: 0...0.15)
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
                newSprite.zPosition = 1_000_000
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
        
        let eyesTurnsRed = createAllEyesRed(delayBefore: 0.1, reversed: false)
        spriteActions.append(contentsOf: eyesTurnsRed)
        
        
        /// call the completion
        resetBossThenAnimate(spriteActions, completion: completion)
    }
    
    // After we animate the boss eating rocks we want to show the animations of the boss getting ready to attack
    func animateBossGettingReadyToAttack(delayBefore: TimeInterval, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        resetBossThenAnimate(spriteActions, completion: completion)
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
        
        resetBossThenAnimate(spriteActions, completion: completion)
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
        
        resetBossThenAnimate(spriteActions, completion: {
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
        let loopedAnimation = SKAction.repeat(animation, count: 4 / 2)
        let trainMoveDuration: TimeInterval = timePerFrame() * 6 * 4 / 2
        let moveIn = SKAction.move(to: trainTargetPosition, duration: trainMoveDuration)
        moveIn.timingMode = .easeInEaseOut
        
        return .init(trainSprite, SKAction.group(loopedAnimation, moveIn).waitBefore(delay: delayBefore))
    }
    
    func createLegRotateAndMove(delayBefore: TimeInterval, reversed: Bool,  frontRotateSpeed: CGFloat, frontRotateAngle: CGFloat, backRotateSpeed: CGFloat, backRotateAngle: CGFloat, frontMoveX: CGFloat, frontMoveY: CGFloat, backMoveX: CGFloat, backMoveY: CGFloat, moveDuration: TimeInterval, moveBackLegs: Bool = false) -> [SpriteAction]? {
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
                if moveBackLegs {
                    spriteActions.append(.init(legSprite, legMoveAction))
                }
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
                if moveBackLegs {
                    spriteActions.append(.init(legSprite, legMoveAction))
                }
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
        let moveDuration: TimeInterval = 0.15
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
        let rotateSpeed: CGFloat = .pi/2 * 2
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
        
        resetBossThenAnimate(spriteActions, completion: completion)
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
            spriteActions = spriteActions.map { $0.waitBefore(delay: delayBefore) }
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
    
    
    func animateGettingReadyToSpawnMonsters(delayBefore: TimeInterval, monsterTypes: [EntityModel.EntityType], completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        var waitBefore: TimeInterval = delayBefore
        
        /// FACE
        // make angry face
        let angryFace = createAngryFace(reverse: false, waitBeforeDelay: waitBefore)
        spriteActions.append(contentsOf: angryFace)
        
        /// MOVE Body
        /// slight recoil to force of web
        if let moveBody = createBossRecoilFromPoison(delayBefore: waitBefore, reversed: false) {
            spriteActions.append(contentsOf: moveBody)
        }
        
        /// WEB
        /// show web coming out of the butt, hehe
        if let webShoot = createWebShootingAniamtion(delayBefore: waitBefore) {
            spriteActions.append(contentsOf: webShoot)
        }
        
        waitBefore += 0.1
        
        // show the monsters coming down from the ceiling.
        /// SHOW MONSTERS
        if let monstersAppear = createMonstersHangingFromCeiling(delayBefore: waitBefore, monsterTypes: monsterTypes) {
            spriteActions.append(contentsOf: monstersAppear)
        }
        
        waitBefore += 0.1
        
        /// UNDO Body
        if let undoMoveBody = createBossRecoilFromPoison(delayBefore: waitBefore, reversed: true) {
            spriteActions.append(contentsOf: undoMoveBody)
        }
        
        /// UNDO face
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: waitBefore)
        spriteActions.append(contentsOf: undoAngryFace)
        
        
        resetBossThenAnimate(spriteActions, completion: completion)
    }
    
    func animateResetToOriginalPositions(delayBefore: TimeInterval, completion: @escaping () -> Void) {
        guard let spriteActions = createResetToOriginalPositionsAnimations(delayBefore: delayBefore) else {
            completion()
            return
        }
        
        resetBossThenAnimate(spriteActions, completion: completion)
    }
    
    
    
    func animateSingleEyeBecomingYellow(delayBefore: TimeInterval, eyeNumber: Int, completion: @escaping () -> Void){
        if let eyeTurnYellow = createEyeAnimation(eyeNumber: eyeNumber, delayBefore: delayBefore, reversed: true, animationSpeed: timePerFrame()) {
            resetBossThenAnimate([eyeTurnYellow], completion: completion)
        } else {
            completion()
        }
    }
    
    func turnEyeCorrectColor(delayBefore: TimeInterval) -> [SpriteAction]? {
        guard let bossSprite = bossSprite,
              bossSprite.numberOfRedEyes > -1 else {
                  return nil
              }
        
        let numberOfRedEyes = bossSprite.numberOfRedEyes
        
        var spriteActions: [SpriteAction] = []
        
        for eyeIndex in 1..<9 {
            // reversed = false makes it red
            // reversed = true makes it yellow
            var reversed = ((8-numberOfRedEyes+1)..<9).contains(eyeIndex) ? false : true
            let turnEyeColor = createSingleEyeRed(delayBefore: delayBefore, reversed: reversed, animationSpeed: 0.0, eyeIndex: eyeIndex)
            spriteActions.append(contentsOf: turnEyeColor)
        }
        
        return spriteActions
    }
    
    func testAnimateShootingWebs(completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        /// FACE
        // make angry face
        let angryFace = createAngryFace(reverse: false, waitBeforeDelay: 0.0)
        spriteActions.append(contentsOf: angryFace)
        
        /// MOVE Body
        if let moveBody = createBossRecoilFromPoison(delayBefore: 0.0, reversed: false) {
            spriteActions.append(contentsOf: moveBody)
        }
        
        /// WEB
        if let webShoot = createWebShootingAniamtion(delayBefore: 0.0) {
            spriteActions.append(contentsOf: webShoot)
        }
        
        /// SHOW MONSTERS
        if let monstersAppear = createMonstersHangingFromCeiling(delayBefore: 0.75, monsterTypes: [.sally, .alamo, .rat, .dragon, .alamo]) {
            spriteActions.append(contentsOf: monstersAppear)
        }
        
        /// UNDO Body
        if let undoMoveBody = createBossRecoilFromPoison(delayBefore: 1.0, reversed: true) {
            spriteActions.append(contentsOf: undoMoveBody)
        }
        
        /// UNDO face
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: 1.0)
        spriteActions.append(contentsOf: undoAngryFace)
        
        resetBossThenAnimate(spriteActions, completion: completion)
    }
    
    func resetBossThenAnimate(_ spriteActions: [SpriteAction], completion: @escaping () -> Void) {
        guard let bossSprite = bossSprite,
              let resetAnimation = createResetToOriginalPositionsAnimations(delayBefore: 0.0) else {
                  completion()
                  return
              }
        
        var newSpriteActions = spriteActions
        newSpriteActions.insert(contentsOf: resetAnimation, at: 0)
        
        bossSprite.activeSpriteActions = spriteActions
        
        animate(newSpriteActions) {
            bossSprite.activeSpriteActions = []
            completion()
        }
    }
    
    func animateBossWorried(delayBefore: TimeInterval, reversed: Bool, completion: @escaping () -> Void) {
        if let worriedAnimation = createBossWorriedAnimation(delayBefore: delayBefore, reversed: reversed),
           let rocksFalling = createRockFallingAnimation(delayBefore: 2.0, numberOfRocks: 10)
        {
            var spriteActions = worriedAnimation
            spriteActions.append(contentsOf: rocksFalling)
            animate(spriteActions, completion: completion)
        } else {
            completion()
        }
    }
    
    // After we complete this function we will call another function to finish the boss phase change animation
    func animateBossPhaseChange(completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        /// CLEAN UP BEFORE DOING ANYHTING
        // remove any webs and monsters if application
        for sprite in bossSprite?.monstersInWebs ?? [] {
            sprite.1.monsterSprite.removeFromParent()
            sprite.1.ropeSprite.removeFromParent()
            sprite.1.webSprite.removeFromParent()
        }
        bossSprite?.monstersInWebs = []
        
        // keep track of waiting
        var waitBefore: TimeInterval = 0.0
        
        // show boss worried
        if let bossWorried = createBossWorriedAnimation(delayBefore: 0.0, reversed: false) {
            spriteActions.append(contentsOf: bossWorried)
        }
        
        // start with a show scree shake
        if let screenShake = createShakingBuildUp(duration: 4.0, targetAmplitiude: 50, delayBefore: 0.0) {
            spriteActions.append(contentsOf: screenShake)
        }
        
        waitBefore += 1.5
        
        // show small rocks falling
        
        if let smallRocks = createRockFallingAnimation(delayBefore: waitBefore, numberOfRocks: 10, rockSize: .small) {
            spriteActions.append(contentsOf: smallRocks)
        }
        
        waitBefore += 1.5
        
        if let mediumRocks = createRockFallingAnimation(delayBefore: waitBefore, numberOfRocks: 10, rockSize: .medium) {
            spriteActions.append(contentsOf: mediumRocks)
        }
        
        waitBefore += 1.0
        
        if let largeRocks = createLargeRockFallingAnimation(delayBefore: waitBefore) {
            spriteActions.append(largeRocks)
        }
        
        waitBefore += 0.2
        
        if let bodyCrumbleUnderPressure = createBossBendsUnderPressure(delayBefore: waitBefore, reversed: false) {
            spriteActions.append(contentsOf: bodyCrumbleUnderPressure)
        }
        
        
        waitBefore += 1.5
        
        // undo worried face
        if let bossWorried = createBossWorriedAnimation(delayBefore: waitBefore, reversed: true) {
            spriteActions.append(contentsOf: bossWorried)
        }
        
        
        waitBefore += 0.5
        
        // angry face
        let angryFace = createAngryFace(reverse: false, waitBeforeDelay: waitBefore, animationSpeed: 0.0)
        spriteActions.append(contentsOf: angryFace)
        
        
        // shake the pile of rocks
        if let shakeRocks = createShakingRocks(delayBefore: waitBefore, shakeDuration: 0.5) {
            spriteActions.append(contentsOf: shakeRocks)
        }
        
        waitBefore += 1.5
        
        // blow away the rocks!
        if let blowAwayRocks = createAllRocksCleared(delayBefore: waitBefore) {
            spriteActions.append(contentsOf: blowAwayRocks)
        }
        
        waitBefore += 0.5
        
        if let undoBodyCrumbleUnderPressure = createBossBendsUnderPressure(delayBefore: waitBefore, reversed: true) {
            spriteActions.append(contentsOf: undoBodyCrumbleUnderPressure)
        }
        
        waitBefore += 0.5
        
        // echo
        if let echo = createEchoEffect(delayBefore: waitBefore) {
            spriteActions.append(contentsOf: echo)
        }
        
        resetBossThenAnimate(spriteActions) { [bossSprite] in
            bossSprite?.clearRocks()
            bossSprite?.clearLargeRocks()
            completion()
        }
        
    }
    
    func animateBossPhaseChangeAnimation(spriteForground: SKNode, sprites: [[DFTileSpriteNode]], bossPhaseChangeTargets: BossPhaseTargets, delayBefore: TimeInterval, positionInForeground: (TileCoord) -> CGPoint, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        
        var waitBefore = delayBefore
        let anticipation: TimeInterval = 1.1
        
        /// BOSS STOMPS LEFT
        if let bossStompsLeft = createBossStomp(delayBefore: waitBefore, reversed: false, myLeftSide: true) {
            spriteActions.append(contentsOf: bossStompsLeft)
        }
        
        waitBefore += anticipation
        
        if let reverseBossStompsLeft = createBossStomp(delayBefore: waitBefore, reversed: true, myLeftSide: true) {
            spriteActions.append(contentsOf: reverseBossStompsLeft)
        }
        
        waitBefore += 0.075
        
        /// SCREEN SHAKE
        if let shakeScreen = shakeScreen(duration: 0.15, amp: 35, delayBefore: waitBefore) {
            spriteActions.append(shakeScreen)
        }
        
        /// ANIMATE "THROWN" ROCKS
        /// We will just have some brown rocks fall in from the ceiling
        if let rocksThrown = bossPhaseChangeTargets.throwRocks,
           let rockAnimation = createPhaseChangeAttackAnimations(delayBefore: waitBefore, tileAttacks: rocksThrown, spriteForeground: spriteForground, sprites: sprites, positionInForeground: positionInForeground) {
            spriteActions.append(contentsOf: rockAnimation)
        }
        
        
        waitBefore += 1.5
        
        /// BOSS STOMPS RIGHT
        if let bossStompsRight = createBossStomp(delayBefore: waitBefore, reversed: false, myLeftSide: false) {
            spriteActions.append(contentsOf: bossStompsRight)
            
        }
        
        waitBefore += anticipation
        
        if let reverseBossStompsRight = createBossStomp(delayBefore: waitBefore, reversed: true, myLeftSide: false) {
            spriteActions.append(contentsOf: reverseBossStompsRight)
        }
        
        /// SCREEN SHAKE
        waitBefore += 0.075
        
        if let shakeScreen = shakeScreen(duration: 0.15, amp: 35, delayBefore: waitBefore) {
            spriteActions.append(shakeScreen)
        }
        
        /// ANIMATE "SPAWNED" MONSTERS
        /// We will just have some brown rocks fall in from the ceiling
        if let spawnedMonsters = bossPhaseChangeTargets.spawnMonsters,
           let rockAnimation = createPhaseChangeAttackAnimations(delayBefore: waitBefore, tileAttacks: spawnedMonsters, spriteForeground: spriteForground, sprites: sprites, positionInForeground: positionInForeground) {
            spriteActions.append(contentsOf: rockAnimation)
        }
        
        waitBefore += 0.25
        
        let undoAngryFace = createAngryFace(reverse: true, waitBeforeDelay: waitBefore, animationSpeed: timePerFrame())
        spriteActions.append(contentsOf: undoAngryFace)
        
        
        animate(spriteActions, completion: completion)
    }
    
    
}


