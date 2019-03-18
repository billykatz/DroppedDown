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
        switch gameState.state {
        case .animating:
            //temporal, these statements must go in this order
            if input.type == .animationsFinished {
                queue.append(input)
                debugPrint("\(input) was appended")
            } else if !input.userGenerated {
                bufferQueue.append(input)
                debugPrint("\(input) was appended to bufferQueue")
            }
            debugPrint("\(input) was NOT appended b/c the game state is .animating")
        case .paused:
            guard input.type == .play else {
                debugPrint("\(input) was NOT appended b/c the game state is .paused")
                return
            }
            queue.append(input)
            debugPrint("\(input) was appended")
        case .playing:
            queue.append(input)
            debugPrint("\(input) was appended")
        case .gameWin:
            if input.type == .playAgain {
                queue.append(input)
            } else {
                fatalError("Not everything is possibleeeeeee!!!")
            }
        case .gameLose:
            fatalError("haven't implemented")
        }

    }
    
    static func pop() -> Input? {
        guard let input = InputQueue.peek(), let transition = InputQueue.gameState.transitionState(given: input) else {
            queue = Array(queue.dropFirst())
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
    
    
//    static func shouldPop(_ input: Input, for gameState: GameState) -> Bool {
//        switch gameState.state {
//        case .playing:
//            return true
//        case .animating:
//            if input.type == .animationsFinished {
//                return true
//            } else if !input.userGenerated {
//                return true
//            }
//            return false
//        case .paused:
//            return input.type == .play
//        case .gameWin:
//            return input.type == .playAgain
//        case .gameLose:
//            return input.type == .playAgain
//
//        }
//    }

    
//    static func gameState(given input: Input) -> GameState {
//        switch input.type {
//        case .gameLose, .monsterAttack, .monsterDies, .playerAttack, .touch, .rotateLeft, .rotateRight:
//            return .animating
//        case .pause:
//            return .paused
//        case .animationsFinished:
//            return .playing
//        case .play:
//           return .playing
//        case .gameWin:
//            return .gameWin
//        case .playAgain:
//            return .playing
//        }
//    }
}


