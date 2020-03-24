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
    case left
    case right
    
    init(from vector: CGVector) {
        if abs(vector.dx) > abs(vector.dy) {
            if vector.dx > 0 { self = .right }
            else { self = .left }
        }
        else {
            if vector.dy > 0 { self = .up }
            else { self = .down }
        }
    }
}

enum RotateDirection {
    case counterClockwise
    case clockwise
    
    init(from swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .up, .right:
            self = .counterClockwise
        case .down, .left:
            self = .clockwise
        }
    }
}
