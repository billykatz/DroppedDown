//
//  SKNode+Extensions.swift
//  DownFall
//
//  Created by William Katz on 12/18/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKNode {
    func addChild(_ child: SKNode?) {
        guard let nonNilChild = child else {
            fatalError("Error: trying to add a nil child to a node")
        }
        addChild(nonNilChild)
    }
}
