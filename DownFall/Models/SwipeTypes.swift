//
//  SwipeTypes.swift
//  DownFall
//
//  Created by Katz, Billy on 3/24/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import CoreGraphics

enum SwipeDirection: String {
    case up
    case down
    case left
    case right
    
    init(from vector: CGVector) {
        let maxX = abs(vector.dx)
        let maxY = abs(vector.dy)
        if maxX > maxY {
            if vector.dx > 0 { self = .right }
            else { self = .left }
        } else {
            if vector.dy > 0 { self = .up }
            else { self = .down }
        }
        
        print("$$$ MaxX \(maxX)  MaxY \(maxY)")
        print("$$$Rotate Swipe Direction \(self.rawValue)")
    }
}

enum RotateDirection {
    case counterClockwise
    case clockwise
    
    init(from swipeDirection: SwipeDirection, isOnRight: Bool, isOnTop: Bool) {
        switch swipeDirection {
        case .up:
            self = isOnRight ? .counterClockwise : .clockwise
        case .down:
            self = isOnRight ? .clockwise : .counterClockwise
        case .right:
            self = isOnTop ? .clockwise : .counterClockwise
        case .left:
            self = isOnTop ? .counterClockwise : .clockwise
        }
    }
}
