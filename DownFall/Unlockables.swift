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
    
    static var startingUnlockables: [Unlockable] {
        [
            Unlockable(stat: .oneHundredRocks, item: StoreOffer.offer(type: .plusOneMaxHealth, tier: 1), purchaseAmount: 200, isPurchased: true, isUnlocked: true),
            Unlockable(stat: .fiveHundredRocks, item: StoreOffer.offer(type: .plusTwoMaxHealth, tier: 1), purchaseAmount: 200, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneHundredGems, item: StoreOffer.offer(type: .dodge(amount: 5), tier: 1), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneHundredGems, item: StoreOffer.offer(type: .luck(amount: 5), tier: 1), purchaseAmount: 100, isPurchased: false, isUnlocked: false),
            Unlockable(stat: .oneThousandRocks, item: StoreOffer.offer(type: .rune(Rune.rune(for: .bubbleUp)), tier: 1), purchaseAmount: 350, isPurchased: false, isUnlocked: false)
            
        ]
    }
    
}
