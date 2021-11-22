//
//  SKAction+Extensions.swift
//  DownFall
//
//  Created by Billy on 11/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKAction {
    static func sequence(_ seq: SKAction..., curve: SKActionTimingMode) -> SKAction {
        let action = SKAction.sequence(seq)
        action.timingMode = curve
        return action
    }
}

