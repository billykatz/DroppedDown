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
    
    var title: String {
        switch self {
        case .resume:
            return "Resume"
        case .playAgain:
            return "Play Again?"
        case .selectLevel:
            return "Level Select"
        case .leaveStore:
            return "Leave Store"
        case .rotate:
            return "Got it! 👍"
        case .visitStore:
            return "Visit Store"
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
            return "Level start"
        case .seeInventory:
            return "Inventory"
        case .shuffleBoard:
            return "Pay 2 \u{2665}: Shuffle board"
        case .wallet, .infoPopup, .storeItem, .backpack:
            return ""
        }
    }
}