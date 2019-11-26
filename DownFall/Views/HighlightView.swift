//
//  HighlightView.swift
//  DownFall
//
//  Created by William Katz on 11/10/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

class HighlightView: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
