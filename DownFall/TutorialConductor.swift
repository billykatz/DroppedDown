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
    
    private var turnsSinceToldToRotateButHasNotYetRotated = 0
    private var showedYouCanRotateAgain = false
    
    
    var isTutorial: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaults.hasCompletedTutorialKey) && !UserDefaults.standard.bool(forKey: UserDefaults.hasSkippedTutorialKey)
    }
    
    var shouldShowLevelGoalsAtStart: Bool {
        if isTutorial { return false }
        else if FTUEConductor().shouldShowCompletedTutorial { return false }
        else if !self.phase.shouldInputLevelGoalView { return false }
        return true
    }
    
    
    init() {
        self.phase = .thisIsYou
        
        if !isTutorial {
            // just set this to a phase that allows the level goal detail view to be inputted
            self.phase = .levelGoalRewards
        }
    }
    
    func startHandlingInput() {
        Dispatch.shared.register { [weak self] input in
            self?.handle(input)
        }
    }
    
    private func handle(_ input: Input) {
        if isTutorial {
            handleTutorialInput(input)
        } else {
            handleFTUEInput(input)
        }
    }
    
    var ftueLevelGoalRewardedWaitATurn = false
    var ftueCollectedItemDontShowMiningGem = false
    
    var shouldSendRuneOfferPhase: TutorialPhase? = nil
    var shouldSendMiningGemsPhase: TutorialPhase? = nil
    var shouldSendRuneChargedFirstTime: TutorialPhase? = nil
    
    func handleFTUEInput(_ input: Input) {
        switch input.type {
        case .boardBuilt:
            if let dialog = FTUEConductor().dialogForCompletingTheTutorial() {
                InputQueue.append(.init(.tutorialPhaseStart(dialog)))
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenCompletedTutorialKey)
            }
            
            // reset these flags just in case they got set at the end of the level
            shouldSendRuneOfferPhase = nil
            shouldSendMiningGemsPhase = nil
            
        case .boardLoaded:
            // reset these flags just in case they got set at the end of the level
            shouldSendRuneOfferPhase = nil
            shouldSendMiningGemsPhase = nil
            
        case .goalCompleted:
            ftueLevelGoalRewardedWaitATurn = true
            
        case .collectItem:
            ftueCollectedItemDontShowMiningGem = true
            
        case .transformation(let trans):
            if let first = trans.first,
               let offers = first.offers,
               case .goalCompleted = first.inputType,
               let runeOffer = offers.first(where: { $0.rune != nil }),
               let phase = FTUEConductor().phaseForEncounteringFirstRune(runeOffer) {
                shouldSendRuneOfferPhase = phase
            }
            
            if let first = trans.first,
               first.removedTilesContainGem ?? false,
               case .touch = first.inputType,
               let endTiles = first.endTiles {
                let gemTile = endTiles
                    .joined() // flatten 2d array
                    .first(where: // find the first gem offer on the board
                        {
                            if case TileType.item = $0.type {
                                return true
                            }
                            return false
                        })
                if let gemTileType = gemTile?.type, let phase = FTUEConductor().phaseForMiningGems(gemTileType){
                    shouldSendMiningGemsPhase = phase
                }
                
            }
            
            if FTUEConductor().shouldShowRuneChargedForTheFirstTime,
                let endTiles = trans.first?.endTiles {
                if let playerData = playerData(in: endTiles),
                   let runes = playerData.runes,
                   let phase = FTUEConductor().phaseForFirstRuneCharge(runes: runes) {
                    shouldSendRuneChargedFirstTime = phase
                }

            }
            
        case .newTurn:
            if let phase = shouldSendRuneOfferPhase {
                shouldSendRuneOfferPhase = nil
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenFirstRuneFTUEKey)
            } else if let phase = shouldSendMiningGemsPhase {
                // basically we want to show this tip as soon as possible
                // So if it every coincides with level goals being rewarded, then just skip it by setting the phase to nil
                if ftueLevelGoalRewardedWaitATurn || ftueCollectedItemDontShowMiningGem {
                    ftueLevelGoalRewardedWaitATurn = false
                    ftueCollectedItemDontShowMiningGem = false
                    shouldSendMiningGemsPhase = nil
                } else {
                    InputQueue.append(.init(.tutorialPhaseStart(phase)))
                    shouldSendMiningGemsPhase = nil
                    UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenMinedFirstGemFTUEKey)
                }
            }
            else if let phase = shouldSendRuneChargedFirstTime {
                InputQueue.append(.init(.tutorialPhaseStart(phase)))
                shouldSendRuneChargedFirstTime = nil
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSeenRuneChargedForTheFirstTimeFTUEKey)
            }
            
            // reset flags that we use to push off the FTUE in case they coincide with other events 
            else if ftueLevelGoalRewardedWaitATurn || ftueCollectedItemDontShowMiningGem {
                ftueLevelGoalRewardedWaitATurn = false
                ftueCollectedItemDontShowMiningGem = false
            }
            
            
        default:
            ()
        }
    }
    
    func handleTutorialInput(_ input: Input) {
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
            
            if showedRotateTutorialAlready {
                turnsSinceToldToRotateButHasNotYetRotated += 1
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
            
            if turnsSinceToldToRotateButHasNotYetRotated >= 8 && !showedYouCanRotateAgain {
                showedYouCanRotateAgain = true
                self.phase = .youCanRotateAgain
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
        } else if oldPhase == .youCanRotate || oldPhase == .levelGoalRewards || oldPhase == .youCanRotateAgain {
            self.phase = .yikesAMonster
        } else if oldPhase == .yikesAMonster {
            self.phase = .killAMonster
        }
    }
    
    
    func setTutorialSkipped() {
        if isTutorial {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasSkippedTutorialKey)
            UserDefaults.standard.setValue(false, forKey: UserDefaults.shouldShowCompletedTutorialKey)
        }
    }
    
    func setTutorialCompleted(playerDied: Bool) {
        // only set these values once
        if isTutorial {
            UserDefaults.standard.setValue(true, forKey: UserDefaults.hasCompletedTutorialKey)
            
            if playerDied {
                UserDefaults.standard.setValue(true, forKey: UserDefaults.hasDiedDuringTutorialKey)
            } else {
                UserDefaults.standard.setValue(true, forKey: UserDefaults.shouldShowCompletedTutorialKey)
                
                if let phase = FTUEConductor().dialogForCompletingTheTutorial() {
                    self.phase = phase
                }
            }
        }
    }
}
