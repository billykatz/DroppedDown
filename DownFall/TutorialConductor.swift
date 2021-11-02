//
//  TutorialConductor.swift
//  DownFall
//
//  Created by Billy on 10/14/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


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
    
    
    var isTutorial: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaults.hasCompletedTutorialKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSkippedTutorialKey)
    }
    
    
    init() {
        self.phase = .thisIsYou
    }
    
    func startHandlingInput() {
        Dispatch.shared.register { [weak self] input in
            self?.handle(input)
        }
    }
    
    private func handle(_ input: Input) {
        if isTutorial {
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
                guard !allGoalsJustCompletedHoldOffOnTutorialForATurn else {
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
        }
    }
    
    
    func setTutorialSkipped() {
        if isTutorial {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSkippedTutorialKey)
        }
    }
    
    func setTutorialCompleted(playerDied: Bool) {
        // only set these values once
        if isTutorial {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasCompletedTutorialKey)
            
            if playerDied {
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasDiedDuringTutorialKey)
            }
        }
    }
}
