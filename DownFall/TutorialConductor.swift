//
//  TutorialConductor.swift
//  DownFall
//
//  Created by Billy on 10/14/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


///
/// Tutorial Conductor is a class that is meant to coordinate and conduct the tutorial
///  - shouldShowHud
///  - shouldShowLevelGoals
///  - shouldShowLevelDetailView
///  - shouldShowTileDetailView
///  - shouldShow
///
///  - shouldInputLevelGoalView
///  - shouldSpawnMonsters
///  - shouldSpawnTileWithGem
///  -
///
///

enum Character: String, Codable {
    case teri
    
    var textureName: String {
        return "\(rawValue)-character"
    }
    
    var humanReadable: String {
        switch self {
        case .teri:
            return "Teri"
        }
    }
}

struct Dialogue: Hashable, Codable {
    let sentences: [String]
    let character: Character
    let delayBeforeTyping: Double
}

extension Dialogue {
    static let thisIsYou: Dialogue = .init(sentences: ["Hey! I'm Teri. This is you. We're in level 1 of the mines."], character: .teri, delayBeforeTyping: 1.25)
    static let thisIsTheExit: Dialogue = .init(sentences: ["This is the exit to get to the next level.",
                                                           "BUT it's blocked. You'll have to complete the level goals to get all those rocks out of the way."],
                                               character: .teri,
                                               delayBeforeTyping: 0.25)
    static let theseAreLevelGoals: Dialogue = .init(sentences: ["The level goals will show up at the start of each level."], character: .teri, delayBeforeTyping: 0.25)
    static let theseAreLevelGoalsInHUD: Dialogue = .init(sentences: ["You can also find them by tapping up here in your HUD."], character: .teri, delayBeforeTyping: 0.25)
    static let okayReadyToMineSomeRocks: Dialogue = .init(sentences:
                                                            [
                                                                "Okay, ready to mine some rocks? Wait, you're a miner and you've never mined rocks? Fine.",
                                                                "Try mining some rocks by tapping any group of 3 or more adjacent rocks of the same color."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let youCanRotate: Dialogue = .init(sentences:
                                                            [
                                                                "You saw how things move down from the top when you mine?",
                                                                "You can also rotate the level by dragging it to affect how the board shifts.",
                                                                "Try getting to the gem you just uncovered."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yikesAMonster: Dialogue = .init(sentences:
                                                            [
                                                                "Look out! That's a monster.",
                                                                "The red dot means it's dormant, but once the dot turns green, it can attack you.",
                                                                "Tap on it to see how it attacks."
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let killAMonster: Dialogue = .init(sentences:
                                                            [
                                                                "Try landing on TOP of this monster to kill it",
                                                            ],
                                                          character: .teri,
                                                          delayBeforeTyping: 0.25)
    
    static let yayMonsterDead1GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    "Phew! You did it.",
                                                    "You still need to mine a few more rocks to unlock the exit."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let yayMonsterDead2GoalCompleted: Dialogue = .init(sentences:
                                                [
                                                    "Phew! You did it.",
                                                    "I think you should get to the exit before more monsters show up.",
                                                    "Remember, the village is just past the Crystal River!"
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let levelGoalRewards: Dialogue = .init(sentences:
                                                [
                                                    "The exit is now unblocked AND you have a choice between two awesome items!",
                                                    "When you pick one up the other diasppears.",
                                                    "No one knows what happens to the other item, some say the Mineral Spirits feed off it."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)
    
    static let youCanLeaveNow: Dialogue = .init(sentences:
                                                [
                                                    "Once the exit unlocks monsters start to appear more frequently",
                                                    "I'd get out of there if I was you."
                                                ],
                                              character: .teri,
                                              delayBeforeTyping: 0.25)



    
}

struct TutorialPhase: Hashable, Codable {
    let shouldShowHud: Bool
    let shouldShowLevelGoals: Bool
    let shouldShowLevelGoalDetailView: Bool
    let shouldShowTileDetailView: Bool
    let shouldInputLevelGoalView: Bool
    let shouldSpawnMonsters: Bool
    let shouldSpawnTileWithGem: Bool
    
    let dialogue: Dialogue
    
    let highlightTileType: [TileType]?
    
    let waitDuration: Double
    let fadeInDuration: Double
    
    let shouldDimScreen: Bool
    let shouldHighlightLevelGoalsInHUD: Bool
    
}

extension TutorialPhase {
    
    static let thisIsYou: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: false, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .thisIsYou, highlightTileType: [.player(.zero)], waitDuration: 1.0, fadeInDuration: 0.5, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)
    
    static let thisIsTheExit: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: false, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .thisIsTheExit, highlightTileType: [.exit(blocked: true)], waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)
    
    
    static let theseAreLevelGoals: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: false, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .theseAreLevelGoals, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false)
    
    static let theseAreLevelGoalsInTheHud: TutorialPhase = .init(shouldShowHud: false, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: false, shouldShowTileDetailView: false, shouldInputLevelGoalView: false, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .theseAreLevelGoalsInHUD, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: true)
    
    static let okayReadyToMineSomeRocks: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .okayReadyToMineSomeRocks, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false)
    
    static let youCanRotate: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: true, shouldSpawnTileWithGem: false, dialogue: .youCanRotate, highlightTileType: nil, waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false)
    
    static let yikesAMonster: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yikesAMonster, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)
    
    static let killAMonster: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .killAMonster, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.25, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)
    
    static let yayMonsterDead1GoalCompleted: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yayMonsterDead1GoalCompleted, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false)
    
    static let yayMonsterDead2GoalCompleted: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .yayMonsterDead2GoalCompleted, highlightTileType: [.monster(.zero)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: false, shouldHighlightLevelGoalsInHUD: false)

    
    static let levelGoalRewards: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .levelGoalRewards, highlightTileType: [.offer(StoreOffer.offer(type: .dodge(amount: 5), tier: 1)), .offer(StoreOffer.offer(type: .luck(amount: 5), tier: 1))], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)
    
