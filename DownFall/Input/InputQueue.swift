//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit


struct Input: Hashable, CustomDebugStringConvertible {
    let type: InputType
    let endTilesStruct: [[Tile]]?
    let transformation: Transformation?

    init(_ type: InputType,
         _ endTilesStruct: [[Tile]]? = [],
         _ transformation: Transformation? = .zero) {
        self.type = type
        self.transformation = transformation
        self.endTilesStruct = endTilesStruct
    }
    
    var debugDescription: String {
        return "{Input: \(type)}"
    }
}

struct InputQueue {
    static var history: [Input] = []
    static var queue: [Input] = []
    static var gameState = AnyGameState(PlayState())
    
    /// Attempts to append the input given the current game state
    static func append(_ input: Input, given: AnyGameState = gameState) {
        
        print("Before shouldAppend input \(input.debugDescription)")
        if gameState.shouldAppend(input) {
            queue.append(input)
            print(input.debugDescription)
        } else {
            print("Not appending because  \(gameState.state)")
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
            if let _ = NSClassFromString("XCTest") {
            } else {
                history.insert(input, at: history.startIndex)
                gameState.enter(input)
                print("Entering \(gameState.state) with \(input)")
            }
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

extension InputQueue {
    static func lastTouchInput() -> Input? {
        for input in history {
            if case InputType.touch = input.type {
                // if we reach a .touch type, then we do not have a relatively new touchBegan input and should not be concerned with older touch begans
                break
            }
            if case InputType.touchBegan = input.type {
                return input
            }
        }
        return nil
    }
}


