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
        case .exit:
            let mineshaft = SKTexture(imageNamed: "mineshaft")
            let tracks = SKTexture(imageNamed: "tracks")
            let minecart = SKTexture(imageNamed: "minecart")
            
            let size = CGSize(width: width, height: height)
            let minecartSize = CGSize(width: width*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient,
                                      height: height*Style.DFTileSpriteNode.Exit.minecartSizeCoefficient)
            super.init(texture: mineshaft,
                       color: .clear,
                       size: size)
            
            let trackSprite = SKSpriteNode(texture: tracks, size: size)
            trackSprite.zPosition = Precedence.background.rawValue
            addChild(trackSprite)
            let minecartSprite = SKSpriteNode(texture: minecart, size: minecartSize)
            minecartSprite.zPosition = Precedence.foreground.rawValue
            minecartSprite.position = CGPoint.position(this: minecartSprite.frame, centeredInBottomOf: self.frame, verticalPadding: Style.Padding.less)
            minecartSprite.name = "minecart"
            addChild(minecartSprite)
            
        default:
            
            super.init(texture: SKTexture(imageNamed: type.textureString()),
                       color: .clear,
                       size: CGSize.init(width: width, height: height))
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("DFTileSpriteNode init?(coder:) is not implemented") }
    
    func removeMinecart() {
        guard self.type == .exit else { return }
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
    
    func tutorialHighlight(){
        if TileType.rockCases.contains(type) {
            let whiteSprite = SKSpriteNode(color: .white, size: size)
            whiteSprite.zPosition = Precedence.background.rawValue
            whiteSprite.alpha = 0.75
            self.addChild(whiteSprite)
            
        } else {
            let border = SKShapeNode(circleOfRadius: Style.TutorialHighlight.radius)
            border.strokeColor = .highlightGold
            border.lineWidth = Style.TutorialHighlight.lineWidth
            border.position = .zero
            border.zPosition = Precedence.menu.rawValue
            
            self.addChild(border)
        }
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
    
    func crumble() -> (SKSpriteNode, SKAction)? {
        var animationFrames: [SKTexture] = []
        switch self.type {
        case .brownRock:
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.brownRockCrumble), rows: 1, columns: 4).animationFrames()
        case .redRock:
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.redRockCrumble), rows: 1, columns: 4).animationFrames()
        case .blueRock:
            animationFrames = SpriteSheet(texture: SKTexture(imageNamed: Identifiers.Sprite.Sheet.blueRockCrumble), rows: 1, columns: 4).animationFrames()
        default:
            return nil
        }
        
        let animateCrumble = SKAction.animate(with: animationFrames, timePerFrame: 0.08)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([animateCrumble, removeFromParent])
        return (self, sequence)
    }
    
}

