//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

indirect enum InputType : Equatable, Hashable, CaseIterable, CustomDebugStringConvertible{
    static var allCases: [InputType] = [.touch(TileCoord(0,0), .blueRock),
                                        .rotateLeft,
                                        .rotateRight,
                                        .attack(TileCoord(0,0), TileCoord(0,0)),
                                        .monsterDies(TileCoord(0,0)),
                                        .gameWin,
                                        .gameLose(""),
                                        .play,
                                        .pause,
                                        .animationsFinished,
                                        .playAgain,
                                        .reffingFinished,
                                        .collectItem(TileCoord(0,0), .zero)]
    
    typealias AllCases = [InputType]
    
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateLeft
    case rotateRight
    case monsterDies(TileCoord)
    case attack(_ from: TileCoord, _ to: TileCoord)
    case attackArea(tileCoords: [TileCoord])
    case gameWin
    case gameLose(String)
    case play
    case pause
    case animationsFinished
    case playAgain
    case transformation(Transformation)
    case reffingFinished
    case boardBuilt
    case collectItem(TileCoord, Item)
    case selectLevel
    case newTurn
    
    var debugDescription: String {
        switch self {
        case .transformation:
            return "Transformation"
        case .touch:
            return "Touch"
        case .rotateLeft:
            return "Rotate Left"
        case .rotateRight:
            return "Rotate Right"
        case .monsterDies:
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
        case .collectItem:
            return "Player collects an item"
        case .selectLevel:
            return "Select Level"
        case .newTurn:
            return "New Turn"
        case .attackArea:
            return "Area attack"
        }
    }
}

struct Input: Hashable, CustomDebugStringConvertible {
    let type: InputType
    let endTiles: [[TileType]]?

    init(_ type: InputType,
         _ endTiles: [[TileType]]? = []) {
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


