//
//  CodexViewModel.swift
//  DownFall
//
//  Created by Billy on 9/3/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation
import Combine


/*
 There are a few different types of items in the game:
   - permanent upgrades: these are things like upgrades to health, dodge, and luck, extra rune slots, and the ability to unlock a 3rd goal
     - health upgrade, level 1-4
     - dodge upgrade, level 1-4
     - luck upgrade, level 1-4
     - runes slots, level 1-4
     - unlock a 3rd level goal
   - one-time use potions: these are things like the transmogrify.  they can appear in levels
     - each item can be unlcok
   - runes: some runes are in the starting game pool but others can be unlocked and purchased so they appear in future runs
 
 Items introduced into the game need to be represented in multiple UIs:
   - In the Progress view
   - Some need to  the game view
 
 Items can be in multiple states:
    - locked or unlocked
    - not purchased or purchased
 
 In the progress view players can:
    - view unlocked items
    - view locked items
    - buy unlocked items

 */


//enum CodingKeys: CodingKey {
//    case stat
//    case item
//    case purchaseAmount
//    case isPurchased
//    case isUnlocked
//}
//
//func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//
//    try container.encode(stat, forKey: .stat)
//    try container.encode(item, forKey: .item)
//    try container.encode(purchaseAmount, forKey: .purchaseAmount)
//    try container.encode(isPurchased, forKey: .isPurchased)
//    try container.encode(isUnlocked, forKey: .isUnlocked)
//}
//
//required init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//
//    stat = try container.decode(Statistics.self, forKey: .stat)
//    item = try container.decode(StoreOffer.self, forKey: .item)
//    purchaseAmount = try container.decode(Int.self, forKey: .purchaseAmount)
//    isPurchased = try container.decode(Bool.self, forKey: .isPurchased)
//    isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
//}

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
        return StoreOfferType.allCases.map { Unlockable(stat: .oneHundredBlueRocks, item: StoreOffer.offer(type: $0, tier: 1), purchaseAmount: 50, isPurchased: false, isUnlocked: true) }
    }
    
}

class CodexViewModel: ObservableObject {
    
    @Published var unlockables: [Unlockable] = []
    var playerData: EntityModel?
    var statData: [Statistics]?
    
    var progress: (Int, Int) {
        var purchasedCount = 0
        var unlockedCount = 0
        
        for unlockable in unlockables {
            purchasedCount += unlockable.isPurchased ? 1 : 0
            unlockedCount += unlockable.isUnlocked ? 1 : 0
        }
        
        return (purchasedCount, unlockedCount)
    }
    
    
    init(unlockables: [Unlockable], playerData: EntityModel, statData: [Statistics]) {
        self.playerData = playerData
        self.statData = statData
        self.unlockables = unlockables
    }
    
    func isUnlocked(unlockableStat: Statistics, playerStats: [Statistics]) -> Bool {
        for stat in playerStats {
            if unlockableStat.statType == stat.statType {
                switch unlockableStat.statType {
                case .rocksDestroyed:
                    return unlockableStat.rockColor == stat.rockColor && stat.amount >= unlockableStat.amount
                case .gemsCollected:
                    return unlockableStat.gemColor == stat.gemColor && stat.amount >= unlockableStat.amount
                case .monstersKilled:
                    return unlockableStat.monsterType == stat.monsterType && stat.amount >= unlockableStat.amount
                case .runeUses:
                    return unlockableStat.runeType == stat.runeType && stat.amount >= unlockableStat.amount
                default:
                    return stat.amount >= unlockableStat.amount
                }
            }
        }
        return false
    }
    
    
    //API
    func purchaseUnlockable(unlockable: Unlockable) {
        guard let index = unlockables.firstIndex(of: unlockable) else { preconditionFailure("Unlockable must be in the array") }
        unlockables[index] = unlockable.purchase()
        self.unlockables = unlockables
    }
    
    
}


extension CodexViewModel: Equatable {
    static func == (lhs: CodexViewModel, rhs: CodexViewModel) -> Bool {
        for lhsUnlockable in lhs.unlockables {
            if !rhs.unlockables.contains(lhsUnlockable) {
                return true
            }
        }
        return lhs.progress == rhs.progress
    
    }
}
