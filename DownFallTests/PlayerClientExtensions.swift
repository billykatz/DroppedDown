//
//  PlayerClientExtensions.swift
//  DownFallTests
//
//  Created by Billy on 6/25/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine
import GameKit
@testable import Shift_Shaft

extension PlayerClient {
    static let noSavedGames = Self(
        fetchGCSavedGames: {
            return Future { promise in
                promise(.failure(ProfileError.failedToLoadRemoteProfile(nil)))
            }
        },
        saveGameData: { _, _, _ in },
        deleteGame: { _ in
            return Future { promise in
                promise(.success(true))
            }
        },
        authenticationHandler: { callback in
            callback!(UIViewController(), nil)
        },
        isAuthenticated: { return true }
    )
    
    static let success = Self(
        fetchGCSavedGames: {
            return Future { promise in
                promise(.success([GKSavedGame()]))
            }
        },
        saveGameData: { _, _, _ in },
        deleteGame: { _ in
            return Future { promise in
                promise(.success(true))
            }
        },
        authenticationHandler: { callback in
            callback!(UIViewController(), nil)
        },
        isAuthenticated: { return true }
    )
}

