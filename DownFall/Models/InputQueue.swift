//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

enum Input : Equatable, Hashable {
    case touch(TileCoord)
    case rotateLeft
    case rotateRight
    case playerAttack
    case monsterAttack(TileCoord)
    case monsterDies(TileCoord)
    case gameWin
    case gameLose
    case animationFinished 
}

struct InputQueue {
    static var queue: [Input] = []
    static private var animating = false
    
    @discardableResult static func append(_ input: Input) -> Bool {
        if input == .animationFinished {
            animating = false
            return true
        }
        queue.append(input)
        return true
    }
    
    static func pop() -> Input? {
        //there should be some way for this to know when it can or cannot pop
        guard !queue.isEmpty else { return nil }
        guard !animating else { return nil }
        animating = true
        let input = queue.first
        queue = Array(queue.dropFirst())
        return input
    }
}


