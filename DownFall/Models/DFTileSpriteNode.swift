//
//  DFTileSpriteNode.swift
//  DownFall
//
//  Created by Katz, Billy-CW on 12/20/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit
import Foundation

protocol Tappable {
    func isTappable() -> Bool
}

extension DFTileSpriteNode: Tappable {
    func isTappable() -> Bool {
        return type != .player && type != .exit
    }
}

class DFTileSpriteNode: SKSpriteNode {
    var type : TileType
    init(type: TileType) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: type.rawValue), color: .clear, size: CGSize.init(width: 75.0, height: 75.0))
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

