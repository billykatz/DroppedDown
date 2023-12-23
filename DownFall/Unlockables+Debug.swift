//
//  Unlockables+Debug.swift
//  DownFall
//
//  Created by Billy on 2/28/22.
//  Copyright © 2022 William Katz LLC. All rights reserved.
//

import Foundation

extension Unlockable {
    
    static var debugUnlockables: [Unlockable] {
        [
            
            // Player Updates
            Unlockable(stat: .fiveRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 0, isPurchased: true, isUnlocked: true, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: true),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 2
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: true),
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 3
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .luck(amount: 5), tier: 3), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 3), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 4
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .luck(amount: 5), tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            
            // AVAILABLE IN RUNS
            
            // Better items
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .greaterHeal, tier: 1), purchaseAmount: 300, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .plusTwoMaxHealth, tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            // Runes
            Unlockable(stat: .oneThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .drillDown)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled100, item: StoreOffer.offer(type: .rune(Rune.rune(for: .fieryRage)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled250, item: StoreOffer.offer(type: .rune(Rune.rune(for: .monsterCrush)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandPurpleRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .moveEarth)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandBlueRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .teleportation)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandBlueRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandPurpleRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            
            // rune slots
            Unlockable(stat: .largestGroup40, item: StoreOffer.offer(type: .runeSlot, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .allRunesUses100, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled100, item: StoreOffer.offer(type: .runeSlot, tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            // red runes
            Unlockable(stat: .oneThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameColumn)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .twoThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .threeThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 2), purchaseAmount: 800, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // Luck and dodge stuff
            Unlockable(stat: .fiveHundredGems, item: StoreOffer.offer(type: .wingedBoots, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveHundredGems, item: StoreOffer.offer(type: .luckyCat, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
        ]
    }
    
}
