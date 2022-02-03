//
//  BossDialogController.swift
//  DownFall
//
//  Created by Billy on 2/2/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation
import SpriteKit

extension UserDefaults {
    
    /// mostly sequential
    // meets boss
    static let hasMetBossForFirstTimeKey = "hasMetBossForFirstTimeKey"
    
    // boss targets what to eat
    static let numberOfTimesBossHasEatenKey = "numberOfTimesBossHasEatenKey"
    static let hasSeenBossTargetWhatToEatKey = "hasSeenBossTargetWhatToEatKey"
    
    // boss targets what to attack
    static let numberOfTimesSeenDynamiteTargetKey = "numberOfTimesSeenDynamiteTargetKey"
    static let hasSeenBossTargetDynamiteKey = "hasSeenBossTargetDynamiteKey"
    
    static let numberOfTimesSeenPoisonTargetKey = "numberOfTimesSeenPoisonTargetKey"
    static let hasSeenBossTargetPoisonKey = "hasSeenBossTargetPoisonKey"
    
    static let numberOfTimesSeenSpawnMinionsTargetKey = "numberOfTimesSeenSpawnMinionsTargetKey"
    static let hasSeenBossGetReadyToSpawnMinionsKey = "hasSeenBossGetReadyToSpawnMinionsKey"
    
    // boss phase change
    static let hasSeenBossPhaseOneToTwoKey = "hasSeenBossPhaseOneToTwoKey"
    static let hasSeenBossPhaseTwoToThreeKey = "hasSeenBossPhaseTwoToThreeKey"
    
    // boss dead
    static let hasSeenBossDefeatedKey = "hasSeenBossDefeatedKey"
    
    /// non-sequential
    static let hasSeenPillarDestroyedKey = "hasSeenPillarDestroyedKey"
    
    static let numberOfTimesBossHasBeenGettingReadyToEatKey = "numberOfTimesBossHasBeenGettingReadyToEatKey"
    static let hasSeenBossIsGettingReadyToEatKey = "hasSeenBossIsGettingReadyToEatKey"
    
    static let hasSeenPlayerDiedKey = "hasSeenPlayerDiedToBossKey"
    
    static let bossKeys : [String] = [
        hasMetBossForFirstTimeKey,
        hasSeenBossTargetWhatToEatKey,
        hasSeenPillarDestroyedKey,
        hasSeenBossIsGettingReadyToEatKey,
        numberOfTimesBossHasBeenGettingReadyToEatKey,
        numberOfTimesBossHasEatenKey,
        numberOfTimesSeenDynamiteTargetKey,
        hasSeenBossTargetDynamiteKey,
        numberOfTimesSeenPoisonTargetKey,
        hasSeenBossTargetPoisonKey,
        numberOfTimesSeenSpawnMinionsTargetKey,
        hasSeenBossGetReadyToSpawnMinionsKey,
        hasSeenBossPhaseOneToTwoKey,
        
    ]
    
    func clearBossKeys() {
        for key in UserDefaults.bossKeys {
            UserDefaults.standard.set(false, forKey: key)
        }
    }
}

class BossDialogController {
    
    struct Constants {
        static let numberOfTimesBeforeShowingWhatToEatHint = 1
        static let numberOfTimesBeforeShowingAboutToEatAgainHint = 1
        static let numberOfTimesBeforeShowingDynamiteTargetHint = 2
        static let numberOfTimesBeforeShowingPoisonAttackHint = 2
        static let numberOfTimesBeforeShowingSpawnMinionsHint = 2
        
        static let bossDialogOverlayName = "bossDialogOverlayName"
    }
    
    let foreground: SKNode
    let playableRect: CGRect
    let userDefaults: UserDefaults
    let numPrevBossWins: Int
    var hasAlreadyShownHintAboutAttackTypeThisTurn = false
    
    init(foreground: SKNode, playableRect: CGRect, userDefaults: UserDefaults = .standard, numberOfPreviousBossWins: Int) {
        self.foreground = foreground
        self.playableRect = playableRect
        self.userDefaults = userDefaults
        self.numPrevBossWins = numberOfPreviousBossWins
//        
//        #if DEBUG
//        userDefaults.clearBossKeys()
//        #endif
        
        Dispatch.shared.register { [weak self] input in
            if case InputType.bossTurnStart(let phase) = input.type {
                self?.handleBossTurnStart(phase)
            } else if case InputType.bossPhaseStart(let phase) = input.type {
                self?.handleBossPhaseStart(phase)
            } else if input.type == .boardBuilt || input.type == .boardBuilt  {
                self?.handleFirstTurn()
            } else if case InputType.transformation(let trans) = input.type {
                guard let first = trans.first else { return }
                if first.pillarsTakeDamage != nil {
                    self?.handlePillarsTakeDamage()
                }
            } else if case InputType.gameWin = input.type {
                self?.handleGameWin()
            }
        }
    }
    
    func checkAndSetKey(_ key: String, setToTrue: Bool = true) -> Bool {
        let value = userDefaults.bool(forKey: key)
        if !value && setToTrue {
            userDefaults.set(true, forKey: key)
        }
        return value
    }
    
    func handlePillarsTakeDamage() {
        if !checkAndSetKey(UserDefaults.hasSeenPillarDestroyedKey) {
            showDialog(Dialogue.bossPlayerDestroysFirstPillar)
        }
    }
    
    func handleFirstTurn() {
        /// First message
        if !checkAndSetKey(UserDefaults.hasMetBossForFirstTimeKey) {
            showDialog(Dialogue.bossPlayerMeetBoss, initialDelay: 1.0)
        }
    }
    
