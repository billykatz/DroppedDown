//
//  CGVector+Extensions.swift
//  DownFall
//
//  Created by Billy on 11/18/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import CoreGraphics

extension CGVector {
    var length: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    var max: CGFloat {
        return Swift.max(abs(dx), abs(dy))
    }
}
