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
}

