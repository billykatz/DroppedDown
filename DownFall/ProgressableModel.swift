//
//  ProgressableModel.swift
//  DownFall
//
//  Created by Billy on 9/3/21.
//  Copyright © 2021 William Katz LLC. All rights reserved.
//

import Foundation


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

struct Unlockable: Codable, Identifiable, Hashable {
    static func == (lhs: Unlockable, rhs: Unlockable) -> Bool {
        return lhs.id == rhs.id
    }
    
    let stat: Statistics
    let item: StoreOffer
    let purchaseAmount: Int
    
    var id: String {
        return "\(item.type)\(item.textureName)\(item.tier)"
    }
    
}

struct ProgressableModel: Codable {
    let unlockables: [Unlockable]

    
    init() {
        unlockables = StoreOfferType.allCases.map { Unlockable(stat: .gemsCollected(.blue, 100), item: StoreOffer.offer(type: $0, tier: 1), purchaseAmount: 50) }
    }
    
}
