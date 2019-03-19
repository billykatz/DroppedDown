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
    var type : TileType
    init(type: TileType, size: CGFloat) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: type.textureString()), color: .clear, size: CGSize.init(width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("DFTileSpriteNode init?(coder:) is not implemented") }
    
    func animatedPlayerAction() -> SKAction {
        var textureNames: [SKTexture] = []
        for frame in 1...9 {
            textureNames.append(SKTexture(imageNamed: "Burly-person-v2-frame-\(frame)"))
        }
        for frame in 0..<9 {
            textureNames.append(SKTexture(imageNamed: "Burly-person-v2-frame-\(9-frame)"))
        }
        let animation = SKAction.animate(with: textureNames, timePerFrame: 0.1)
        return animation
    }
}

