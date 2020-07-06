//
//  ProfileSaving.swift
//  DownFall
//
//  Created by Katz, Billy on 6/14/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import GameKit

struct Profile {
    let name: String
}

protocol ProfileSaving {
    func saveProfile(name: String, overwriteFile: Bool, completion: @escaping (Result<Bool, ProfileError>) -> Void)
    func loadProfile(name: String, completion: @escaping (Profile?) -> Void)
    func authenticate(_ presenter: UIViewController)
}

enum ProfileError: Error {
    case fileWithNameAlreadyExists
    case saveError(Error)
}

class ProfileViewModel: ProfileSaving {
    func authenticate(_ presenter: UIViewController) {
        print("Starting to authenticate with game center")
        GKLocalPlayer().authenticateHandler = { viewController, error in
            if let vc = viewController {
                presenter.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("we are authenticated")
            } else {
                print("disable GameCenter")
            }
        }
    }
    
    
    func saveProfile(name: String, overwriteFile: Bool = false, completion: @escaping (Result<Bool, ProfileError>) -> Void) {
        let localPlayer = GKLocalPlayer()
        let fauxData = "Billy".data(using: .utf8)!
        
        /// Fetch the save games to see if there are any other games with the same name
        localPlayer.fetchSavedGames { (savedGames, error) in
            guard error == nil else {
                completion(.failure(.saveError(error!)))
                return
            }
            
            /// Check if a profile already exists with the name
            savedGames?
                .filter({ (game) -> Bool in
                    return game.name == name
                })
                .forEach { game in
                    if !overwriteFile {
                        completion(.failure(.fileWithNameAlreadyExists))
                        return
                    }
                }
            
            guard overwriteFile else { return }
            
            /// If we have reach this point, we should save the data
            localPlayer.saveGameData(fauxData, withName: name) { (savedGame, error) in
                completion(.success(true))
            }
        }
    }
    
    func loadProfile(name: String, completion: @escaping (Profile?) -> Void) {
        let localPlayer = GKLocalPlayer()
        localPlayer.fetchSavedGames { (savedGames, error) in
            if error == nil, let games = savedGames {
                for game in games {
                    if game.name == name {
                        completion(Profile(name: game.name!))
                        return
                    }
                }
            } else {
                // This should be considered a failure.
                completion(nil)
            }
        }
        
    }
}
