//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

indirect enum InputType : Equatable, Hashable, CaseIterable, CustomDebugStringConvertible{
    static var allCases: [InputType] = [.touch(TileCoord(0,0), .blueRock), .rotateLeft, .rotateRight,
                                        .attack(TileCoord(0,0), TileCoord(0,0)), .monsterDies(TileCoord(0,0)),
                                        .gameWin, .gameLose, .play, .pause,
                                        .animationsFinished, .playAgain, .reffingFinished]
    
    typealias AllCases = [InputType]
    
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateLeft
    case rotateRight
    case monsterDies(TileCoord)
    case attack(_ from: TileCoord, _ to: TileCoord)
    case gameWin
    case gameLose
    case play
    case pause
    case animationsFinished
    case playAgain
    case transformation(Transformation)
    case reffingFinished
    case boardBuilt
    case collectGem(TileCoord)
    
    var canBeNonUserGenerated: Bool {
        switch self {
            case .attack, .monsterDies,
                 .animationsFinished, .gameWin, .gameLose, .transformation:
            return true
        default:
            return false
        }
    }
    
    var debugDescription: String {
        switch self {
        case .transformation:
            return "Transformation"
        case .touch(_):
            return "Touch"
        case .rotateLeft:
            return "Rotate Left"
        case .rotateRight:
            return "Rotate Right"
        case .monsterDies(_):
            return "Monster Dies"
        case .gameWin:
            return "Game Win"
        case .gameLose:
            return "Game Lose"
        case .play:
            return "Play"
        case .pause:
            return "Pause"
        case .animationsFinished:
            return "Animations Finished"
        case .playAgain:
            return "Play Again"
        case .reffingFinished:
            return "Reffing Finished"
        case .attack(let from, let to):
            return "Attacked from \(from) to \(to)"
        case .boardBuilt:
            return "Board has been built"
        case .collectGem:
            return "Player collects gem"
        }
    }
}

struct Input: Hashable, CustomDebugStringConvertible {
    let type: InputType
    let endTiles: [[TileType]]?

    init(_ type: InputType, _ endTiles: [[TileType]]? = []) {
        self.type = type
        self.endTiles = endTiles
    }
    
    var debugDescription: String {
        return "{Input: \(type)}"
    }
}

struct InputQueue {
    static var queue: [Input] = []
    static var gameState = AnyGameState(PlayState())
    /// Attempts to append the input given the current game state
    /// However the game state is a FSM and cannot accept input at different points
    /// An example, if we are animating a rotation and the user hits rotate right, we
    /// ignore that input because we cannot animate two things at a time
    static func append(_ input: Input, given: AnyGameState = gameState) {
//        debugPrint("ATTEMP TO APPEND: \(input) and gameState: \(given.state)")
        
        let debugString : String
        if gameState.shouldAppend(input) {
            queue.append(input)
//            debugString = #"SUCCESS Appending: \#(input)"#
        } else {
//            debugString = #"FAIL to append: \#(input). \#n\#tCurrent Game State: \#(gameState.state)"#
        }
//        debugPrint(debugString)
    }
    
    static func pop() -> Input? {
        guard let input = InputQueue.peek(),
            let transition = InputQueue.gameState.transitionState(given: input) else {
                if !queue.isEmpty {
                    let input = InputQueue.peek()
                    if let input = input {
//                        debugPrint(#"ILLEGAL: \#(input) Current Game State: \#(gameState.state)"#)
                    } else {
//                        debugPrint(#"NOT SURE HOW WE ARE HERE"#)
                    }
                    queue.removeFirst()
                }
            return nil
        }
//        debugPrint(#"POPPING: \#(input) \#n\#tBefore: \#(gameState.state) \#n\#tAfter: \#(transition.state)"#)
        
        queue = Array(queue.dropFirst())
        let oldGameState = gameState
        gameState = transition
        
        if gameState.state != oldGameState.state {
            if let _ = NSClassFromString("XCTest") {
            } else {
                gameState.enter(input)
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


