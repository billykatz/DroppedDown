//
//  ButtonIdentifier.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

enum ButtonIdentifier: String {
    
    case mainMenuAbandonRun
    case mainMenuContinueRun
    
    case yesAbandonRun
    case doNotAbandonRun
    
    case runeReplacementCancel
    
    case resume
    case playAgain
    case selectLevel
    case leaveStore
    case loseAndGoToStore
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
    case backpack
    case backpackSelect
    case backpackCancel
    case backpackConfirm
    case mainMenu
    case pausedExitToMainMenu
    case cycleLevel
    case seeInventory
    case shuffleBoard
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
    case mainMenuOptions
    case mainMenuStore
    case continueRun
    case discardFoundRune
    case swapRunes
    case toggleSound
    case givePlayerRune
    case debugPause
    case debugWin
    case debugLose
    
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
            return "New Game"
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
        case .cycleLevel:
            return "Level select"
        case .seeInventory:
            return "Inventory"
        case .shuffleBoard:
            return "Pay 2 \u{2665}: Shuffle board"
        case .okay:
            return "Okay"
        case .selectProfile:
            return "Delete Local Profile"
        case .newProfile:
            return "Delete Remote profile"
        case .resetData:
            return "Reset Data"
        case .mainMenuStore:
            return "Store"
        case .mainMenuOptions:
            return "Stats"
        case .discardFoundRune:
            return "Discard Found Rune"
        case .swapRunes:
            return "Swap Runes"
        case .toggleSound:
            return "Sound"
        case .givePlayerRune:
            return "Give Player Random Rune"
        case .debugPause:
            return "Debug Pause"
        case .debugWin:
            return "Debug Win"
        case .debugLose:
            return "Debug Lose"
        case .loseAndGoToStore:
            return "Go to Store"
            
        case .yesAbandonRun, .mainMenuAbandonRun:
            return "Abandon run"
        case .doNotAbandonRun:
            return "Cancel"
            
        case .mainMenuContinueRun:
            return "Continue run"
        
        case .wallet, .infoPopup, .storeItem, .backpack, .sellHealth, .buyHealth, .sellDodge, .buyDodge, .sellLuck, .buyLuck, .buyRuneSlot, .sellRuneSlot, .runeReplacementCancel:
            return ""
        }
    }
}
