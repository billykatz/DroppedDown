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
    let _endTileStruct: [[Tile]]?
    var endTilesStruct: [[Tile]]? {
        if case InputType.transformation(let tranformations) = self.type {
            return _endTileStruct ?? tranformations.first?.endTiles
        }
        return _endTileStruct
    }

    init(_ type: InputType,
         _ endTilesStruct: [[Tile]]? = []) {
        self.type = type
        self._endTileStruct = endTilesStruct
    }
    
    var debugDescription: String {
        return "{Input: \(type)}"
    }
}

struct InputQueue {
    
    struct Constants {
        static let tag = String(describing: InputQueue.self)
    }
    
    static var history: [Input] = []
    static var queue: [Input] = []
    static var gameState = AnyGameState(PlayState())
    
    /// Attempts to append the input given the current game state
    static func append(_ input: Input, given: AnyGameState = gameState) {
#if DEBUG
        GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] Begin append method \(input.type). Current state \(gameState.state)")
#endif
        
        if gameState.shouldAppend(input) {
#if DEBUG
            GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] Appending \(input.type)")
#endif
            queue.append(input)
            return
        }
#if DEBUG
        if let first = history.first {
            GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] \(input.type) is being ignored. Current game state is \(gameState.state). The last input was \(first)")
        } else {
            GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] \(input.type) is being ignored. Current game state is \(gameState.state). No history")
        }
#endif
        
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
#if DEBUG
                GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] Entering \(gameState.state) with \(input).  Last game state \(oldGameState.state)")
                if case let InputType.transformation(trans) = input.type {
                    if let first = trans.first?.inputType {
                        GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] The transformation is \(first))")
                        print()
                    } else {
                        GameLogger.shared.log(prefix: Constants.tag, message: "[Input Queue] No transformation")
                    }
                }
#endif
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


