//
//  Unlockables.swift
//  DownFall
//
//  Created by Billy on 9/12/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation

struct Unlockable: Codable, Identifiable, Equatable, Hashable {
    
    static func == (lhs: Unlockable, rhs: Unlockable) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let stat: Statistics
    let item: StoreOffer
    let purchaseAmount: Int
    let isPurchased: Bool
    let isUnlocked: Bool
    let applysToBasePlayer: Bool
    var recentlyPurchasedAndHasntSpawnedYet: Bool
    var hasBeenTappedOnByPlayer: Bool
    
    var canAppearInRun: Bool {
        return isUnlocked && isPurchased && !applysToBasePlayer
    }
    
    var id: String {
        return "\(item.textureName)\(item.tier)"
    }
    
    func update(
     stat: Statistics? = nil,
     item: StoreOffer? = nil,
     purchaseAmount: Int? = nil,
     isPurchased: Bool? = nil,
     isUnlocked: Bool? = nil,
     applysToBasePlayer: Bool? = nil,
     recentlyPurchasedAndHasntSpawnedYet: Bool? = nil,
     hasBeenTappedOnByPlayer: Bool? = nil
    ) -> Unlockable {
        return Unlockable(stat: stat ?? self.stat,
                          item: item ?? self.item,
                          purchaseAmount: purchaseAmount ?? self.purchaseAmount,
                          isPurchased: isPurchased ?? self.isPurchased,
                          isUnlocked: isUnlocked ?? self.isUnlocked,
                          applysToBasePlayer: applysToBasePlayer ?? self.applysToBasePlayer,
                          recentlyPurchasedAndHasntSpawnedYet: recentlyPurchasedAndHasntSpawnedYet ?? self.recentlyPurchasedAndHasntSpawnedYet,
                          hasBeenTappedOnByPlayer: hasBeenTappedOnByPlayer ?? self.hasBeenTappedOnByPlayer)
    }
    
    func debugDescription() {
        print("""
        \(item.textureName)
        unlocked? \(isUnlocked)
        unlock stat: \(stat.humanReadable())
        purchased: \(isPurchased)
        cost: \(purchaseAmount)
        applysToBase: \(applysToBasePlayer)
        recentlyPurchased: \(recentlyPurchasedAndHasntSpawnedYet)
        hasBeenTappedOnByPlayer: \(hasBeenTappedOnByPlayer)
        id: \(id)
        
        """)
    }
    
    
    func purchase() -> Unlockable {
        return Unlockable(stat: stat, item: item, purchaseAmount: purchaseAmount, isPurchased: true, isUnlocked: isUnlocked, applysToBasePlayer: applysToBasePlayer, recentlyPurchasedAndHasntSpawnedYet: true, hasBeenTappedOnByPlayer: hasBeenTappedOnByPlayer)
    }
    
    func didTapOn() -> Unlockable {
        return Unlockable(stat: stat, item: item, purchaseAmount: purchaseAmount, isPurchased: isPurchased, isUnlocked: isUnlocked, applysToBasePlayer: applysToBasePlayer, recentlyPurchasedAndHasntSpawnedYet: recentlyPurchasedAndHasntSpawnedYet, hasBeenTappedOnByPlayer: true)
    }
    
