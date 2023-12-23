//
//  ProfileViewModel+ScreenshotHelper.swift
//  DownFall
//
//  Created by Billy on 3/10/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

extension ProfileViewModel {
    
    func setUpPowerUpScreenShot() {
        #if DEBUG
        var newUnlockables : [Unlockable] = []
        for unlockable in profile.unlockables {
            var isUnlocked = false
            var isPurchased = false
            var hasBeenTapped = true
            
            if unlockable.item == StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), unlockable.item.tier == 1 {
                isUnlocked = true
                isPurchased = true
                hasBeenTapped = true
                
            } else if unlockable.item == StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), unlockable.item.tier == 2 {
                isUnlocked = true
                isPurchased = false
                hasBeenTapped = false
                
            } else if unlockable.item == StoreOffer.offer(type: .plusOneMaxHealth, tier: 3), unlockable.item.tier == 3 {
                isUnlocked = false
                isPurchased = false
                hasBeenTapped = false
                
            }
            /// DODGE
            else if unlockable.item == StoreOffer.offer(type: .dodge(amount: 3), tier: 1), unlockable.item.tier == 1 {
                isUnlocked = true
                isPurchased = true
                hasBeenTapped = true
                
            } else if unlockable.item == StoreOffer.offer(type: .dodge(amount: 3), tier: 2), unlockable.item.tier == 2 {
                isUnlocked = true
                isPurchased = false
                hasBeenTapped = false
                
            } else if unlockable.item == StoreOffer.offer(type: .dodge(amount: 3), tier: 3), unlockable.item.tier == 3 {
                isUnlocked = false
                isPurchased = false
                hasBeenTapped = false
                
            }
            /// LUCK
            else if unlockable.item == StoreOffer.offer(type: .luck(amount: 3), tier: 1), unlockable.item.tier == 1 {
                isUnlocked = true
                isPurchased = true
                hasBeenTapped = true
                
            } else if unlockable.item == StoreOffer.offer(type: .luck(amount: 3), tier: 2), unlockable.item.tier == 2 {
                isUnlocked = true
                isPurchased = false
                hasBeenTapped = false
                
            } else if unlockable.item == StoreOffer.offer(type: .luck(amount: 3), tier: 3), unlockable.item.tier == 3 {
                isUnlocked = false
                isPurchased = false
                hasBeenTapped = false
            }
            

            let new = Unlockable(stat: unlockable.stat, item: unlockable.item, purchaseAmount: unlockable.purchaseAmount, isPurchased: isPurchased, isUnlocked: isUnlocked, applysToBasePlayer: unlockable.applysToBasePlayer, recentlyPurchasedAndHasntSpawnedYet: unlockable.recentlyPurchasedAndHasntSpawnedYet, hasBeenTappedOnByPlayer: hasBeenTapped)
            
            
            newUnlockables.append(new)
        }

        var newPlayerData = profile.player
        
        newPlayerData = newPlayerData.spend(amount: newPlayerData.carry.totalGem)
        
        newPlayerData = newPlayerData.earn(amount: 250)
        
        let newProfile = profile.updatePlayer(newPlayerData)
        
        saveProfile(newProfile.updateAllUnlockables(newUnlockables))
        #endif

    }
    

}
