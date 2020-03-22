//
//  SKView+Extensions.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import SpriteKit

extension SKView {
    func isInTop(_ gestureRecognizer: UISwipeGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return location.y < (frame.height)/2
    }
    
    func isOnRight(_ gestureRecognizer: UISwipeGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return location.x > (frame.width)/2
    }
    
    func isInTop(_ point: CGPoint?) -> Bool {
        guard let point = point else { return false }
        return point.y > (frame.height)/2
    }
    
    func isOnRight(_ point: CGPoint?) -> Bool {
        guard let point = point else { return false }
        return point.x > (frame.width)/2
    }

}

