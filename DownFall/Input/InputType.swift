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
    
    // leaving out tutorial cases from here
    static var allCases: [InputType] = [.touchBegan(TileCoord(0,0), .rock(color: .red, holdsGem: false, groupCount: 0)),
                                        .touch(TileCoord(0,0), .rock(color: .red, holdsGem: false, groupCount: 0)),
                                        .rotateCounterClockwise(preview: false),
                                        .rotateClockwise(preview: false),
                                        .attack(attackType: .targets,
                                                attacker: TileCoord(0,0),
                                                defender: TileCoord(0,0),
                                                affectedTiles: [],
                                                dodged: false,
                                                attackerIsPlayer: false
                                        ),
                                        .monsterDies(TileCoord(0,0), .wizard, deathType: .player),
                                        .gameWin(0),
                                        .gameLose(killedBy: .alamo),
                                        .play,
                                        .pause,
                                        .animationsFinished(ref: true),
                                        .playAgain,
                                        .reffingFinished(newTurn: false),
                                        .collectItem(TileCoord(0,0), .zero, 0),
                                        .collectOffer(collectedCoord: .zero, collectedOffer: .zero, discardedCoord: .zero, discardedOffer: .zero),
                                        .itemUseCanceled,
                                        .itemUseSelected(.zero),
                                        .itemCanBeUsed(false),
                                        .itemUsed(.zero, .init(targets: [], areLegal: false)),
                                        .decrementDynamites(Set<TileCoord>()),
                                        .rotatePreview([], .zero),
                                        .rotatePreviewFinish([], nil),
                                        .refillEmpty,
                                        .tileDetail(.exit(blocked: false), []),
                                        .boardBuilt,
                                        .unlockExit,
                                        .levelGoalDetail([]),
                                        .goalCompleted([], allGoalsCompleted: false),
                                        .runeReplacement(Pickaxe(runeSlots: 0, runes: []), .zero),
                                        .runeReplaced(Pickaxe(runeSlots: 0, runes: []), .zero),
                                        .bossTurnStart(BossPhase()),
                                        .bossPhaseStart(BossPhase()),
                                        .noMoreMoves,
                                                                 
    ]
    
    typealias AllCases = [InputType]
    
    case touchBegan(_ position: TileCoord, _ tileType: TileType)
    case touch(_ position: TileCoord, _ tileType: TileType)
    case rotateCounterClockwise(preview: Bool)
    case rotateClockwise(preview: Bool)
    case monsterDies(TileCoord, EntityModel.EntityType, deathType: MonsterDeathType)
    case attack(attackType: AttackType, attacker: TileCoord, defender: TileCoord?, affectedTiles: [TileCoord], dodged: Bool, attackerIsPlayer: Bool)
    case gameWin(_ goalsCompleted: Int)
    case gameLose(killedBy: EntityModel.EntityType?)
    case play
    case pause
    case animationsFinished(ref: Bool)
    case playAgain
    case transformation([Transformation])
    case reffingFinished(newTurn: Bool)
    case boardBuilt
    case boardLoaded
    case collectItem(TileCoord, Item, Int)
    case collectOffer(collectedCoord: TileCoord, collectedOffer: StoreOffer, discardedCoord: TileCoord, discardedOffer: StoreOffer)
    case selectLevel
    case newTurn
    case visitStore
    case itemUseSelected(Rune)
    case itemUseCanceled
    case itemCanBeUsed(Bool)
    case itemUsed(Rune, AllTarget)
    case decrementDynamites(Set<TileCoord>)
    case rotatePreview([[DFTileSpriteNode]], Transformation)
    case rotatePreviewFinish([SpriteAction], Transformation?)
    case refillEmpty
    case tileDetail(TileType, [TileCoord])
    case unlockExit
    case levelGoalDetail([GoalTracking])
    case goalCompleted([GoalTracking], allGoalsCompleted: Bool)
    case runeReplacement(Pickaxe, Rune)
    case runeReplaced(Pickaxe, Rune)
    case foundRuneDiscarded(Rune)
    case loseAndGoToStore
    
    // tutorial ish
    case tutorialPhaseStart(TutorialPhase)
    case tutorialPhaseEnd(TutorialPhase)
    
    // boss input
    case bossTurnStart(BossPhase)
    case bossPhaseStart(BossPhase)
    
    // no more moves
    case noMoreMoves
    case noMoreMovesConfirm(payTwoHearts: Bool, pay25Percent: Bool)
    
    var debugDescription: String {
        switch self {
        case .transformation(let trans):
            return "Transformation \(String(describing: trans.first?.inputType))"
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
        case .attack(_, let attacker, let defender, _, _, _):
            return "Attacked from \(attacker) to \(String(describing: defender))"
        case .boardBuilt:
            return "Board has been built"
        case .boardLoaded:
            return "Board has been loaded"
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
            return "\(ability.textureName) used on targets \(targets.allTargetCoords)"
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
        case .unlockExit:
            return "Unlock Exit"
        case .levelGoalDetail:
            return "Level Goal Detail"
        case .goalCompleted:
            return "Goal was completed"
        case .collectOffer(_, let offer, _, _):
            return "Player collects \(offer.textureName)"
        case .runeReplacement(_, _):
            return "Rune Replacement flow"
        case .runeReplaced:
            return "Rune replaced"
        case .foundRuneDiscarded:
            return "Found rune discarded"
        case .loseAndGoToStore:
            return "Lose and go to store"
            
        // tutorial stuff
        case .tutorialPhaseStart:
            return "Tutorial - phase start"
        case .tutorialPhaseEnd:
            return "Tutorial - phase end"
            
        // boss stuff
        case .bossTurnStart(let phase):
            return "Boss Turn Start. Phase: \(phase.bossPhaseType.rawValue). State: \(phase.bossState.stateType.rawValue)"
        case .bossPhaseStart(let phase):
            return "Boss Phase Start. Phase: \(phase.bossPhaseType.rawValue). State: \(phase.bossState.stateType.rawValue)"
            
        // no more moves
        case .noMoreMoves:
            return "No more moves"
            
        case  .noMoreMovesConfirm(let payTwoHearts, let pay25Percent):
            return "No more move confirmation. Pay 2 hearts? \(payTwoHearts). Pay 25%? \(pay25Percent)."
            
            
        }
    }
}
