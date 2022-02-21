//
//  OfferAnimator.swift
//  DownFall
//
//  Created by Billy on 2/19/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMedia

typealias PositionGiver = (TileCoord) -> CGPoint

struct TargetTileType {
    let target: TileCoord
    let type: TileType
}

extension Animator {
    
    func animateCollectingOffer(_ offer: StoreOffer, playerPosition: TileCoord, targetTileTypes: [TargetTileType], delayBefore: TimeInterval, hud: HUD, sprites: [[DFTileSpriteNode]], positionInForeground: PositionGiver, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        switch offer.type {
        case .transmogrifyPotion, .killMonsterPotion:
            if let spriteAction = createSingleTargetOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileCoord: targetTileTypes.first!.target, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: spriteAction)
            }
            
        case .gemMagnet:
            if let gemAction = createGemMagnetOfferAnimation(delayBefore: delayBefore, offer: offer, playerTileCoord: playerPosition, targetTileTypes: targetTileTypes, hud: hud, sprites: sprites, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: gemAction)
            }
                
              
        case .infusion:
            if let infusion = createInfusionOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileType: targetTileTypes.first!, sprites: sprites, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: infusion)
            }
            
        default:
            break
            
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func createInfusionOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, startTileCoord: TileCoord, targetTileType: TargetTileType, sprites: [[DFTileSpriteNode]], positionInForeground: PositionGiver) -> [SpriteAction]? {
        guard let foreground = foreground, let tileSize = tileSize, let playableRect = playableRect else { return nil }
        var spriteActions: [SpriteAction] = []
        let cgTileSize = CGSize(widthHeight: tileSize)
        var waitBefore = delayBefore
        
        /// save this for later
        let originalRockPosition = sprites[targetTileType.target].position
        
        /// INITIAL ROCK MOVEMENT
        // expand the rock and move it to the right half of the center third
        var rockSprite = sprites[targetTileType.target]
        rockSprite.zPosition = 30_000_000
        let newRockSpritePosition = CGPoint.position(CGRect(origin: .zero, size: cgTileSize), inside: playableRect, verticalAnchor: .center, horizontalAnchor: .center, yOffset: 0.0, xOffset: playableRect.width/3, translatedToBounds: true)
        
        let initialRockScale = cgTileSize.scale(by: 4)
        let initialRockSpeed: CGFloat = 1000
        let initialRockDistance = (newRockSpritePosition - rockSprite.position).length
        let initialRockDuration = initialRockDistance / initialRockSpeed
        let initialMoveRockSpriteAction = SKAction.move(to: newRockSpritePosition, duration: initialRockDuration)
        let initialRockScaleAction = SKAction.scale(to: initialRockScale, duration: initialRockDuration)
        
        let initialRockSeq = SKAction.group(initialRockScaleAction, initialMoveRockSpriteAction, curve: .easeInEaseOut).waitBefore(delay: waitBefore)
        spriteActions.append(.init(rockSprite, initialRockSeq))
        
        /// INITIAL GEM CREATION AND MOVEMENT
        // create and expand the gem and move it to the left half of the center third
        let color: ShiftShaft_Color
        if case TileType.rock(color: let rockColor, _, _) = targetTileType.type {
            color = rockColor
        } else {
            color = .blue
        }
        let gemSpriteName = Item(type: .gem, amount: 0, color: color)
        let gemSprite = SKSpriteNode(texture: SKTexture(imageNamed: gemSpriteName.textureName), size: cgTileSize)
        let initalGemPosition = positionInForeground(startTileCoord)
        gemSprite.zPosition = 1_000_000
        gemSprite.position = initalGemPosition
        foreground.addChild(gemSprite)
        
        let newGemSpritePosition = CGPoint.position(CGRect(origin: .zero, size: cgTileSize), inside: playableRect, verticalAnchor: .center, horizontalAnchor: .center, yOffset: 0.0, xOffset: -playableRect.width/3, translatedToBounds: true)
        let initialMoveGemAction = SKAction.move(to: newGemSpritePosition, duration: initialRockDuration)
        let initialGemScaleAction = SKAction.scale(to: initialRockScale, duration: initialRockDuration)
        let initialGemSeq = SKAction.group(initialGemScaleAction, initialMoveGemAction, curve: .easeInEaseOut).waitBefore(delay: waitBefore)
        spriteActions.append(.init(gemSprite, initialGemSeq))
        
        // keep track of wait before for sequencing purposes
        waitBefore += initialRockDuration
        
        /// SECONDARY MOVEMENT PRIOR TO INFUSION
        // move them away from one another slowly
        let rockMoveVector = CGVector(dx: 100, dy: 0.0)
        let gemMoveVector = CGVector(dx: -100, dy: 0.0)
        let secondaryMoveDuration = 0.3
        
        let secondaryRockMoveAway = SKAction.move(by: rockMoveVector, duration: secondaryMoveDuration).waitBefore(delay: waitBefore)
        secondaryRockMoveAway.timingMode = .easeIn
        let secondaryGemMoveAway = SKAction.move(by: gemMoveVector, duration: secondaryMoveDuration).waitBefore(delay: waitBefore)
        secondaryGemMoveAway.timingMode = .easeIn
        spriteActions.append(.init(rockSprite, secondaryRockMoveAway))
        spriteActions.append(.init(gemSprite, secondaryGemMoveAway))
        
        // keep track of wait before for sequencing purposes
        waitBefore += secondaryMoveDuration
        
        /// TERTIARY MOVEMENT - BIG BANG
        // crash them into one another
        let finalMeetingPoint = CGPoint.position(CGRect(origin: .zero, size: cgTileSize), inside: playableRect, verticalAnchor: .center, horizontalAnchor: .center)
        
        let finalMoveDuration: TimeInterval = 0.1
        let moveTowardsMeetingPoint = SKAction.move(to: finalMeetingPoint, duration: 0.1).waitBefore(delay: waitBefore)
        let squash = SKAction.scaleX(by: 0.25, y: 1.0, duration: 0.05).waitBefore(delay: finalMoveDuration/4*3)
        let moveThenSquash = SKAction.sequence(moveTowardsMeetingPoint, squash, curve: .easeIn)
        let gemMoveThenSquash = SKAction.sequence(moveTowardsMeetingPoint, squash, .removeFromParent(), curve: .easeIn)

        
        spriteActions.append(.init(rockSprite, moveThenSquash))
        spriteActions.append(.init(gemSprite, gemMoveThenSquash))
        
        // keep track of wait before for sequencing purposes
        waitBefore += finalMoveDuration
        
        // flash the screen white
        let whiteSprite = SKSpriteNode(texture: SKTexture(imageNamed: "white-sprite"), size: cgTileSize)
        whiteSprite.zPosition = 300_000_000
        whiteSprite.position = .zero
        
        let whiteSpriteDuration: TimeInterval = 0.2
        let waitToAddWhiteSprite = SKAction.run { [foreground] in
            foreground.addChild(whiteSprite)
        }.waitBefore(delay: waitBefore)
        let whiteSpriteScale = SKAction.scale(to: cgTileSize.scale(by: 100), duration: whiteSpriteDuration)
        let whiteSpriteSeq = SKAction.sequence(whiteSpriteScale, .removeFromParent())
        spriteActions.append(.init(foreground, waitToAddWhiteSprite))
        spriteActions.append(.init(whiteSprite, whiteSpriteSeq))
        
        waitBefore += whiteSpriteDuration
        
        // show a the new rock with 10 alternating/spinning glow sprites behind it of different sizes and alphas (smaller and closer are brighter)
        var glowEffectZPosition: CGFloat = 1_000_000
        var glowAlpha = 1.0
        for idx in 1..<11 {
            let glow = SKSpriteNode(texture: SKTexture(imageNamed: "crystalGlow"), size: tileCGSize.scale(by: CGFloat(idx)))
            glow.alpha = glowAlpha
            glow.zPosition = glowEffectZPosition
            
            let waitToAddGlowSprite = SKAction.run { [foreground] in
                foreground.addChild(glow)
            }.waitBefore(delay: waitBefore)
            spriteActions.append(.init(foreground, waitToAddGlowSprite))
            
            // spin at a random speed, and spin a lot
            let spinSpeed: CGFloat = CGFloat((idx % 4) + 1) * CGFloat(5.0) / .pi
            let spinDuation = 1.0
            let spinAngle: CGFloat = CGFloat(idx.isEven ? -1 : 1) * spinSpeed * spinDuation
            
            // no wait before because it will wait to be added to the screen
            let spinAction = SKAction.rotate(byAngle: spinAngle, duration: spinDuation)
            let seq = SKAction.sequence(spinAction, .removeFromParent())
            spriteActions.append(.init(glow, seq))
            
            glowAlpha -= 0.05
            glowEffectZPosition -= 1_000
        }
//        
        // put the rock with sprkales in the glow
//        var newRockSprite: DFTileSpriteNode = .init(type: .empty, height: tileSize, width: tileSize)
        let createSparklyRock = SKAction.run {
            if case TileType.rock(color: let color, holdsGem: _, groupCount: let groupCount) = targetTileType.type {
                
                // creat the new one
                rockSprite = DFTileSpriteNode(type: .rock(color: color, holdsGem: true, groupCount: groupCount), height: tileSize, width: tileSize)
                rockSprite.position = .zero
                rockSprite.zPosition = glowEffectZPosition*2
                
//                foreground.addChild(rockSprite)
            }
        }.waitBefore(delay: waitBefore)
        
        spriteActions.append(.init(foreground, createSparklyRock))
        
        /// UNSQUASH ROCK
        let finalRockUnSquash = SKAction.scaleX(by: 4, y: 1.0, duration: 0.0)
        spriteActions.append(.init(rockSprite, finalRockUnSquash.waitBefore(delay: waitBefore)))
        
        if case TileType.rock(color: let color, holdsGem: _, groupCount: let groupCount) = targetTileType.type,
           let sparkleAnimationSpriteSheet = TileType.rock(color: color, holdsGem: true, groupCount: groupCount).sparkleSheetName {
            let animation = SKAction.animate(with: sparkleAnimationSpriteSheet.animationFrames(), timePerFrame: timePerFrame())
            
            spriteActions.append(.init(rockSprite, animation).waitBefore(delay: waitBefore))
        }
        
        // add the spin duration
        waitBefore += 1.0
        
        /// FINALLY MOVE IT BACK TO it's palce
        // then put the rock back into place
        let finalRockDistance = (CGPoint.zero - originalRockPosition).length
        let finalRockDuration = finalRockDistance / initialRockSpeed
        let finalRockScaleNormal = SKAction.scale(to: cgTileSize, duration: finalRockDuration)

        let moveBackToOriginalPosition = SKAction.move(to: originalRockPosition, duration: finalRockDuration)
        
        let finalRockSeq = SKAction.sequence(moveBackToOriginalPosition, finalRockScaleNormal).waitBefore(delay: waitBefore)
        
        spriteActions.append(.init(rockSprite, finalRockSeq))
        
        
        return spriteActions
    }
    
    func createGemMagnetOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, playerTileCoord: TileCoord, targetTileTypes: [TargetTileType], hud: HUD, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint) -> [SpriteAction]? {
        guard let foreground = foreground,
            let tileSize = tileSize
        else { return nil }
        
        // store spriteActions
        var spriteActions: [SpriteAction] = []
        
        /// calculate this once
        let playerPosition = positionInForeground(playerTileCoord)
        
        // calculate total gems
        var totalGemsCollected = 0
        
        /// find all the target gems
        /// create a gem for each one in the stack
        for targetTileType in targetTileTypes {
            let coord = targetTileType.target
            let type = targetTileType.type
            
            if case TileType.item(let item) = type {
                
                totalGemsCollected += item.amount
                let waitPerGem = 0.07
                var zPosition: CGFloat = 1_000_000
                
                sprites[coord.row][coord.col].alpha = 0.0
                
                for amount in 1..<item.amount+1 {
                    let sprite = SKSpriteNode(texture: SKTexture(imageNamed: type.textureString()), size: CGSize(widthHeight: tileSize))
                    
                    /// add each gem sprite to the foreground
                    let position = positionInForeground(coord)
                    sprite.position = position
                    sprite.zPosition = zPosition
                    zPosition -= 1000
                    foreground.addChild(sprite)
                    
                    /// have it get big and move away slightly from it's center
                    let initalDuration: TimeInterval = 0.25
                    let negativePositive = CGFloat(Bool.randomSign)
                    let range: Range<CGFloat> = 50..<100
                    let xRandom = negativePositive * CGFloat.random(in: range)
                    let yRandom = negativePositive * CGFloat.random(in: range)
                    let moveAwayPosition = sprite.frame.center.translate(xOffset: xRandom, yOffset: yRandom)
                    let moveAwayAction = SKAction.move(to: moveAwayPosition, duration: initalDuration)
                    moveAwayAction.timingMode = .easeInEaseOut

                    let scaleUpAction = SKAction.scale(to: CGSize(widthHeight: tileSize*2), duration: initalDuration)
                    scaleUpAction.timingMode = .easeInEaseOut
                    
                    let scaleAndMoveAway = SKAction.group(moveAwayAction, scaleUpAction)
                    
                    /// calculate distance and set speed
                    let speed: CGFloat = 800
                    let distance = (playerPosition - position).length
                    let duration = distance / speed
                    
                    /// have it move away and then to the player, accelarating
                    let scaleDownAction = SKAction.scale(to: CGSize(widthHeight: tileSize/4), duration: duration)
                    let moveAction = SKAction.move(to: playerPosition, duration: duration)
                    let group = SKAction.group(scaleDownAction, moveAction, curve: .easeIn)
                    
                    // stagger the gems slightly
                    let waitBefore = SKAction.wait(forDuration: delayBefore + (waitPerGem * Double(amount)))
                    
                    
                    let seq = SKAction.sequence(waitBefore, scaleAndMoveAway, group)
                    let spriteAction = SpriteAction(sprite, seq, removeFromParentWhenComplete: true)
                    spriteActions.append(spriteAction)
                }
            }
        }
        
        /// also have the number of gems go up as each gem enters
        hud.incrementStat(offer: offer.type, updatedPlayerData: nil, totalToIncrement: totalGemsCollected)
        
        
        return spriteActions
        
        
    }
    
    func createSingleTargetOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, startTileCoord: TileCoord, targetTileCoord: TileCoord, positionInForeground: (TileCoord) -> CGPoint) -> [SpriteAction]? {
        guard let foreground = foreground,
              let tileSize = tileSize
        else {
            return nil
        }
        
        let startPosition = positionInForeground(startTileCoord)
        
        // TODO: Allow this rendering transformation to handle items without animating textures
        let potionAnimationFrames = SpriteSheet(texture: SKTexture(imageNamed: offer.textureName),
                                                rows: 1,
                                                columns: offer.spriteSheetColumns!)
        
        let placeholderSprite = SKSpriteNode(color: .clear, size: CGSize(width: tileSize, height: tileSize))
        placeholderSprite.run(SKAction.repeatForever(SKAction.animate(with: potionAnimationFrames.animationFrames(), timePerFrame: 0.2)))
        
        // add potion sprite to board
        placeholderSprite.size = CGSize(width: tileSize/2, height: tileSize/2)
        placeholderSprite.position = startPosition
        placeholderSprite.zPosition = Precedence.floating.rawValue
        foreground.addChild(placeholderSprite)
        
        /// animate it moving to the affected tile
        
        /// determine target position
        let targetPosition = positionInForeground(targetTileCoord)
        
        let moveAction = SKAction.move(to: targetPosition, duration: 1.0)
        
        /// grow animation
        let growAction = SKAction.scale(by: 4, duration: 0.5)
        let shrinkAction = SKAction.scale(by: 0.25, duration: 0.5)
        let growSkrinkSequence = SKAction.sequence([growAction, shrinkAction])
        
        let moveGrowShrink = SKAction.group([moveAction, growSkrinkSequence])
        
        /// smoke animation
        let increaseSize = SKAction.scale(to: CGSize(width: tileSize, height: tileSize), duration: 0)
        let smokeAnimation = smokeAnimation
        let increaseSmoke = SKAction.sequence([increaseSize, smokeAnimation])
        
        /// remove it
        let removeAnimation = SKAction.removeFromParent()
        
        // run it in sequence
        let sequence = SKAction.sequence([moveGrowShrink, increaseSmoke, removeAnimation])
        
        return [.init(placeholderSprite, sequence)]
        
    }
}
