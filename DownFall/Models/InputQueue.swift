//
//  InputQueue.swift
//  DownFall
//
//  Created by William Katz on 12/5/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import SpriteKit

enum InputType : Equatable, Hashable {
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
}

struct Input {
    let type: InputType
    let userGenerated: Bool
    
    init(_ type: InputType, _ userGenerated: Bool) {
        self.type = type
        self.userGenerated = userGenerated
    }
    
    
}

enum GameState {
    case playing
    case paused
    case animating
}

struct InputQueue {
    static var queue: [Input] = []
    static var gameState: GameState = .playing
    
    @discardableResult static func append(_ input: Input) -> Bool {
        debugPrint(input)
        guard shouldAppend(input, for: InputQueue.gameState) else { return false }
        debugPrint("\(input) was appended")
        queue.append(input)
        return true
    }
    
    static func pop() -> Input? {
        guard let input = InputQueue.peek(),
            shouldPop(input, for: InputQueue.gameState) else { return nil }
        queue = Array(queue.dropFirst())
        InputQueue.gameState = gameState(given: input)
        debugPrint("\(input) was popped")
        return input
    }
    
    static func peek() -> Input? {
        guard !queue.isEmpty else { return nil }
        return queue.first
    }
    
    static func shouldAppend(_ input: Input, for gameState: GameState) -> Bool {
        switch gameState {
        case .playing:
            return true
        case .animating:
            if input.type == .animationsFinished {
                return true
            } else if !input.userGenerated {
                return true
            }
            return false
        case .paused:
            return input.type == .play
        }
    }
    
    static func shouldPop(_ input: Input, for gameState: GameState) -> Bool {
        switch gameState {
        case .playing:
            return true
        case .animating:
            if input.type == .animationsFinished {
                return true
            } else if !input.userGenerated {
                return true
            }
            return false
        case .paused:
            return input.type == .play
        }
    }

    
    static func gameState(given input: Input) -> GameState {
        switch input.type {
        case .gameLose, .gameWin, .monsterAttack, .monsterDies, .playerAttack, .touch, .rotateLeft, .rotateRight:
            return .animating
        case .pause:
            return .paused
        case .animationsFinished:
            //enforce rules unless they have already been enforced
            return .playing
        case .play:
           return .playing
        }
    }
}


