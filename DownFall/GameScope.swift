//
//  GameScope.swift
//  DownFall
//
//  Created by William Katz on 12/8/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics
import UIKit

/// Singleton to hold references to game-wide variables
final class GameScope {
    
    struct Constants {
        static let tag = String(describing: GameScope.self)
    }
    
    static let boardSizeCoefficient = CGFloat(0.9)
    static var shared: GameScope = GameScope(difficulty: .normal)
    var difficulty: Difficulty
    let profileManager: ProfileManaging = ProfileLoadingManager()
    
    var screenSize: CGSize {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return .zero
        }

        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        return CGSize(width: windowWidth, height: windowHeight)
    }
    
    init(difficulty: Difficulty) {
        self.difficulty = difficulty
    }
    
    
    
    deinit {
        GameLogger.shared.log(prefix: Constants.tag, message: "GameScopre has been deinited")
    }
}

