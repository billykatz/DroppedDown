//
//  StoreInventory.swift
//  DownFall
//
//  Created by William Katz on 8/13/19.
//  Copyright © 2019 William Katz LLC. All rights reserved.
//

import CoreGraphics

class StoreInventory {
    var inventory: [Ability]?
    
    init() {
        createInventory()
    }
    
    func createInventory() {
        inventory = [DoubleAttack(),
                     ShieldEast(),
                     DoubleAttack(),
                     ShieldEast(),
                     DoubleAttack(),
                     ShieldEast(),
                     DoubleAttack(),
                     ShieldEast(),
                     ShieldEast()]
    }
}

extension StoreInventory: StoreSceneInventory {
    var items: [Ability] {
        return inventory ?? []
    }
}