    static let youCanLeaveNow: TutorialPhase = .init(shouldShowHud: true, shouldShowLevelGoals: true, shouldShowLevelGoalDetailView: true, shouldShowTileDetailView: true, shouldInputLevelGoalView: true, shouldSpawnMonsters: false, shouldSpawnTileWithGem: false, dialogue: .youCanLeaveNow, highlightTileType: [.exit(blocked: false)], waitDuration: 0, fadeInDuration: 0.0, shouldDimScreen: true, shouldHighlightLevelGoalsInHUD: false)


    
}

class TutorialConductor {
    
    private(set) var phase: TutorialPhase
    private var minedRocksForFirstTime = false
    private var showedRotateTutorialAlready = false
    
    private var collectedItemsForFirstTime = false
    private var showedCollectedItemsTutorialAlready = false
    
    private var turnsSinceMonsterAppeared = 0
    private var tappedOnMonsterForFirstTime = false
    private var showedHowToKillAMonsterAlready = false
    
    private var monsterKilled = false
    private var showMonsterKilledAlready = false
    
    
    private var levelGoalsAwarded = false
    private var showedLevelGoalsTutorialAlready = false
    
    private var turnsSinceExitUnlocked = 0
    private var showedYouCanLeaveNowAlready = false
    
    private var allGoalsJustCompletedHoldOffOnTutorialForATurn = false
    
    init() {
        self.phase = .thisIsYou
        
        Dispatch.shared.register { [weak self] input in
            self?.handle(input)
        }
    }
    
