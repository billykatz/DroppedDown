//
//  SwipeTypes.swift
//  DownFall
//
//  Created by Katz, Billy on 3/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import CoreGraphics

enum SwipeDirection {
    case up
    case down
    
    init(from vector: CGVector) {
        if vector.dy > 0 { self = .up }
        else { self = .down }
    }
}

enum RotateDirection {
    case counterClockwise
    case clockwise
    
    init(from swipeDirection: SwipeDirection, isOnRight: Bool) {
        switch swipeDirection {
        case .up:
            self = isOnRight ? .counterClockwise : .clockwise
        case .down:
            self = isOnRight ? .clockwise : .counterClockwise
        }
    }
}
