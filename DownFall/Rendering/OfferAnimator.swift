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
    
    func animateCollectingOffer(_ offer: StoreOffer, playerPosition: TileCoord, targetTileTypes: [TargetTileType], delayBefore: TimeInterval, hud: HUD, sprites: [[DFTileSpriteNode]], endTiles: [[Tile]], transformationOffers: [StoreOffer]?, positionInForeground: PositionGiver, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        switch offer.type {
        case .transmogrifyPotion, .killMonsterPotion:
            if let firsTarget = targetTileTypes.first?.target, let spriteAction = createSingleTargetOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileCoord: firsTarget, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: spriteAction)
            }
            
        case .gemMagnet:
            if let gemAction = createGemMagnetOfferAnimation(delayBefore: delayBefore, offer: offer, playerTileCoord: playerPosition, targetTileTypes: targetTileTypes, hud: hud, sprites: sprites, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: gemAction)
            }
                
              
        case .infusion:
            if let firstTarget = targetTileTypes.first, let infusion = createInfusionOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileType: firstTarget, sprites: sprites, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: infusion)
            }
            
        case .snakeEyes:
            if let snakeEyesAnimation = createSnakeEyesOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileTyes: targetTileTypes, sprites: sprites) {
                spriteActions.append(contentsOf: snakeEyesAnimation)
            }
            
        case .liquifyMonsters:
            if let animation = createLiquifyMonstersOfferAnimation(delayBefore: delayBefore, offer: offer, startTileCoord: playerPosition, targetTileTypes: targetTileTypes, sprites: sprites, positionGiver: positionInForeground) {
                spriteActions.append(contentsOf: animation)
            }
            
        case .chest:
            if let finalOffer = transformationOffers?.first,
                let animation = createChestOfferAnimation(delayBefore: delayBefore, offer: offer, finalOffer: finalOffer, startTileCoord: playerPosition, targetTileTypes: targetTileTypes, sprites: sprites, positionGiver: positionInForeground) {
                spriteActions.append(contentsOf: animation)
            }
        
        default:
            break
            
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func createChestOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, finalOffer: StoreOffer, startTileCoord: TileCoord, targetTileTypes: [TargetTileType], sprites: [[DFTileSpriteNode]], positionGiver: PositionGiver) -> [SpriteAction]? {
        guard let tileSize = tileSize, let foreground = foreground else { return nil }
        let cgTileSize = CGSize(widthHeight: tileSize)
        var spriteActions: [SpriteAction] = []
        
        var waitBefore: TimeInterval = delayBefore
        
        // open up the chest
        let openChestSprite = SKSpriteNode(texture: SKTexture(imageNamed: "open-chest"), size: cgTileSize)
        openChestSprite.zPosition = 1_000_000
        openChestSprite.position = positionGiver(startTileCoord).translateVertically(-20)
        
        foreground.addChild(openChestSprite)
        
        let moveDuration = 0.2
        let moveUpChestSlowly = SKAction.moveBy(x: 0, y: 40, duration: moveDuration)
        
        spriteActions.append(.init(openChestSprite, moveUpChestSlowly))
        
        waitBefore += moveDuration
        
        // create all the items possible
        var itemsToShow: [StoreOffer] = StoreOfferType.allCases.filter { $0 != finalOffer.type }.map { StoreOffer.offer(type: $0, tier: 1) }.shuffled()
        itemsToShow.append(finalOffer)
        
        // show each one for a moment and then show the next one
        // slowly increase the amount of time that we show an item
        // finally show the final item
        var startingShowTime: TimeInterval = 0.05
        var itemToShowPosition = openChestSprite.position
        itemToShowPosition = itemToShowPosition.translateVertically(200)
        
        var finalItemSprite: SKSpriteNode = finalOffer.sprite
        let floatTotalItems = CGFloat(itemsToShow.count)
        for (idx, itemToShow) in itemsToShow.enumerated() {
            let floatIndex = CGFloat(idx)
            let itemSprite = SKSpriteNode(texture: SKTexture(imageNamed: itemToShow.textureName), size: cgTileSize.scale(by: 1.5))
            itemSprite.position = itemToShowPosition
            itemSprite.zPosition = 1_750_000
            let appearAction = SKAction.run {
                foreground.addChild(itemSprite)
            }
            
            let initialWaitAction = SKAction.wait(forDuration: waitBefore)
            let foregroundSeq = SKAction.sequence(initialWaitAction, appearAction)
            spriteActions.append(.init(foreground, foregroundSeq))
            
            waitBefore += startingShowTime
            
            finalItemSprite = itemSprite
            
            if (itemToShow != itemsToShow.last) {
                let waitBeforeRemove = SKAction.wait(forDuration: startingShowTime)
                let itemAction = SKAction.sequence(waitBeforeRemove, .removeFromParent())
                spriteActions.append(.init(itemSprite, itemAction))
                
                waitBefore += startingShowTime
            }
            
            
            if floatIndex > floatTotalItems / 6 * 5 {
                startingShowTime = 0.2
            } else if floatIndex > floatTotalItems / 4 * 3 {
                startingShowTime = 0.13
            } else if floatIndex > floatTotalItems / 2  {
                startingShowTime = 0.08
            } else {
                startingShowTime = 0.04
            }


        }
        
        // show glow fun stuff
        let durationBeforeGlow = TimeInterval(0.2)
        var glowEffectZPosition: CGFloat = 500_000
        var glowAlpha = 1.0
        for idx in 1..<11 {
            let glow = SKSpriteNode(texture: SKTexture(imageNamed: "crystalGlow"), size: tileCGSize.scale(by: 3 + CGFloat(idx)/10))
            var glowPosition = positionGiver(startTileCoord)
            glowPosition = glowPosition.translateVertically(150)
            glow.position = glowPosition
            glow.zPosition = glowEffectZPosition
            glow.alpha = glowAlpha
            
            let waitToAddGlowSprite = SKAction.run { [foreground] in
                foreground.addChild(glow)
            }.waitBefore(delay: durationBeforeGlow)
            spriteActions.append(.init(foreground, waitToAddGlowSprite))
            
            // spin at a random speed, and spin a lot
            let spinSpeed: CGFloat = CGFloat((idx % 4) + 1) * CGFloat(5.0) / .pi
            // spin the entire time we are showing the options
            let spinDuation = (waitBefore + 0.2)
            let spinAngle: CGFloat = CGFloat(idx.isEven ? -1 : 1) * spinSpeed * spinDuation
            
            // no wait before because it will wait to be added to the screen
            let spinAction = SKAction.rotate(byAngle: spinAngle, duration: spinDuation)
            let seq = SKAction.sequence(spinAction, .removeFromParent())
            spriteActions.append(.init(glow, seq))
            
            glowAlpha -= 0.05
            glowEffectZPosition -= 1_000
        }
        
        // remove the chest
        let removeOpenChestSprite = SKAction.scale(to: .zero, duration: 0.2)
        let openChestFinalSeq = SKAction.sequence(removeOpenChestSprite, .removeFromParent()).waitBefore(delay: waitBefore)
        spriteActions.append(.init(openChestSprite, openChestFinalSeq))

        
        // grow the final offer sprite
        // raise it up slowly
        // and then scale way small as the player collects it
        let scaleFinalOffer = SKAction.scale(by: 2.0, duration: 0.2)
        let raiseUpSlowly = SKAction.moveBy(x: 0.0, y: 30, duration: 0.2)
        let scaleAndRaise = SKAction.group(scaleFinalOffer, raiseUpSlowly, curve: .easeInEaseOut)
        
        let scaleDown = SKAction.scale(to: cgTileSize.scale(by: 0.25), duration: 0.2)
        let moveToPlayerPosition = SKAction.move(to: positionGiver(startTileCoord), duration: 0.2)
        let scaleDownAndMove = SKAction.group(scaleDown, moveToPlayerPosition, curve: .easeIn).waitBefore(delay: 1.0)
        
        let finalItemSeq = SKAction.sequence(scaleAndRaise, scaleDownAndMove, .removeFromParent()).waitBefore(delay: 0.2)
        
        spriteActions.append(.init(finalItemSprite, finalItemSeq))
        
        
        return spriteActions
    }
    
    func createLiquifyMonstersOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, startTileCoord: TileCoord, targetTileTypes: [TargetTileType], sprites: [[DFTileSpriteNode]], positionGiver: PositionGiver) -> [SpriteAction]? {
        guard let tileSize = tileSize, let foreground = foreground else { return nil }
        let cgTileSize = CGSize(widthHeight: tileSize)
        var spriteActions: [SpriteAction] = []
        let moveDuration = 0.25
        var waitBefore: TimeInterval = delayBefore
        
        // make the liquify monsters sprite fly from the player to the targeted monsters
        for targetTileType in targetTileTypes {
            let liquifyMonsterSprite = SKSpriteNode(texture: SKTexture(imageNamed: "liquifyMonsters"), size: cgTileSize)
            liquifyMonsterSprite.position = positionGiver(startTileCoord)
            liquifyMonsterSprite.zPosition = 1_000_000
            liquifyMonsterSprite.alpha = 1.0
            
            foreground.addChild(liquifyMonsterSprite)
            
            let targetPosition = positionGiver(targetTileType.target)
            
            let moveAction = SKAction.move(to: targetPosition, duration: moveDuration)
            
            
            // make it glow and blink
            let lowerFade: CGFloat = 0.0
            let waitForABlink = SKAction.wait(forDuration: 0.05)
            let fadeToNone0 = SKAction.fadeAlpha(to: lowerFade, duration: 0.2)
            let fadeToFull1 = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let fadeToHalf1 = SKAction.fadeAlpha(to: lowerFade, duration: 0.2)
            let fadeToFull2 = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            let fadeToHalf2 = SKAction.fadeAlpha(to: lowerFade, duration: 0.1)
            let fadeToFull3 = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
            let fadeToHalf3 = SKAction.fadeAlpha(to: lowerFade, duration: 0.05)
            let fadeToFull4 = SKAction.fadeAlpha(to: 1.0, duration: 0.025)
            let fadeToHalf4 = SKAction.fadeAlpha(to: lowerFade, duration: 0.025)
            let fadeToFull5 = SKAction.fadeAlpha(to: 1.0, duration: 0.0125)
            let fadeToHalf5 = SKAction.fadeAlpha(to: lowerFade, duration: 0.0125)
            
            let seq = SKAction.sequence(moveAction, fadeToNone0, waitForABlink, fadeToFull1, fadeToHalf1, waitForABlink, fadeToFull2, fadeToHalf2, waitForABlink, fadeToFull3, fadeToHalf3, waitForABlink, fadeToFull4, fadeToHalf4, waitForABlink, fadeToFull5, fadeToHalf5, .removeFromParent(), curve: .easeInEaseOut)
            
            spriteActions.append(.init(liquifyMonsterSprite, seq))
            
        }
        // calculated by hand
        let flashDuration: TimeInterval = 1.225
        waitBefore += flashDuration + moveDuration
        

        // make the monster poof
        for targetTileType in targetTileTypes {
            let sprite = sprites[targetTileType.target]
            
            let removeSpriteAttackIndicator: SKAction = .run {
                sprite.removeAttackIndicator()
            }
            
            // poof the offers away in a bit of smoke
            let poofAction = smokeAnimation
            let scaleAction = SKAction.scale(by: 3.0, duration: 0.1)
            
            
            let group = SKAction.group(removeSpriteAttackIndicator, poofAction, scaleAction).waitBefore(delay: waitBefore)
            
            spriteActions.append(.init(sprite, group))
        }
        
        // leave behind 10x gem stack (handled by just called animations finished in the Renderer
        
        
        return spriteActions
    }
    
    func createSnakeEyesOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, startTileCoord: TileCoord, targetTileTyes: [TargetTileType], sprites: [[DFTileSpriteNode]]) -> [SpriteAction]? {

        
        var spriteActions: [SpriteAction] = []
        
        
        // spin the current offers (located in sprites)
        for targetTileType in targetTileTyes {
            let currentOfferSprite = sprites[targetTileType.target]
            
            currentOfferSprite.zPosition = 1_000_000
            
            let spinSpeed: CGFloat = 20
            let spinDuration: CGFloat = 1.0
            let spinAngle: CGFloat = -spinSpeed * spinDuration
            
            // spit it
            let spinAction = SKAction.rotate(byAngle: spinAngle, duration: spinDuration)
            spinAction.timingMode = .easeIn
            
            let removeOfferTierBorder = SKAction.run {
                currentOfferSprite.hideOfferTier()
            }
            
            // poof the offers away in a bit of smoke
            let poofAction = smokeAnimation
            let scaleAction = SKAction.scale(by: 3.0, duration: 0.1)
            let poofScale = SKAction.group(poofAction, scaleAction)
            
            
            let seq = SKAction.sequence(spinAction, removeOfferTierBorder, poofScale).waitBefore(delay: delayBefore)
            
            spriteActions.append(.init(currentOfferSprite, seq))
        }
        
        
        return spriteActions
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
        let potionAnimationFrames: SpriteSheet
        if let spriteSheet = offer.spriteSheetName {
            potionAnimationFrames = SpriteSheet(texture: SKTexture(imageNamed: spriteSheet),
                                                rows: 1,
                                                columns: offer.spriteSheetColumns!)
        } else {
            potionAnimationFrames = SpriteSheet(texture: SKTexture(imageNamed: offer.textureName),
                                                rows: 1,
                                                columns: 1)

        }
        
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
