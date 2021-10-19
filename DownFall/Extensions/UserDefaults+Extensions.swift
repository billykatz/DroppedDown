//
//  UserDefaults+Extensions.swift
//  DownFall
//
//  Created by Billy on 6/23/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine

struct UserDefaultClient {
    var fetchPlayerUUID: (String) -> Future<String, Error>
    var set: (String?, String) -> ()
}

extension UserDefaultClient {
    static var live = Self(
        fetchPlayerUUID: { UserDefaults.fetchPlayerUUID(uuidKey: $0) },
        set: { name, key in return UserDefaults.standard.set(name, forKey: key) }
    )
    static var noUserDefaults = Self(
        fetchPlayerUUID: { _ in
            return Future { promise in promise(.failure(ProfileError.noUserDefaultsValue)) }
        },
        set: { _,_ in }
    )
    
    static let testUserDefaults = Self(
        fetchPlayerUUID: { _ in
            return Future { promise in promise(.success("test-uuid")) }
        }, set: { _, _ in }
    )
}


extension UserDefaults {
    /// Returns the UUID saved in UserDefaults or an error if no UserDefaults exists
    static func fetchPlayerUUID(uuidKey: String) -> Future<String, Error> {
        return Future { promise in
            if let playerUUID = UserDefaults.standard.string(forKey: uuidKey) { promise(.success(playerUUID))
            } else {
                promise(.failure(ProfileError.noUserDefaultsValue))
            }
        }
    }
    
    static let muteSoundKey = "muteSound"
    static let showGroupNumberKey = "showRockGroupNumber"
    static let hasLaunchedBeforeKey = "hasLaunchedBefore"
    static let hasCompletedTutorialKey = "hasCompletedTutorial"
}
