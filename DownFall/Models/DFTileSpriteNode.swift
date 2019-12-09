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
    init(type: TileType, size: CGFloat) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: type.textureString()), color: .clear, size: CGSize.init(width: size, height: size))
    }
    
    init(type: TileType, height: CGFloat, width: CGFloat) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: type.textureString()),
                   color: .clear,
                   size: CGSize.init(width: width, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("DFTileSpriteNode init?(coder:) is not implemented") }
    
    func indicateAboutToAttack() {
        let blinkingSprite = SKSpriteNode(color: .yellow, size: self.size)
        blinkingSprite.zPosition = Precedence.background.rawValue
        let blink = SKAction.run {
            blinkingSprite.alpha = abs(blinkingSprite.alpha - 1)
        }
        let wait = SKAction.wait(forDuration: 0.2)
        let group = SKAction.sequence([blink, wait])
        let action = SKAction.repeatForever(group)
        blinkingSprite.run(action)
        self.addChild(blinkingSprite)
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
}

