//
//  GKLocalPlayer.swift
//  DownFall
//
//  Created by Katz, Billy on 7/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Combine
import GameKit

struct PlayerClient {
    var fetchGCSavedGames: () -> Future<[GKSavedGame], Error>
    var saveGameData: (Data, String, @escaping ((GKSavedGame?, Error?) -> ())) -> ()
    var deleteGame: (String) -> Future<Bool, Error>
    var authenticationHandler : (((UIViewController?, Error?) -> ())?) -> ()
    var isAuthenticated: () -> Bool
}

extension PlayerClient {
    static let live = Self(
        fetchGCSavedGames: { GKLocalPlayer.local.fetchGCSavedGames() },
        saveGameData: { data, name, completion in
            GKLocalPlayer.local.saveGameData(data, withName: name, completionHandler: completion)
        },
        deleteGame: { GKLocalPlayer.local.deleteGame($0) },
        authenticationHandler: { authHandler in
            GKLocalPlayer.local.authenticateHandler = authHandler
        },
        isAuthenticated: { GKLocalPlayer.local.isAuthenticated }
    )
}

extension GKLocalPlayer {
    func fetchGCSavedGames() -> Future<[GKSavedGame], Error> {
        return Future { promise in
            GKLocalPlayer.local.fetchSavedGames { (savedGames, error) in
                if let err = error {
                    promise(.failure(err))
                } else {
                    promise(Result.success(savedGames ?? []))
                }
            }
            
        }
    }
    
    func deleteGame(_ name: String) -> Future<Bool, Error> {
        return Future { promise in
            GKLocalPlayer.local.deleteSavedGames(withName: name) { (error) in
                if error == nil {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
    }

}