    static var debugData: [Unlockable] {
        return StoreOfferType.allCases.map { Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: $0, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false) }
    }
    
    static var debugStartingUnlockables: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false)
        ]
    }
    
    static func unlockables() -> [Unlockable] {
        return [
            // Player Updates
            Unlockable(stat: .fiveRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 0, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .luck(amount: 3), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 3), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 2
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .luck(amount: 3), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 3), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 3
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .luck(amount: 4), tier: 3), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .reachDepth8, item: StoreOffer.offer(type: .dodge(amount: 4), tier: 3), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // tier 4
            Unlockable(stat: .beatTheBossOnce, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .beatTheBossOnce, item: StoreOffer.offer(type: .luck(amount: 5), tier: 4), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .beatTheBossOnce, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 4), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// tier 5
            Unlockable(stat: .beatTheBossFiveTimes, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 5), purchaseAmount: 2000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .beatTheBossFiveTimes, item: StoreOffer.offer(type: .luck(amount: 5), tier: 5), purchaseAmount: 1250, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .beatTheBossFiveTimes, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 5), purchaseAmount: 1250, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // AVAILABLE IN RUNS
            
            // HEALTH
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .greaterHeal, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .plusTwoMaxHealth, tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            /// Runes
            ///
            /// RED
            Unlockable(stat: .threeThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .drillDown)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandRedRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .rainEmbers)), tier: 2), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            ///
            /// BLOOD
            ///
            Unlockable(stat: .monstersKilled100, item: StoreOffer.offer(type: .rune(Rune.rune(for: .fieryRage)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled500, item: StoreOffer.offer(type: .rune(Rune.rune(for: .monsterCrush)), tier: 2), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled750, item: StoreOffer.offer(type: .rune(Rune.rune(for: .liquifyMonsters)), tier: 2), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            ///
            /// PURPLE
            ///
            Unlockable(stat: .threeThousandPurpleRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandPurpleRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .moveEarth)), tier: 2), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            ///
            /// BLUE
            ///
            Unlockable(stat: .threeThousandBlueRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .teleportation)), tier: 2), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandBlueRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 2), purchaseAmount: 750, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            
            // rune slots
            Unlockable(stat: .largestGroup40, item: StoreOffer.offer(type: .runeSlot, tier: 1), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .beatTheBossOnce, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .monstersKilled1000, item: StoreOffer.offer(type: .runeSlot, tier: 3), purchaseAmount: 1000, isPurchased: false, isUnlocked: false, applysToBasePlayer: true, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),

            
            
            // Luck and dodge stuff
            Unlockable(stat: .oneHundredAttacksDodged, item: StoreOffer.offer(type: .wingedBoots, tier: 2), purchaseAmount: 250, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .fiveThousandGems, item: StoreOffer.offer(type: .luckyCat, tier: 2), purchaseAmount: 250, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // Other items
            Unlockable(stat: .largestGroup35, item: StoreOffer.offer(type: .liquifyMonsters, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .largestGroup30, item: StoreOffer.offer(type: .infusion, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .largestGroup25, item: StoreOffer.offer(type: .escape, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .largestGroup20, item: StoreOffer.offer(type: .gemMagnet, tier: 1), purchaseAmount: 500, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            Unlockable(stat: .batKilled100, item: StoreOffer.offer(type: .greaterRuneSpiritPotion, tier: 2), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: .sallyKilled100, item: StoreOffer.offer(type: .killMonsterPotion, tier: 2), purchaseAmount: 350, isPurchased: false, isUnlocked: false, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
        ]
    }
    
    static var startingUnlockedUnlockables: [Unlockable] {
        let stat = Statistics(amount: 0, statType: .attacksDodged)
        
        return [
            /// 
            /// TIER 1 health stuff
            Unlockable(stat: stat, item: StoreOffer.offer(type: .lesserHeal, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// TIER 1 luck and dodge
            Unlockable(stat: stat, item: StoreOffer.offer(type: .fourLeafClover, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .sandals, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .runningShoes, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .horseshoe, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// TIER 1 Wealth
            Unlockable(stat: stat, item: StoreOffer.offer(type: .gems(amount: 25), tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// TIER 1 - UTIL
            Unlockable(stat: stat, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .chest, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .snakeEyes, tier: 1), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            /// TIER 2
            /// TIER 2 health
            Unlockable(stat: stat, item: StoreOffer.offer(type: .lesserHeal, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            // TIER 2 dodge and luck
            Unlockable(stat: stat, item: StoreOffer.offer(type: .runningShoes, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .horseshoe, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            /// TIER 2 Wealth
            Unlockable(stat: stat, item: StoreOffer.offer(type: .gems(amount: 50), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// TIER 2 Starting Runes
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .fireball)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            
            /// TIER 2 - UTIL
            Unlockable(stat: stat, item: StoreOffer.offer(type: .killMonsterPotion, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .chest, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            Unlockable(stat: stat, item: StoreOffer.offer(type: .snakeEyes, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
            /// TIER 2 Rune Slot
            Unlockable(stat: stat, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 100, isPurchased: true, isUnlocked: true, applysToBasePlayer: false, recentlyPurchasedAndHasntSpawnedYet: false, hasBeenTappedOnByPlayer: false),
            
        ]
    }
    
}
