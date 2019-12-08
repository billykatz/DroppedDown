//
//  InputType.swift
//  DownFall
//
//  Created by William Katz on 11/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation

indirect enum InputType : Equatable, Hashable, CaseIterable, CustomDebugStringConvertible{
    static func fuzzyEqual(_ lhs: InputType, _ rhs: InputType) -> Bool {
        if case InputType.touch = lhs,
            case InputType.touch = rhs {
            return true
        }
        return lhs == rhs
    }
    
    
    static var allCases: [InputType] = [.touchBegan(TileCoord(0,0), .blueRock),
                                        .touch(TileCoord(0,0), .blueRock),
                                        .rotateCounterClockwise,
                                        .rotateClockwise,
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
                                        .collectItem(TileCoord(0,0), .zero),
                                        .tutorial(.zero)
    ]
    
    typealias AllCases = [InputType]
    
    case touchBegan(_ position: TileCoord, _ tileType: TileType)
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateCounterClockwise
    case rotateClockwise
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
    case tutorial(TutorialStep)
    case visitStore
    
    var debugDescription: String {
        switch self {
        case .transformation:
            return "Transformation"
        case .touch:
            return "Touch"
        case .rotateCounterClockwise:
            return "Rotate Left"
        case .rotateClockwise:
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
        case .tutorial(let dialog):
            return "Tutorial with \(dialog)"
        case .visitStore:
            return "Visiting store between levels"
        }
    }
}
