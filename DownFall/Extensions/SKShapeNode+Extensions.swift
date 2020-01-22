//
//  SKShapeNode+Extensions.swift
//  DownFall
//
//  Created by Katz, Billy on 1/22/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKShapeNode {
    var color: UIColor {
        get {
            return self.fillColor
        }
        set {
            self.fillColor = newValue
            self.strokeColor = newValue
        }
    }
}

