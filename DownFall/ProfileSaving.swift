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
    func saveProfile(name: String, completion: @escaping (Bool) -> Void)
    func loadProfile(name: String, completion: @escaping (Profile?) -> Void)
    func authenticate(_ presenter: UIViewController)
}


class ProfileViewModel: ProfileSaving {
    func authenticate(_ presenter: UIViewController) {
        GKLocalPlayer().authenticateHandler = { viewController, error in
            if let vc = viewController {
                presenter.present(vc, animated: true)
            } else if GKLocalPlayer().isAuthenticated {
                print("we are authenticated")
            } else {
                print("disable GameCenter")
            }
        }
    }
    
    
    func saveProfile(name: String, completion: @escaping (Bool) -> Void) {
        let localPlayer = GKLocalPlayer()
        let fauxData = "Billy".data(using: .utf8)!
        localPlayer.saveGameData(fauxData, withName: name) { (savedGame, error) in
            completion(savedGame != nil)
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
                completion(nil)
            }
        }

    }
}
