//
//  ButtonIdentifier.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

enum ButtonIdentifier: String {
    
    case mainMenuAbandonTutorial
    case mainMenuAbandonRun
    case mainMenuContinueRun
    case mainMenuContinueTutorial
    
    case yesAbandonRun
    case doNotAbandonRun
    case doNotAbandonTutorial
    case yesSkipTutorial
    
    case runeReplacementCancel
    
    case resume
    case playAgain
    case selectLevel
    case leaveStore
    case storeItem
    case rotate
    case wallet
    case infoPopup
    case visitStore
    case newGame
    case back
    case startTutorial
    case purchase
    case sell
    case close
    
    // MARK:- Rune Use
    case backpack
    case backpackSelect
    case backpackCancel
    case backpackConfirm
    case runeUseConfirmBeforeReady
    
    
    case mainMenu
    case pausedExitToMainMenu
    case tutorialPausedExitToMainMenu
    case cycleLevel
    case seeInventory
    case okay
    case sellHealth
    case buyHealth
    case sellDodge
    case buyDodge
    case sellLuck
    case buyLuck
    case buyRuneSlot
    case sellRuneSlot
    case selectProfile
    case newProfile
    case resetData
    
    // Main Menu
    case mainMenuStats
    case mainMenuFeedback
    
    case mainMenuSwipeScreenshot
    
    case continueRun
    case discardFoundRune
    case swapRunes
    
    // Options
    case toggleSound
    case toggleMusic
    case toggleShowGroupNumber
    
    case givePlayerRune
    case debugPause
    case debugWin
    
    case gameMenuOptions
    case soundOptionsBack
    
    case tutorialMenuOptions
    case tutorialSoundOptionsBack
    
    // game recap
    case gameRecapViewBoard
    case gameRecapShowRecap
    
    // shuffle board
    case confirmShufflePay2Hearts
    case confirmShufflePay25Percent
    
    
    // Boss test scene buttons
    case echoEffect
    case walkEffect
    case tiltHead
    case chompTeeth
    case lightBite
    case angryEyes
    case idlePhase1
    case rockTrio
    case rearUp
    case groundPound
    case resetPositions
    case poisonBeamAttack
    case webAttack
    case eyesTurnRed
    case oneEyeTurnsYellow
    case worried
    case bossStomps
    
    var title: String {
        switch self {
        case .resume:
            return "Resume"
        case .playAgain:
            return "Main Menu"
        case .selectLevel:
            return "Level Select"
        case .leaveStore, .continueRun:
            return "Continue"
        case .rotate:
            return "Got it! 👍"
        case .visitStore:
            return "Continue"
        case .newGame:
            return "New Run"
        case .back:
            return "Back"
        case .startTutorial:
            return "Start Tutorial"
        case .purchase:
            return "Purchase"
        case .sell:
            return "Sell"
        case .close:
            return "Close"
        case .backpackSelect:
            return "Select"
        case .backpackCancel:
            return "Cancel"
        case .backpackConfirm:
            return "Confirm"
        case .mainMenu, .pausedExitToMainMenu:
            return "Exit to Menu"
        case .tutorialPausedExitToMainMenu:
            return "Skip Tutorial"
        case .mainMenuAbandonTutorial:
            return "(Not recommended)\nSkip tutorial"
        case .mainMenuContinueTutorial:
            return "Continue tutorial"
        case .cycleLevel:
            return "Level select"
        case .seeInventory:
            return "Inventory"
        case .okay:
            return "Okay"
        case .selectProfile:
            return "Delete Local Profile"
        case .newProfile:
            return "Delete Remote profile"
        case .resetData:
            return "Reset Data"
        case .mainMenuStats:
            return "Stats"
        case .discardFoundRune:
            return "Discard Found Rune"
        case .swapRunes:
            return "Swap Runes"
        case .toggleSound:
            return "Sound"
        case .toggleMusic:
            return "Music"
        case .toggleShowGroupNumber:
            return "Rock Group Total"
        case .givePlayerRune:
            return "Give Player Random Rune"
            
            
        case .debugPause:
            return "Debug Pause"
        case .debugWin:
            return "Debug Win"
            
        case .yesAbandonRun, .mainMenuAbandonRun:
            return "Abandon run"
        
        case .yesSkipTutorial:
            return "Skip tutorial"
            
        case .doNotAbandonRun, .doNotAbandonTutorial:
            return "Cancel"
            
        case .mainMenuContinueRun:
            return "Continue run"
            
        case .mainMenuFeedback:
            return "Feedback"
            
        case .soundOptionsBack, .tutorialSoundOptionsBack:
            return "Back"
        
        case .gameMenuOptions, .tutorialMenuOptions:
            return "Options"
            
        case .gameRecapViewBoard:
            return "Show board"
            
        case .gameRecapShowRecap:
            return "Show recap"
            
            
        case .confirmShufflePay2Hearts:
            return "Offer 2 hearts"
        
        case .confirmShufflePay25Percent:
            return "Offer 25% of gems"
            
        
        case .wallet, .infoPopup, .storeItem, .backpack, .sellHealth, .buyHealth, .sellDodge, .buyDodge, .sellLuck, .buyLuck, .buyRuneSlot, .sellRuneSlot, .runeReplacementCancel, .runeUseConfirmBeforeReady:
            return ""
            
            
        // Boss Test Scene Button cases
        case .echoEffect:
            return "Echo"
        case .walkEffect:
            return "Walk"
        case .tiltHead:
            return "Tilt"
        case .chompTeeth:
            return "Chomp"
        case .lightBite:
            return "Bite"
        case .angryEyes:
            return "Angry Eyes"
        case .idlePhase1:
            return "Idle Phase 1"
        case .rockTrio:
            return "Rock Trio"
        case .rearUp:
            return "Rear Up"
        case .groundPound:
            return "Ground Pound"
        case .resetPositions:
            return "Reset Positions"
        case .poisonBeamAttack:
            return "Poison Beam"
        case .webAttack:
            return "Web Attack"
        case .eyesTurnRed:
            return "Eyes Red"
        case .oneEyeTurnsYellow:
            return "1 Eye Yellow"
        case .worried:
            return "Worried"
        case .bossStomps:
            return "Stomps"
            
            
        /// screen shot stuff
        case .mainMenuSwipeScreenshot:
            return "Swipe"
        }
    }
}
