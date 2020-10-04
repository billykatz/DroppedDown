//
//  InputType.swift
//  DownFall
//
//  Created by William Katz on 11/14/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import Foundation
import CoreGraphics

indirect enum InputType : Hashable, CaseIterable, CustomDebugStringConvertible{
    static func fuzzyEqual(_ lhs: InputType, _ rhs: InputType) -> Bool {
        if case InputType.touch(let lhsCoord, _) = lhs,
            case InputType.touch(let rhsCoord, _) = rhs {
            return lhsCoord == rhsCoord
        } else if case InputType.animationsFinished(let lhsRef) = lhs,
            case InputType.animationsFinished(let rhsRef) = rhs {
            return lhsRef == rhsRef
        } else if case InputType.collectItem(_, _, _) = lhs, case InputType.collectItem(_, _, _) = rhs {
            return true
        } else if case InputType.decrementDynamites(_) = lhs, case InputType.decrementDynamites(_) = rhs {
            return true
        } 
        return lhs == rhs
    }
    
    
    static var allCases: [InputType] = [.touchBegan(TileCoord(0,0), .rock(color: .red, holdsGem: false)),
                                        .touch(TileCoord(0,0), .rock(color: .red, holdsGem: false)),
                                        .rotateCounterClockwise(preview: false),
                                        .rotateClockwise(preview: false),
                                        .attack(attackType: .targets,
                                                attacker: TileCoord(0,0),
                                                defender: TileCoord(0,0),
                                                affectedTiles: [],
                                                dodged: false),
                                        .monsterDies(TileCoord(0,0), .wizard),
                                        .gameWin,
                                        .gameLose(""),
                                        .play,
                                        .pause,
                                        .animationsFinished(ref: true),
                                        .playAgain,
                                        .reffingFinished(newTurn: false),
                                        .collectItem(TileCoord(0,0), .zero, 0),
                                        .itemUseCanceled,
                                        .itemUseSelected(.zero),
                                        .itemCanBeUsed(false),
                                        .itemUsed(.zero, []),
                                        .decrementDynamites(Set<TileCoord>()),
                                        .rotatePreview([], .zero),
                                        .rotatePreviewFinish([], nil),
                                        .refillEmpty,
                                        .tileDetail(.exit(blocked: false), []),
                                        .boardBuilt,
                                        .unlockExit,
                                        .levelGoalDetail([]),
                                        .goalCompleted([])
                                                                 
    ]
    
    typealias AllCases = [InputType]
    
    case touchBegan(_ position: TileCoord, _ tileType: TileType)
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateCounterClockwise(preview: Bool)
    case rotateClockwise(preview: Bool)
    case monsterDies(TileCoord, EntityModel.EntityType)
    case attack(attackType: AttackType, attacker: TileCoord, defender: TileCoord?, affectedTiles: [TileCoord], dodged: Bool)
    case gameWin
    case gameLose(String)
    case play
    case pause
    case animationsFinished(ref: Bool)
    case playAgain
    case transformation([Transformation])
    case reffingFinished(newTurn: Bool)
    case boardBuilt
    case collectItem(TileCoord, Item, Int)
    case collectOffer(TileCoord, StoreOffer)
    case selectLevel
    case newTurn
    case visitStore
    case itemUseSelected(Rune)
    case itemUseCanceled
    case itemCanBeUsed(Bool)
    case itemUsed(Rune, [TileCoord])
    case decrementDynamites(Set<TileCoord>)
    case rotatePreview([[DFTileSpriteNode]], Transformation)
    case rotatePreviewFinish([SpriteAction], Transformation?)
    case refillEmpty
    case tileDetail(TileType, [TileCoord])
    case shuffleBoard
    case unlockExit
    case levelGoalDetail([GoalTracking])
    case goalCompleted([GoalTracking])
    
    var debugDescription: String {
        switch self {
        case .transformation:
            return "Transformation"
        case .touch:
            return "Touch"
        case .rotateCounterClockwise:
            return "Rotate Counter clockwise"
        case .rotateClockwise:
            return "Rotate clockwise"
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
        case .attack(_, let attacker, let defender, _, _):
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
        case .visitStore:
            return "Visiting store between levels"
        case .itemUseCanceled:
            return "Item use canceled"
        case .itemUseSelected:
            return "Item use selected"
        case .itemCanBeUsed(let used):
            return "item can be used: \(used)"
        case .itemUsed(let ability, let targets):
            return "\(ability.textureName) used on targets \(targets)"
        case .decrementDynamites:
            return "Decrement the dynamite fuses"
        case .rotatePreview:
            return "Rotate preview"
        case .rotatePreviewFinish:
            return "Rotate finish"
        case .refillEmpty:
            return "Refill empty tiles"
        case .tileDetail:
            return "Tile detail"
        case .shuffleBoard:
            return "Shuffle board"
        case .unlockExit:
            return "Unlock Exit"
        case .levelGoalDetail:
            return "Level Goal Detail"
        case .goalCompleted:
            return "Goal was completed"
        case .collectOffer(_, let offer):
            return "Player collects \(offer.textureName)"
            
        }
    }
}
