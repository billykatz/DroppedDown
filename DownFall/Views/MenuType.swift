//
//  MenuType.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

enum MenuType {
    case pause
    case gameWin
    case rotate
    case gameLose
    case confirmation
    case tutorialConfirmation
    case debug
    case detectedSavedGame
    case detectedSavedTutorial
    case confirmAbandonTutorial
    case tutorialPause
    
    struct Constants {
        static let resume = "Resume"
        static let win = "You Won!!"
        static let playAgain = "Play Again?"
        static let visitStore = "Visit Store"
        static let gameLose = "Sorry, you ded"
    }
    
    
    var buttonIdentifer: ButtonIdentifier {
        switch self {
        case .pause, .tutorialPause:
            return ButtonIdentifier.resume
        case .gameWin:
            return ButtonIdentifier.visitStore
        case .rotate:
            return ButtonIdentifier.rotate
        case .gameLose:
            return ButtonIdentifier.playAgain
        case .confirmation, .tutorialConfirmation, .confirmAbandonTutorial:
            return ButtonIdentifier.backpackConfirm
        case .debug:
            return .resume
        case .detectedSavedGame, .detectedSavedTutorial:
            return ButtonIdentifier.backpackConfirm
        }
        
    }
    
    var secondaryButtonIdentifier: ButtonIdentifier? {
        switch self {
        case .confirmation:
            return ButtonIdentifier.backpackCancel
        default:
            return nil
        }
    }
    
    var widthCoefficient: CGFloat {
        switch self {
        case .rotate:
            return 0.9
        default:
            return 0.7
        }
    }
    
    var heightCoefficient: CGFloat {
        switch self {
        case .rotate:
            return 0.65
        default:
            return 0.33
        }
    }
}
