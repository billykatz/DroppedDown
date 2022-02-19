//
//  OfferAnimator.swift
//  DownFall
//
//  Created by Billy on 2/19/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit



extension Animator {
    
    func animateCollectingOffer(_ offer: StoreOffer, playerPosition: TileCoord, targetPositions: [TileCoord], positionInForeground: (TileCoord) -> CGPoint, completion: @escaping () -> Void) {
        var spriteActions: [SpriteAction] = []
        switch offer.type {
        case .transmogrifyPotion, .killMonsterPotion:
            if let spriteAction = createSingleTargetOfferAnimation(delayBefore: 0.0, offer: offer, startTileCoord: playerPosition, targetTileCoord: targetPositions.first!, positionInForeground: positionInForeground) {
                spriteActions.append(contentsOf: spriteAction)
            }
        case .gemMagnet:
            ()
        default:
            break
            
        }
        
        animate(spriteActions, completion: completion)
        
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
