//
//  GKLocalPlayer.swift
//  DownFall
//
//  Created by Katz, Billy on 7/18/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import Combine
import GameKit

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
    
    func deleteGame(_ game: GKSavedGame) -> Future<Bool, Error> {
        return Future { promise in
            GKLocalPlayer.local.deleteSavedGames(withName: game.name ?? "") { (error) in
                if error == nil {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
    }
}

