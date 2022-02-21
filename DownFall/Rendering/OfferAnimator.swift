//
//  OfferAnimator.swift
//  DownFall
//
//  Created by Billy on 2/19/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

struct TargetTileTypes {
    let target: TileCoord
    let type: TileType
}

extension Animator {
    
    func animateCollectingOffer(_ offer: StoreOffer, playerPosition: TileCoord, targetTileTypes: [TargetTileTypes], delayBefore: TimeInterval, hud: HUD, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint, completion: @escaping () -> Void) {
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
                
                
        default:
            break
            
        }
        
        animate(spriteActions, completion: completion)
        
    }
    
    func createGemMagnetOfferAnimation(delayBefore: TimeInterval, offer: StoreOffer, playerTileCoord: TileCoord, targetTileTypes: [TargetTileTypes],  hud: HUD, sprites: [[DFTileSpriteNode]], positionInForeground: (TileCoord) -> CGPoint) -> [SpriteAction]? {
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
