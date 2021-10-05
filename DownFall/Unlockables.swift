//
//  Unlockables.swift
//  DownFall
//
//  Created by Billy on 9/12/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct Unlockable: Codable, Identifiable, Equatable {
    
    static func == (lhs: Unlockable, rhs: Unlockable) -> Bool {
        return lhs.id == rhs.id
    }
    
    let stat: Statistics
    let item: StoreOffer
    let purchaseAmount: Int
    let isPurchased: Bool
    let isUnlocked: Bool
    let applysToBasePlayer: Bool
    
    var canAppearInRun: Bool {
        return isUnlocked && isPurchased && !applysToBasePlayer
    }
    
    var id: String {
        return "\(item.textureName)\(item.tier)"
    }
    
    func purchase() -> Unlockable {
        return Unlockable(stat: stat, item: item, purchaseAmount: purchaseAmount, isPurchased: true, isUnlocked: isUnlocked, applysToBasePlayer: applysToBasePlayer)
    }
    
    static var debugData: [Unlockable] {
        return StoreOfferType.allCases.map { Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: $0, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true, applysToBasePlayer: false) }
    }
    
    static var debugStartingUnlockables: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false)
        ]
    }
    
    static var unlockables: [Unlockable] {
        [
            
            // Player Updates
            Unlockable(stat: .fiftyRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 10, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth5, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 3), purchaseAmount: 400, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth5, item: StoreOffer.offer(type: .luck(amount: 5), tier: 3), purchaseAmount: 400, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth5, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 3), purchaseAmount: 400, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 4), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .luck(amount: 5), tier: 4), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .reachDepth10, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 4), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
           
            
            // Better items
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .greaterHeal, tier: 1), purchaseAmount: 250, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .plusTwoMaxHealth, tier: 2), purchaseAmount: 250, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            
            
            // Runes
            Unlockable(stat: .blueGems100Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            Unlockable(stat: .purpleGems100Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            Unlockable(stat: .redGems100Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameColumn)), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),

            
            // red runes
            Unlockable(stat: .fiveHundredGems, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 2), purchaseAmount: 300, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            // rune uses
            Unlockable(stat: .fiveHundredGems, item: StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2), purchaseAmount: 300, isPurchased: false, isUnlocked: false, applysToBasePlayer: false),
            
            
            // rune slots
            Unlockable(stat: .largestGroup40, item: StoreOffer.offer(type: .runeSlot, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .allRunesUses100, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true),
            Unlockable(stat: .monstersKilled100, item: StoreOffer.offer(type: .runeSlot, tier: 3), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true)
        ]
    }
    
    static var startingUnlockedUnlockables: [Unlockable] {
        let stat = Statistics(amount: 0, statType: .attacksDodged)
        
        
        return [
            Unlockable(stat: stat, item: StoreOffer.offer(type: .lesserHeal, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .luck(amount: 2), tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .dodge(amount: 2), tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .gems(amount: 25), tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            
            Unlockable(stat: stat, item: StoreOffer.offer(type: .luck(amount: 4), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .dodge(amount: 4), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .gems(amount: 50), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .fireball)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .killMonsterPotion, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false),
            
        ]
    }
    
}