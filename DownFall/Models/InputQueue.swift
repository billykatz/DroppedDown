//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

enum Input {
    case touch(TileCoord)
    case rotateLeft
    case rotateRight
}

struct InputQueue {
    var queue: [Input]
    
    @discardableResult mutating func append(_ input: Input) -> Bool {
        queue.append(input)
        return true
    }
    
    mutating func pop() -> Input? {
        //there should be some way for this to know when it can or cannot pop
        let input = queue.first
        queue = Array(queue.dropFirst())
        return input
    }
}


