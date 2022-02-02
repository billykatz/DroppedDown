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
    static let hasMetBossForFirstTimeKey = "hasMetBossForFirstTimeKey"
    static let hasSeenBossTargetWhatToEatKey = "hasSeenBossTargetWhatToEatKey"
    static let hasSeenBossEatRocksKey = "hasSeenBossEatRocksKey"
    static let hasSeenBossTargetDynamiteKey = "hasSeenBossTargetDynamiteKey"
    static let hasSeenBossTargetPoisonKey = "hasSeenBossTargetPoisonKey"
    static let hasSeenBossGetReadyToSpawnMinionsKey = "hasSeenBossGetReadyToSpawnMinionsKey"
    static let hasSeenBossPhaseOneToTwoKey = "hasSeenBossPhaseOneToTwoKey"
    static let hasSeenBossPhaseTwoToThreeKey = "hasSeenBossPhaseTwoToThreeKey"
    static let hasSeenBossDefeatedKey = "hasSeenBossDefeatedKey"
    
    /// non-sequential
    static let hasSeenPillarDestroyedKey = "hasSeenPillarDestroyedKey"
    static let hasSeenBossIsGettingReadyToEatKey = "hasSeenBossIsGettingReadyToEatKey"
    
    static let hasSeenPlayerDiedKey = "hasSeenPlayerDiedToBossKey"
    
    static let bossKeys : [String] = [
        hasMetBossForFirstTimeKey,
        hasSeenBossTargetWhatToEatKey,
        
    ]
    
    func clearBossKeys() {
        for key in UserDefaults.bossKeys {
            UserDefaults.standard.set(false, forKey: key)
        }
    }
}

class BossDialogController {
    
    let foreground: SKNode
    let playableRect: CGRect
    let userDefaults: UserDefaults
    
    init(foreground: SKNode, playableRect: CGRect, userDefaults: UserDefaults = .standard) {
        self.foreground = foreground
        self.playableRect = playableRect
        self.userDefaults = userDefaults
        
        #if DEBUG
        userDefaults.clearBossKeys()
        #endif
        
        Dispatch.shared.register { [weak self] input in
            if case InputType.bossTurnStart(let phase) = input.type {
                self?.handleBossTurnStart(phase)
            } else if case InputType.bossPhaseStart(let phase) = input.type {
                self?.handleBossPhaseStart(phase)
            } else if input.type == .boardBuilt || input.type == .boardBuilt  {
                self?.handleFirstTurn()
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
    
    func handleFirstTurn() {
        /// First message
        if !checkAndSetKey(UserDefaults.hasMetBossForFirstTimeKey) {
            showDialog(Dialogue.bossPlayerMeetBoss, initialDelay: 1.0)
        }
    }
    
    func handleBossTurnStart(_ bossPhase: BossPhase) {
        /// First message
        if !checkAndSetKey(UserDefaults.hasSeenBossTargetWhatToEatKey) {
            showDialog(Dialogue.bossTargetsRocksToEat)
        }
        
    }
    
    func handleBossPhaseStart(_ bossPhase: BossPhase) {
        
    }
    
    struct Constants {
        static let bossDialogOverlayName = "bossDialogOverlayName"
    }
    
    func showDialog(_ dialog: Dialogue, initialDelay: TimeInterval = 0.0) {
        // remove the last one
        foreground.removeChild(with: Constants.bossDialogOverlayName)
        
        // create and show the new one
        let bossDialogPhase = BossDialoguePhase(dialogue: dialog)
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



