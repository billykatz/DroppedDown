//
//  SKNode+Extension.swift
//  DownFall
//
//  Created by William Katz on 5/17/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKNode {
    func wasTouched(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let _ = touches.first else { return false }
        return true
    }
    
    func addOptionalChild(_ child: SKNode?) {
        guard let nonNilChild = child else {
            fatalError("Error: trying to add a nil child to a node")
        }
        addChild(nonNilChild)
    }
    
    func addChildSafely(_ child: SKNode?) {
        let childPosition = child?.position
        if child?.parent != nil {
            child?.removeFromParent()
            addOptionalChild(child)
        } else {
            addOptionalChild(child)
        }
        child?.position = childPosition ?? .zero
    }

}
