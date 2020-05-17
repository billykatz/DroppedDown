//
//  SKSpriteNode+Extensions.swift
//  DownFall
//
//  Created by William Katz on 5/16/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    convenience init(precedence: Precedence,
                     texture: SKTexture,
                     color: UIColor,
                     size: CGSize) {
        self.init(texture: texture, color: color, size: size)
        self.zPosition = precedence.rawValue
    }
    
    func addIndicator(of amount: Int) {
        let scale = CGFloat(0.4)
        let amountParagraph = ParagraphNode(text: "\(amount)", paragraphWidth: self.size.width * scale, fontSize: UIFont.extraSmallSize, fontColor: .white)
        
        let amountBackground = SKShapeNode(rectOf: self.size.applying(CGAffineTransform(scaleX: scale, y: scale)))
        amountBackground.color = .black
        amountBackground.zPosition = Precedence.menu.rawValue
        
        amountBackground.addChild(amountParagraph)
        
        amountBackground.position = CGPoint.position(amountBackground.frame, inside: self.frame, verticalAlign: .bottom, horizontalAnchor: .right)
        
        addChild(amountBackground)
    }
    
    func addZPositionToChildren(_ zPos: CGFloat) {
        for child in children {
            child.zPosition = zPos
        }
    }
}

