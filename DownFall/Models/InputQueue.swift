//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

enum InputType : Equatable, Hashable, CaseIterable{
    static var allCases: [InputType] = [.touch(TileCoord(0,0)), .rotateLeft, .rotateRight, .playerAttack,
                                        .monsterAttack(TileCoord(0,0)), .monsterDies(TileCoord(0,0)), .gameWin, .gameLose,
                                        .play, .pause, .animationsFinished, .playAgain]
    
    typealias AllCases = [InputType]
    
    case touch(TileCoord)
    case rotateLeft
    case rotateRight
    case playerAttack
    case monsterAttack(TileCoord)
    case monsterDies(TileCoord)
    case gameWin
    case gameLose
    case play
    case pause
    case animationsFinished
    case playAgain
    
    var canBeNonUserGenerated: Bool {
        switch self {
            case .playerAttack, .monsterAttack, .monsterDies,
                 .animationsFinished, .gameWin, .gameLose:
            return true
        default:
            return false
        }
    }
}

struct Input: Hashable {
    let type: InputType
    let userGenerated: Bool
    
    init(_ type: InputType, _ userGenerated: Bool) {
        self.type = type
        self.userGenerated = userGenerated
    }
}

struct InputQueue {
    static var queue: [Input] = []
    static var bufferQueue: [Input] = []
    static var gameState = AnyGameState(PlayState())
    /// Attempts to append the input given the current game state
    /// However the game state is a FSM and cannot accept input at different points
    /// An example, if we are animating a rotation and the user hits rotate right, we
    /// ignore that input because we cannot animate two things at a time
    static func append(_ input: Input, given: AnyGameState = gameState) {
        debugPrint(input)
        if gameState.shouldAppend(input) {
            queue.append(input)
            debugPrint("\(input) was appended")
        } else if gameState.shouldBuffer(input) && input.type.canBeNonUserGenerated {
            bufferQueue.append(input)
            debugPrint("\(input) was appended to bufferQueue")
        } else {
            debugPrint("\(input) was NOT appended b/c the game state is \(gameState.state)")
        }
    }
    
    static func pop() -> Input? {
        guard let input = InputQueue.peek(),
            let transition = InputQueue.gameState.transitionState(given: input) else {
            return nil
        }
        queue = Array(queue.dropFirst())
        gameState = transition
        
        debugPrint("\(input) was popped")
        if input.type == .animationsFinished {
            queue.append(contentsOf: bufferQueue)
            bufferQueue.removeAll(keepingCapacity: true)
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
        output += "\nCurrent buffer \(bufferQueue)"
        return output
    }
}

protocol Resets {
    static var queue: [Input] { get set }
    static var bufferQueue: [Input] { get set }
    static var gameState: AnyGameState { get set }
    static func reset(to startingGameState: AnyGameState)
}

extension InputQueue: Resets {
    static func reset(to startingGameState: AnyGameState = AnyGameState(PlayState())) {
        queue = []
        bufferQueue = []
        gameState = startingGameState
    }
}


