//
//  ProfileCodingClient+Extensions.swift
//  DownFallTests
//
//  Created by Billy on 7/2/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
@testable import Shift_Shaft

extension Unlockable {
    static var testUnlockablesNonePurchased: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 3), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 4), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
        ]
    }
    
    static var testUnlockablesOnePurchased: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 3), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 4), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
        ]
    }
    

    
    static let unlockables1Progress = debugStartingUnlockables
}

extension ProfileDecodingClient {
    static let test = Self { profileType, data in
        return Profile(name: "test-uuid", player: .playerZero, currentRun: nil, stats: [], unlockables: [], startingUnlockbles: [], pastRunSeeds: [])
    }
    
    static let progress10 = Self { profileType, data in
        return Profile(name: "test-uuid", player: .playerZero, currentRun: nil, stats: [], unlockables: Unlockable.testUnlockablesOnePurchased, startingUnlockbles: [], pastRunSeeds: [])
        
    }
}

extension ProfileEncodingClient {
    static let test = Self { profile in
        return Data()
    }
}

extension ProfileCodingClient {
    static let test = Self(
        decoder: .test,
        encoder: .test
    )
}
