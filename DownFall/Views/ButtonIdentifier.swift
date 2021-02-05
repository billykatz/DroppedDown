//
//  ButtonIdentifier.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

enum ButtonIdentifier: String {
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
    case backpack
    case backpackSelect
    case backpackCancel
    case backpackConfirm
    case mainMenu
    case cycleLevel
    case seeInventory
    case shuffleBoard
    case runeReplaceCancel
    case runeReplaceConfirm
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
    
    case increaseGreen
    case increaseBlue
    case increaseRed
    case increaseAlpha
    
    var title: String {
        switch self {
        case .resume:
            return "Resume"
        case .playAgain:
            return "Play Again?"
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
        case .mainMenu:
            return "Main Menu"
        case .cycleLevel:
            return "Level select"
        case .seeInventory:
            return "Inventory"
        case .shuffleBoard:
            return "Pay 2 \u{2665}: Shuffle board"
        case .runeReplaceCancel:
            return "Cancel"
        case .runeReplaceConfirm:
            return "Confirm"
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
            return "Settings"
        case .discardFoundRune:
            return "Discard"
        case .swapRunes:
            return "Swap"
        case .toggleSound:
            return "Toggle Sound"
        case .increaseGreen:
            return "+ 50 Green"
        case .increaseBlue:
            return "+ 50 Blue"
        case .increaseRed:
            return "+ 50 Red"
        case .increaseAlpha:
            return "+ 50 Alpha"
        case .wallet, .infoPopup, .storeItem, .backpack, .sellHealth, .buyHealth, .sellDodge, .buyDodge, .sellLuck, .buyLuck, .buyRuneSlot, .sellRuneSlot:
            return ""
        }
    }
}