    func handleGameWin() {
//        if !checkAndSetKey(UserDefaults.hasSeenBossDefeatedKey) {
            if numPrevBossWins > 3 {
                showDialog(Dialogue.bossPlayerOnAWinStreak)
            } else {
                showDialog(Dialogue.bossPlayerKillsBoss)

            }
//        }
    }
    
    func handleBossTurnStart(_ bossPhase: BossPhase) {
        
        /// Message containing hint about destroying rocks the boss wants to eat.
        if bossPhase.bossState.targets.whatToEat != nil  && bossPhase.bossState.targets.eats == nil {
            let numberBefore = userDefaults.integer(forKey: UserDefaults.numberOfTimesBossHasEatenKey)
            userDefaults.set(numberBefore+1, forKey: UserDefaults.numberOfTimesBossHasEatenKey)
            
            if numberBefore >= Constants.numberOfTimesBeforeShowingWhatToEatHint && !checkAndSetKey(UserDefaults.hasSeenBossTargetWhatToEatKey) {
                showDialog(Dialogue.bossTargetsRocksToEat)
            }
        }
        /// Message containing hint that the red->yellow eyes show when Wally will attack again
        if bossPhase.bossState.stateType == .rests && bossPhase.bossState.turnsLeftInState == 2 {
            
            // this branch kinda keeps track of when the boss has done a full cycle
            hasAlreadyShownHintAboutAttackTypeThisTurn = false
            
            let numberBefore = userDefaults.integer(forKey: UserDefaults.numberOfTimesBossHasBeenGettingReadyToEatKey)
            userDefaults.set(numberBefore+1, forKey: UserDefaults.numberOfTimesBossHasBeenGettingReadyToEatKey)
            
            if numberBefore >= Constants.numberOfTimesBeforeShowingAboutToEatAgainHint && !checkAndSetKey(UserDefaults.hasSeenBossIsGettingReadyToEatKey) {
                showDialog(Dialogue.bossIsGettingReadyToEatAgain)
            }
        }
        
        /// Messages containing hints about the poison attacks
        if case BossStateType.targetAttack(let attack) = bossPhase.bossState.stateType {
            switch attack {
            case .dynamite:
                let numberBefore = userDefaults.integer(forKey: UserDefaults.numberOfTimesSeenDynamiteTargetKey)
                userDefaults.set(numberBefore+1, forKey: UserDefaults.numberOfTimesSeenDynamiteTargetKey)
                
                if !hasAlreadyShownHintAboutAttackTypeThisTurn,
                    numberBefore >= Constants.numberOfTimesBeforeShowingDynamiteTargetHint,
                   !checkAndSetKey(UserDefaults.hasSeenBossTargetDynamiteKey) {
                    hasAlreadyShownHintAboutAttackTypeThisTurn = true
                    showDialog(Dialogue.bossTargetsToAttackDynamite)
                    
                }
            case .poison:
                let numberBefore = userDefaults.integer(forKey: UserDefaults.numberOfTimesSeenPoisonTargetKey)
                userDefaults.set(numberBefore+1, forKey: UserDefaults.numberOfTimesSeenPoisonTargetKey)
                
                if !hasAlreadyShownHintAboutAttackTypeThisTurn,
                    numberBefore >= Constants.numberOfTimesBeforeShowingPoisonAttackHint,
                   !checkAndSetKey(UserDefaults.hasSeenBossTargetPoisonKey) {
                    hasAlreadyShownHintAboutAttackTypeThisTurn = true
                    showDialog(Dialogue.bossTargetsToAttackPoison)
                }
                
            case .spawnMonster(_):
                let numberBefore = userDefaults.integer(forKey: UserDefaults.numberOfTimesSeenSpawnMinionsTargetKey)
                userDefaults.set(numberBefore+1, forKey: UserDefaults.numberOfTimesSeenSpawnMinionsTargetKey)
                
                if !hasAlreadyShownHintAboutAttackTypeThisTurn,
                    numberBefore >= Constants.numberOfTimesBeforeShowingSpawnMinionsHint,
                   !checkAndSetKey(UserDefaults.hasSeenBossGetReadyToSpawnMinionsKey) {
                    hasAlreadyShownHintAboutAttackTypeThisTurn = true
                    showDialog(Dialogue.bossTargetsToAttackSpawnMonsters)
                }

            }
            
        }
        
    }
    
    func handleBossPhaseStart(_ bossPhase: BossPhase) {
        hasAlreadyShownHintAboutAttackTypeThisTurn = false
        
        if !checkAndSetKey(UserDefaults.hasSeenBossPhaseOneToTwoKey) {
            showDialog(Dialogue.bossPlayerTriggersFirstPhaseChange)
        }
    }
    
    func showDialog(_ dialog: Dialogue, initialDelay: TimeInterval = 0.0) {
        // remove the last one
        foreground.removeChild(with: Constants.bossDialogOverlayName)
        
        // create and show the new one
        let selectRandomly: Int
        if dialog == .bossPlayerKillsBoss || dialog == .bossPlayerOnAWinStreak {
            selectRandomly = 1
        } else {
            selectRandomly = 0
        }
        let bossDialogPhase = BossDialoguePhase(dialogue: dialog, selectRandomly: selectRandomly)
        let bossDialogOverlay = BossDialogueOverlay(playableRect: playableRect, foreground: foreground, bossDialoguePhase: bossDialogPhase)
        bossDialogOverlay.name = Constants.bossDialogOverlayName
        
        let wait = SKAction.wait(forDuration: initialDelay)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        fadeIn.timingMode = .easeInEaseOut
        
        
        bossDialogOverlay.alpha = 0
        foreground.addChild(bossDialogOverlay)
        bossDialogOverlay.run(SKAction.sequence([wait, fadeIn]))
        
    }
}