    private func handle(_ input: Input) {
        switch input.type {
        case .boardBuilt:
            InputQueue.append(.init(.tutorialPhaseStart(.thisIsYou)))
        case .tutorialPhaseEnd(let phase):
            transitionToPhase(from: phase)
            
        case .transformation(let trans):
            guard let tran = trans.first,
                  case InputType.touch? = tran.inputType,
                  tran.newTiles != nil else {
                return
            }
            minedRocksForFirstTime = true
        case .collectItem, .collectOffer:
            collectedItemsForFirstTime = true
            
        case .tileDetail(let type, _):
            if type == .monster(.zero) && !tappedOnMonsterForFirstTime {
                tappedOnMonsterForFirstTime = true
            }
            
        case .monsterDies:
            monsterKilled = true
            
        case .play:
            if tappedOnMonsterForFirstTime && !showedHowToKillAMonsterAlready {
                showedHowToKillAMonsterAlready = true
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
        case .goalCompleted(_, let allRewarded):
            if allRewarded {
                levelGoalsAwarded = true
                allGoalsJustCompletedHoldOffOnTutorialForATurn = true
            }
            
        case .newTurn:
            /// when goals are rewarded, but the countdown for showing how to kill a monster is gonna go off, we need to tell it wait a turn so the LevelGoalTracker can use the InputQueue.  Hackyyy i know.
            guard !allGoalsJustCompletedHoldOffOnTutorialForATurn || showedHowToKillAMonsterAlready else {
                allGoalsJustCompletedHoldOffOnTutorialForATurn = false
                return
            }
            
            if minedRocksForFirstTime && !showedRotateTutorialAlready {
                showedRotateTutorialAlready = true
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
            if collectedItemsForFirstTime && !showedCollectedItemsTutorialAlready {
                showedCollectedItemsTutorialAlready = true
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
            
            // the monster has appeared
            if collectedItemsForFirstTime {
                turnsSinceMonsterAppeared += 1
            }
            
            if monsterKilled && !showMonsterKilledAlready {
                showMonsterKilledAlready = true
                showedHowToKillAMonsterAlready = true
                
                self.phase = levelGoalsAwarded ? .yayMonsterDead2GoalCompleted : .yayMonsterDead1GoalCompleted
                
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
            // you still havent killed a monster but you completed a level goal
            if levelGoalsAwarded && !showedLevelGoalsTutorialAlready {
                
                // we want to reset this timer so they still have a chance to do this naturally
                turnsSinceMonsterAppeared = 0
                showedLevelGoalsTutorialAlready = true
                self.phase = .levelGoalRewards
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
                
            // progress the tutorial in case they forget the goal
            if turnsSinceMonsterAppeared >= 8 && !showedHowToKillAMonsterAlready {
                showedHowToKillAMonsterAlready = true
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
            
            if levelGoalsAwarded {
                turnsSinceExitUnlocked += 1
            }
            
            if turnsSinceExitUnlocked >= 20 && !showedYouCanLeaveNowAlready {
                showedYouCanLeaveNowAlready = true
                self.phase = .youCanLeaveNow
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
            }
            
            
        default:
            break;
        }
    }
    
    func transitionToPhase(from oldPhase: TutorialPhase) {
        if oldPhase == .thisIsYou {
            // update the phase
            self.phase = .thisIsTheExit
            
            // send it to the queue
            InputQueue.append(.init(.tutorialPhaseStart(phase)))
        } else if oldPhase == .thisIsTheExit {
            self.phase = .theseAreLevelGoals
        } else if oldPhase == .theseAreLevelGoals {
            self.phase = .theseAreLevelGoalsInTheHud
            
            // send it to the queue
            InputQueue.append(.init(.tutorialPhaseStart(phase)))
        } else if oldPhase == .theseAreLevelGoalsInTheHud {
            self.phase = .okayReadyToMineSomeRocks
            
            InputQueue.append(.init(.tutorialPhaseStart(phase)))
        } else if oldPhase == .okayReadyToMineSomeRocks {
            self.phase = .youCanRotate
        } else if oldPhase == .youCanRotate || oldPhase == .levelGoalRewards {
            self.phase = .yikesAMonster
        } else if oldPhase == .yikesAMonster {
            self.phase = .killAMonster
        } else if oldPhase == .killAMonster {
        }
    }
    
}
