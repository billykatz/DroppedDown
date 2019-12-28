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
            minecartSprite.position = CGPoint.positionThis(minecartSprite.frame, inBottomOf: self.frame, padding: Style.Padding.less)
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
       finger.position = CGPoint.positionThis(finger.frame,
                                              inBottomOf: self.frame,
                                              padding: -Style.Padding.most,
                                              offset: Style.Offset.less)
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
}

