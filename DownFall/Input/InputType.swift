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
                                        .playAgain(didWin: false),
                                        .reffingFinished(newTurn: false),
                                        .collectItem(TileCoord(0,0), .zero, 0),
                                        .collectOffer(collectedCoord: .zero, collectedOffer: .zero, discardedCoord: .zero, discardedOffer: .zero),
                                        .runeUseCanceled,
                                        .runeUseSelected(.zero),
                                        .runeUsed(.zero, .init(targets: [], areLegal: false)),
                                        .decrementDynamites(Set<TileCoord>()),
                                        .rotatePreview([], .zero),
                                        .rotatePreviewFinish([], nil),
                                        .refillEmpty,
                                        .tileDetail(.exit(blocked: false), []),
                                        .boardBuilt,
                                        .unlockExit,
                                        .levelGoalDetail([]),
                                        .goalCompleted([], allGoalsCompleted: false),
                                        .runeReplacement(Pickaxe(runeSlots: 0, runes: []), .zero, promptedByChest: false),
                                        .runeReplaced(Pickaxe(runeSlots: 0, runes: []), replacedRune: .zero,  newRune: .zero, promptedByChest: false),
                                        .bossTurnStart(BossPhase()),
                                        .bossPhaseStart(BossPhase()),
                                        .noMoreMoves,
                                        .collectChestOffer(offer: .zero)
                                                                 
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
    case playAgain(didWin: Bool)
    case transformation([Transformation])
    case reffingFinished(newTurn: Bool)
    case boardBuilt
    case boardLoaded
    
    case collectItem(TileCoord, Item, Int)
    case collectOffer(collectedCoord: TileCoord, collectedOffer: StoreOffer, discardedCoord: TileCoord, discardedOffer: StoreOffer)
    case collectChestOffer(offer: StoreOffer)
    
    case selectLevel
    case newTurn
    case visitStore
    
    /// Rune Use and Targeting inputs
    case runeUseSelected(Rune)
    case runeUseCanceled
    case runeUsed(Rune, AllTarget)
    
    case decrementDynamites(Set<TileCoord>)
    case rotatePreview([[DFTileSpriteNode]], Transformation)
    case rotatePreviewFinish([SpriteAction], Transformation?)
    case refillEmpty
    case tileDetail(TileType, [TileCoord])
    case unlockExit
    case levelGoalDetail([GoalTracking])
    case goalCompleted([GoalTracking], allGoalsCompleted: Bool)
    case runeReplacement(Pickaxe, Rune, promptedByChest: Bool)
    case runeReplaced(Pickaxe, replacedRune: Rune, newRune: Rune, promptedByChest: Bool)
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
            if let firstInputType = trans.first?.inputType {
                return "transformation \(String(describing: firstInputType))"
            } else {
                return "transformation"
            }
        case .touch:
            return "Touch"
        case .rotateCounterClockwise:
            return "rotateCounterClockwise"
        case .rotateClockwise:
            return "rotateClockwise"
        case .monsterDies:
            return "monsterDies"
        case .gameWin:
            return "gameWin"
        case .gameLose:
            return "gameLose"
        case .play:
            return "play"
        case .pause:
            return "pause"
        case .animationsFinished:
            return "animationsFinished"
        case .playAgain:
            return "playAgain"
        case .reffingFinished(let newTurn):
            return "reffingFinished. newTurn? \(newTurn)"
        case .attack(_, let attacker, let defender, _, _, _):
            return "attack. Attacked from \(attacker) to \(String(describing: defender))"
        case .boardBuilt:
            return "boardBuilt"
        case .boardLoaded:
            return "boardLoaded"
        
        case .collectItem:
            return "collectItem"
        case .collectChestOffer:
            return "collectChestOffer"
            
        case .selectLevel:
            return "selectLevel"
        case .newTurn:
            return "newTurn"
        case .touchBegan:
            return "touchBegan"
        case .visitStore:
            return "visitStore"
        case .runeUseCanceled:
            return "runeUseCanceled"
        case .runeUseSelected:
            return "runeUseSelected"
        case .runeUsed(let ability, let targets):
            return "\(ability.textureName) used on targets \(targets.allTargetCoords)"
        case .decrementDynamites:
            return "decrementDynamites"
        case .rotatePreview:
            return "rotatePreview"
        case .rotatePreviewFinish:
            return "rotatePreviewFinish"
        case .refillEmpty:
            return "refillEmpty"
        case .tileDetail:
            return "tileDetail"
        case .unlockExit:
            return "unlockExit"
        case .levelGoalDetail:
            return "levelGoalDetail"
        case .goalCompleted:
            return "goalCompleted"
        case .collectOffer(_, let offer, _, _):
            return "collectOffer. offer: \(offer.textureName)"
        case .runeReplacement(_, _, let promptedByChest):
            return "runeReplacement. promptedByChest? \(promptedByChest)"
        case .runeReplaced:
            return "runeReplaced"
        case .foundRuneDiscarded:
            return "foundRuneDiscarded"
        case .loseAndGoToStore:
            return "loseAndGoToStore"
            
        // tutorial stuff
        case .tutorialPhaseStart:
            return "tutorialPhaseStart"
        case .tutorialPhaseEnd:
            return "tutorialPhaseEnd"
            
        // boss stuff
        case .bossTurnStart(let phase):
            return "bossTurnStart. Phase: \(phase.bossPhaseType.rawValue). State: \(String.init(describing: phase.bossState.stateType))"
        case .bossPhaseStart(let phase):
            return "bossPhaseStart. Phase: \(phase.bossPhaseType.rawValue). State: \(String.init(describing: phase.bossState.stateType))"
            
        // no more moves
        case .noMoreMoves:
            return "noMoreMoves"
            
        case  .noMoreMovesConfirm(let payTwoHearts, let pay25Percent):
            return "noMoreMovesConfirm. Pay 2 hearts? \(payTwoHearts). Pay 25%? \(pay25Percent)."
            
            
        }
    }
}
