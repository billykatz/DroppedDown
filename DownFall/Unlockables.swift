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
    
    var id: String {
        return "\(item.textureName)\(item.tier)"
    }
    
    init(stat: Statistics, item: StoreOffer, purchaseAmount: Int, isPurchased: Bool, isUnlocked: Bool) {
        self.stat = stat
        self.item = item
        self.purchaseAmount = purchaseAmount
        self.isPurchased = isPurchased
        self.isUnlocked = isUnlocked
    }
    
    func purchase() -> Unlockable {
        return Unlockable(stat: stat, item: item, purchaseAmount: purchaseAmount, isPurchased: true, isUnlocked: isUnlocked)
    }
    
    static var debugData: [Unlockable] {
        return StoreOfferType.allCases.map { Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: $0, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true) }
    }
    
    static var debugStartingUnlockables: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: true)
        ]
    }
    
    static var startingUnlockables: [Unlockable] {
        [
            // mined rocks
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 2), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 3), purchaseAmount: 500, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .luck(amount: 5), tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .twoThousandRocks, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 4), purchaseAmount: 1000, isPurchased: false, isUnlocked: false),
           
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .plusTwoMaxHealth, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .blueRocks100Mined, item: StoreOffer.offer(type: .transmogrifyPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .redRocks123Mined, item: StoreOffer.offer(type: .killMonsterPotion, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .purpleRocks501Mined, item: StoreOffer.offer(type: .rune(Rune.rune(for: .drillDown)), tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 1), purchaseAmount: 350, isPurchased: false, isUnlocked: false),
            
            // gems collected
            Unlockable(stat: .blueGems100Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .getSwifty)), tier: 1), purchaseAmount: 350, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .redGems123Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameColumn)), tier: 1), purchaseAmount: 300, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .purpleGems501Collected, item: StoreOffer.offer(type: .rune(Rune.rune(for: .vortex)), tier: 1), purchaseAmount: 250, isPurchased: false, isUnlocked: false),
            
            // monsters killed
            Unlockable(stat: .alamoKilled10, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flipFlop)), tier: 1), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .batKilled10, item: StoreOffer.offer(type: .rune(Rune.rune(for: .flameWall)), tier: 1), purchaseAmount: 125, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .ratKilled10, item: StoreOffer.offer(type: .rune(Rune.rune(for: .gemification)), tier: 1), purchaseAmount: 300, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .monstersKilled100, item: StoreOffer.offer(type: .rune(Rune.rune(for: .undo)), tier: 1), purchaseAmount: 450, isPurchased: false, isUnlocked: false),
            
            
            // rune uses
            Unlockable(stat: .bubbleUpUsed10, item: StoreOffer.offer(type: .rune(Rune.rune(for: .phoenix)), tier: 1), purchaseAmount: 150, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .flameColumnUsed100 , item: StoreOffer.offer(type: .rune(Rune.rune(for: .transformRock)), tier: 1), purchaseAmount: 150, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .allRunesUses101, item: StoreOffer.offer(type: .rune(Rune.rune(for: .moveEarth)), tier: 1), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            
            
            
            // misc
            Unlockable(stat: .allRunesUses101, item: StoreOffer.offer(type: .runeSlot, tier: 1), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .allRunesUses101, item: StoreOffer.offer(type: .runeSlot, tier: 2), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .allRunesUses101, item: StoreOffer.offer(type: .runeSlot, tier: 3), purchaseAmount: 100, isPurchased: false, isUnlocked: false)
        ]
    }
    
}
