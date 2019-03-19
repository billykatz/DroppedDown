//
//  Animator.swift
//  DownFall
//
//  Created by William Katz on 1/12/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

struct Animator {
    
    static func shake(label: SKNode) {
        let duration = 0.5
        let rotateLeft = SKAction.rotate(byAngle: -1, duration: duration)
        let group = SKAction.group([SKAction.rotate(byAngle: 0.5, duration: duration),
                     rotateLeft,
                     SKAction.rotate(byAngle: 1, duration: duration),
                     rotateLeft,
                     SKAction.rotate(byAngle: 0.5, duration: duration)])
        label.run(group)
    }
    
    static func colorize(label: SKLabelNode) {
        let group = SKAction.group([SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.5)])
        label.run(group)
    }
}
