//
//  Input.swift
//  DownFall
//
//  Created by William Katz on 8/27/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

indirect enum InputType : Equatable, Hashable, CaseIterable, CustomDebugStringConvertible {
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
