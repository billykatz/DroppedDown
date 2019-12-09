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
    case tutorial1Win
    
    struct Constants {
        static let resume = "Resume"
        static let win = "You Won!!"
        static let playAgain = "Play Again?"
        static let visitStore = "Visit Store"
    }
    
    
    var buttonIdentifer: ButtonIdentifier {
        switch self {
        case .pause:
            return ButtonIdentifier.resume
        case .gameWin:
            return ButtonIdentifier.playAgain
        case .rotate:
            return ButtonIdentifier.rotate
        case .tutorial1Win:
            return ButtonIdentifier.visitStore
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
