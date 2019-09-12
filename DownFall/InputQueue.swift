//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit


struct InputQueue {
    static var queue: [Input] = []
    static var gameState = AnyGameState(PlayState())
    
    /// Attempts to append the input given the current game state
    static func append(_ input: Input, given: AnyGameState = gameState) {
        if gameState.shouldAppend(input) {
            queue.append(input)
        }
    }
    
    static func pop() -> Input? {
        guard let input = InputQueue.peek(),
            let transition = InputQueue.gameState.transitionState(given: input) else {
                if !queue.isEmpty {
                    queue.removeFirst()
                }
            return nil
        }
        
        queue = Array(queue.dropFirst())
        let oldGameState = gameState
        gameState = transition
        
        if gameState.state != oldGameState.state {
            gameState.enter(input)
        }
        
        return input
    }
    
    static func peek() -> Input? {
        guard !queue.isEmpty else { return nil }
        return queue.first
    }
}

extension InputQueue {
    static var debugDescription: String {
        var output = ""
        output += "Current gameState: \(gameState.state)"
        output += "\nCurrent queue \(queue)"
        return output
    }
}

protocol Resets {
    static var queue: [Input] { get set }
    static var gameState: AnyGameState { get set }
    static func reset(to startingGameState: AnyGameState)
}

extension InputQueue: Resets {
    static func reset(to startingGameState: AnyGameState = AnyGameState(PlayState())) {
        queue = []
        gameState = startingGameState
    }
}

extension InputType {
    static func legalMoves() -> [InputType] {
        let moves =  [InputType.rotateRight,
                      .rotateLeft,
                      .touch(TileCoord(0, 0), .blackRock)]
        return moves
    }
}
