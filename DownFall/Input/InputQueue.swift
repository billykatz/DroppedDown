//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

indirect enum InputType : Equatable, Hashable, CaseIterable, CustomDebugStringConvertible{
    static var allCases: [InputType] = [.touchBegan(TileCoord(0,0), .blueRock),
                                        .touch(TileCoord(0,0), .blueRock),
                                        .rotateLeft,
                                        .rotateRight,
                                        .attack(attackType: .targets,
                                                attacker: TileCoord(0,0),
                                                defender: TileCoord(0,0),
                                                affectedTiles: []),
                                        .monsterDies(TileCoord(0,0)),
                                        .gameWin,
                                        .gameLose(""),
                                        .play,
                                        .pause,
                                        .animationsFinished(ref: true),
                                        .playAgain,
                                        .reffingFinished(newTurn: false),
                                        .collectItem(TileCoord(0,0), .zero)]
    
    typealias AllCases = [InputType]
    
    case touchBegan(_ position: TileCoord, _ tileType: TileType)
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateLeft
    case rotateRight
    case monsterDies(TileCoord)
    case attack(attackType: AttackType, attacker: TileCoord, defender: TileCoord?, affectedTiles: [TileCoord])
    case gameWin
    case gameLose(String)
    case play
    case pause
    case animationsFinished(ref: Bool)
    case playAgain
    case transformation(Transformation)
    case reffingFinished(newTurn: Bool)
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
        case .attack(_, let attacker, let defender, _):
            return "Attacked from \(attacker) to \(String(describing: defender))"
        case .boardBuilt:
            return "Board has been built"
        case .collectItem:
            return "Player collects an item"
        case .selectLevel:
            return "Select Level"
        case .newTurn:
            return "New Turn"
        case .touchBegan:
            return "Touch began"
        }
    }
}

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
                history.insert(input, at: history.startIndex)
//                print("________________________")
//                print(input.type.debugDescription)
//                print(gameState.state)
//                print("________________________")
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


