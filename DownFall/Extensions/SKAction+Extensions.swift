//
//  SKAction+Extensions.swift
//  DownFall
//
//  Created by Billy on 11/19/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKAction {
    static let zero = SKAction.wait(forDuration: 0.0)
    
    static func sequence(_ seq: SKAction..., curve: SKActionTimingMode = .linear) -> SKAction {
        let action = SKAction.sequence(seq)
        action.timingMode = curve
        return action
    }
    
    static func group(_ group: SKAction..., curve: SKActionTimingMode = .linear) -> SKAction {
        let action = SKAction.group(group)
        action.timingMode = curve
        return action
    }

}

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX: Int = 3, amplitudeY: Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y: dy, duration: Double(0.015))
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}
