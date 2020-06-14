//
//  FreeDynamite.swift
//  DownFall
//
//  Created by Katz, Billy on 3/29/20.
//  Copyright © 2020 William Katz LLC. All rights reserved.
//

import UIKit

struct FreeDynamite: Ability {
    
    var distanceBetweenTargets: Int? { return nil }
    
    var rechargeMinimum: Int {
        return 1
    }
    
    var progressColor: UIColor {
        return UIColor.darkBarRed
    }
    
    var cooldown: Int { return 0 }
    
    var rechargeType: [TileType] { return [] }
    
    var count: Int
    
    init(count: Int = 0) {
        self.count = 0
    }
    
    func animatedColumns() -> Int? {
        return nil
    }
    
    var affectsCombat: Bool {
        return false
    }
    
    var textureName: String {
        return "dynamite"
    }
    
    var cost: Int { return 0 }
    
    var currency: Currency { return .gold }
    
    var type: AbilityType { return .dynamite }
    
    var description: String {
        return "Destroys one of any kind of rock."
    }
    
    var flavorText: String {
        return "Boom boom boom boom, I want you to go boom."
    }
    
    var extraAttacksGranted: Int? {
        return nil
    }
    
    func blocksDamage(from: Direction) -> Int? {
        return nil
    }
    
    var usage: Usage {
        return .once
    }
    
    var heal: Int? { return nil }
    var targets: Int? { return 1 }
    var targetTypes: [TileType]? { return TileType.rockCases }
}

