//
//  DFTileSpriteNode.swift
//  DownFall
//
//  Created by Katz, Billy-CW on 12/20/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import Foundation

class DFTileSpriteNode: SKSpriteNode {
    var type: TileType
    init(type: TileType, height: CGFloat, width: CGFloat) {
        self.type = type
        switch type {
        case .exit(let blocked):
            if blocked {
                super.init(texture: SKTexture(imageNamed: type.textureString()),
                           color: .clear,
                           size: CGSize(width: width, height: height))
            } else {
                let mineshaft = SKTexture(imageNamed: "mineshaft")
                let tracks = SKTexture(imageNamed: "tracks")
                let minecart = SKTexture(imageNamed: "minecart")
                
                let size = CGSize(width: width, height: height)
                let minecartSize = CGSize(width: width*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient,
                                          height: height*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient)
                super.init(texture: mineshaft,
                           color: .clear,
                           size: size)
                
                let minecartSprite = SKSpriteNode(texture: minecart, size: minecartSize)
                minecartSprite.zPosition = Precedence.foreground.rawValue
                minecartSprite.position = CGPoint.position(this: minecartSprite.frame, centeredInBottomOf: self.frame, verticalPadding: Style.Padding.less)
                minecartSprite.name = "minecart"
                addChild(minecartSprite)
                
                let trackSprite = SKSpriteNode(texture: tracks, size: size)
                trackSprite.zPosition = Precedence.background.rawValue
                addChild(trackSprite)
            }
            
        default:
            
            super.init(texture: SKTexture(imageNamed: type.textureString()),
                       color: .clear,
                       size: CGSize(width: width, height: height))
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("DFTileSpriteNode init?(coder:) is not implemented") }
    
    func removeMinecart() {
        guard case TileType.exit = self.type else { return }
        for child in children {
            if child.name == "minecart" {
                child.removeFromParent()
            }
        }
    }
    
    func indicateSpriteWillBeAttacked() {
        let indicatorSprite = SKSpriteNode(color: .yellow, size: self.size)
        indicatorSprite.zPosition = Precedence.background.rawValue
        
        self.addChild(indicatorSprite)
        
        let wait = SKAction.wait(forDuration: 2.0)
        let remove = SKAction.removeFromParent()
        indicatorSprite.run(SKAction.sequence([wait, remove]))
    }
    
    func indicateSpriteWillBeEaten() {
        let indicatorSprite = SKSpriteNode(color: .red, size: self.size)
        indicatorSprite.zPosition = Precedence.background.rawValue
        
        self.addChild(indicatorSprite)
        
        let wait = SKAction.wait(forDuration: 5.0)
        let remove = SKAction.removeFromParent()
        indicatorSprite.run(SKAction.sequence([wait, remove]))
    }
    
    func indicateSpriteWillBeBossAttacked() {
        let indicatorSprite = SKSpriteNode(color: .clayRed, size: self.size)
        indicatorSprite.zPosition = Precedence.background.rawValue
        
        self.addChild(indicatorSprite)
        
        let wait = SKAction.wait(forDuration: 5.0)
        let remove = SKAction.removeFromParent()
        indicatorSprite.run(SKAction.sequence([wait, remove]))
    }
    
    func indicateSpriteIsBossAttacked() {
        let indicatorSprite = SKSpriteNode(color: .foregroundBlue, size: self.size)
        indicatorSprite.zPosition = Precedence.background.rawValue
        
        self.addChild(indicatorSprite)
        
        let wait = SKAction.wait(forDuration: 5.0)
        let remove = SKAction.removeFromParent()
        indicatorSprite.run(SKAction.sequence([wait, remove]))
    }
    
    /**
     Indicates that attack timing of a sprite
     
     - Parameter frequency:  The frequency of an attack
     - Parameter turns:  The turns until the next attack
     
     */
    
    func showAttackTiming(_ frequency: Int,
                          _ turns: Int) {
        
        let size = CGSize(width: self.frame.width * 0.1, height: frame.height * 0.1)
        
        var previousCircle: SKShapeNode?
        
        var color = UIColor.clear
        if turns == 0 {
            color = .green
        } else if turns == 1 {
            color = .yellow
        } else {
            color = .red
        }
        previousCircle = SKShapeNode(circleOfRadius: size.width)
        previousCircle?.fillColor = color
        previousCircle?.strokeColor = color
        previousCircle?.position = CGPoint.position(previousCircle?.frame, inside: frame, verticalAlign: .bottom, horizontalAnchor: .right)
        previousCircle?.zPosition = Precedence.foreground.rawValue
        addOptionalChild(previousCircle)
        
    }
    
    func showFinger() {
        let finger = SKSpriteNode(imageNamed: "finger")
        finger.position = CGPoint.position(this: finger.frame,
                                           centeredInBottomOf: self.frame,
                                           verticalPadding: -Style.Padding.most)
        finger.size = Style.TutorialHighlight.fingerSize
        
        let moveDownVector = CGVector.init(dx: 0.0, dy: -20.0)
        let moveUpVector = CGVector.init(dx: 0.0, dy: 20.0)
        let moveDownAnimation = SKAction.move(by: moveDownVector, duration: Style.TutorialHighlight.fingerTimeInterval)
        let moveUpAnimation = SKAction.move(by: moveUpVector, duration: Style.TutorialHighlight.fingerTimeInterval)
        
        let indicateAnimation = SKAction.repeatForever(SKAction.sequence([moveDownAnimation, moveUpAnimation]))
        finger.run(indicateAnimation)
        finger.zPosition = Precedence.menu.rawValue
        
        self.addChild(finger)
    }
    
    func glow() -> (SKSpriteNode, SKAction)? {
        guard type == TileType.item(.gem)  else { return nil }
        let gemGlow = SKSpriteNode(texture: SKTexture(imageNamed: "crystalGlow"), color: .clear, size: self.size)
        let spin = SKAction.rotate(byAngle: .pi*2.0, duration: AnimationSettings.Renderer.glowSpinSpeed)
        let shrink = SKAction.scale(by: 0.8, duration: 1.0)
        let grow = SKAction.scale(to: self.size, duration: 1.0)
        let shrinkThenGrow = SKAction.sequence([shrink, grow])
        let shrinkGrowForever = SKAction.repeatForever(shrinkThenGrow)
        let spinIndefinitelyAction = SKAction.repeatForever(spin)
        gemGlow.zPosition = Precedence.underground.rawValue
        return (gemGlow, SKAction.group([shrinkGrowForever, spinIndefinitelyAction]))
    }
    
    func crumble() -> (SKSpriteNode, SKAction)? {
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .rock(.brown, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.brownRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.red, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.redRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.blue, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.blueRockCrumble), rows: 1, columns: 4).animationFrames()
        case .rock(.purple, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.purpleRockCrumble), rows: 1, columns: 4).animationFrames()
        default:
            return nil
        }
        
        let animateCrumble = SKAction.animate(with: animationFrames, timePerFrame: 0.08)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([animateCrumble, removeFromParent])
        return (self, sequence)
    }
    
    func sparkle() -> SKAction? {
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .rock(.red, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.redRockWithGem), rows: 1, columns: 11).animationFrames()
        case .rock(.blue, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.blueRockWithGem), rows: 1, columns: 13).animationFrames()
        case .rock(.purple, _):
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.purpleRockWithGem), rows: 1, columns: 10).animationFrames()
        default:
            return nil
        }
        
        let emptySprite = SKSpriteNode(color: .clear, size: size)
        emptySprite.name = "child"
        let addSprite = SKAction.run { [weak self] in
            self?.addChildSafely(emptySprite)
        }
        let waitAction = SKAction.wait(forDuration: TimeInterval(Int.random(lower: 2, upper: 10)),
                                       withRange: TimeInterval(Int.random(lower: 2, upper: 10)))
        let animateAction = SKAction.animate(with: animationFrames, timePerFrame: 0.08)
        let removeSprite = SKAction.run { [weak self] in
            self?.removeChild(with: "child")
        }
        let sequence = SKAction.sequence([waitAction, addSprite, animateAction, removeSprite])
        let repeatForever = SKAction.repeatForever(sequence)
        return repeatForever

    }
    
}

